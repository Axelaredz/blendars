extends Node

# Godot Headless Game Server
# Запускается с --headless и является authoritative сервером

const Protocol = preload("res://src/shared/protocol.gd")

## Configuration
@export var listen_port: int = 7777
@export var max_players: int = 64
@export var tick_rate: int = 20

## Network
var peer: ENetMultiplayerPeer
var server: ENetPacketPeer
var connected_peers: Dictionary = {}

## Game State
var players: Dictionary = {}  # peer_id -> PlayerData
var world_state: Dictionary = {}

## Nakama validation
var nakama_client: NakamaClient
var nakama_session: NakamaSession
var nakama_http_adapter: NakamaHTTPAdapter
var nakama_server_key: String = "defaultkey"
var nakama_host: String = "127.0.0.1"
var nakama_port: int = 7350

## Tick timer
var tick_timer: Timer
var tick_interval: float

## Signals
signal player_connected(peer_id: int, player_data: Dictionary)
signal player_disconnected(peer_id: int)
signal packet_received(peer_id: int, opcode: int, data: Dictionary)


func _ready() -> void:
	print("[Server] Starting Godot Game Server...")
	print("[Server] Port: %d, Max Players: %d, Tick Rate: %d" % [listen_port, max_players, tick_rate])
	
	# Validate Nakama connection
	await _validate_nakama_connection()
	
	# Start ENet server
	_start_server()
	
	# Start tick loop
	tick_interval = 1.0 / tick_rate
	tick_timer = Timer.new()
	tick_timer.wait_time = tick_interval
	tick_timer.timeout.connect(_on_tick)
	add_child(tick_timer)
	tick_timer.start()
	
	print("[Server] Server started successfully")


func _start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(listen_port, max_players)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error("[Server] Failed to start ENet server on port %d" % listen_port)
		get_tree().quit(1)
		return
	
	multiplayer.peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	print("[Server] ENet listening on port %d" % listen_port)


func _validate_nakama_connection() -> void:
	# Get Nakama config from environment or config file
	var nakama_host := OS.get_environment("NAKAMA_HOST")
	var nakama_port := OS.get_environment("NAKAMA_PORT")
	var server_key := OS.get_environment("NAKAMA_SERVER_KEY")
	
	if nakama_host.is_empty():
		# Default values for local development
		nakama_host = "127.0.0.1"
		nakama_port = "7350"
		server_key = "defaultkey"
	
	nakama_http_adapter = NakamaHTTPAdapter.new()
	nakama_client = NakamaClient.new(nakama_http_adapter, server_key, "http", nakama_host, int(nakama_port), 3)
	
	print("[Server] Connecting to Nakama at %s:%s" % [nakama_host, nakama_port])


func _on_peer_connected(peer_id: int) -> void:
	print("[Server] Peer connected: %d" % peer_id)
	connected_peers[peer_id] = true
	
	# Wait for AUTH_REQUEST before adding to game
	# Don't add to players dict yet


func _on_peer_disconnected(peer_id: int) -> void:
	print("[Server] Peer disconnected: %d" % peer_id)
	connected_peers.erase(peer_id)
	
	if players.has(peer_id):
		var player_data := players[peer_id] as Dictionary
		_broadcast_player_leave(peer_id, player_data)
		players.erase(peer_id)
	
	player_disconnected.emit(peer_id)


func _on_tick() -> void:
	# Update game state
	_update_world_state()
	
	# Send world updates to all players
	_broadcast_world_state()


func _update_world_state() -> void:
	# Update server-side game logic here
	# Physics, AI, combat, etc.
	pass


func _broadcast_world_state() -> void:
	if players.is_empty():
		return
	
	var world_update := {
		"players": _serialize_players(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var packet := _create_packet(Protocol.Opcode.WORLD_UPDATE, world_update)
	_send_to_all(packet)


func _serialize_players() -> Array:
	var serialized := []
	for peer_id in players:
		serialized.append(players[peer_id])
	return serialized


func _broadcast_player_join(peer_id: int, player_data: Dictionary) -> void:
	var packet_data := {
		"peer_id": peer_id,
		"player": player_data
	}
	var packet := _create_packet(Protocol.Opcode.PLAYER_JOIN, packet_data)
	_send_to_all_except(peer_id, packet)


func _broadcast_player_leave(peer_id: int, player_data: Dictionary) -> void:
	var packet_data := {
		"peer_id": peer_id,
		"player": player_data
	}
	var packet := _create_packet(Protocol.Opcode.PLAYER_LEAVE, packet_data)
	_send_to_all(packet)


func _create_packet(opcode: int, data: Dictionary) -> PackedByteArray:
	var json := JSON.stringify(data)
	var bytes := json.to_utf8_buffer()
	
	# Prepend opcode (4 bytes)
	var packet := PackedByteArray()
	packet.resize(4)
	packet.encode_s32(0, opcode)
	packet.append_array(bytes)
	
	return packet


func _send_to_all(packet: PackedByteArray) -> void:
	for peer_id in connected_peers:
		if peer_id != 1:  # Skip server peer
			peer.send(peer_id, packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


func _send_to_all_except(exclude_peer: int, packet: PackedByteArray) -> void:
	for peer_id in connected_peers:
		if peer_id != 1 and peer_id != exclude_peer:
			peer.send(peer_id, packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


func _send_to_peer(peer_id: int, packet: PackedByteArray) -> void:
	peer.send(peer_id, packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


func _process_raw_packet(peer_id: int, packet: PackedByteArray) -> void:
	if packet.size() < 4:
		return
	
	var opcode := packet.decode_s32(0)
	var data_bytes := packet.slice(4)
	var json_string := data_bytes.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(json_string)
	var data: Dictionary = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	
	packet_received.emit(peer_id, opcode, data)
	
	match opcode:
		Protocol.Opcode.AUTH_REQUEST:
			_handle_auth_request(peer_id, data)
		Protocol.Opcode.PLAYER_MOVE:
			_handle_player_move(peer_id, data)
		Protocol.Opcode.CHAT_MESSAGE:
			_handle_chat_message(peer_id, data)
		Protocol.Opcode.DISCONNECT:
			_handle_disconnect(peer_id)


func _handle_auth_request(peer_id: int, data: Dictionary) -> void:
	var token: String = data.get("token", "")
	var user_id: String = data.get("user_id", "")
	
	# Validate token with Nakama
	var valid := await _validate_session(token)
	
	if valid:
		var player_data := {
			"peer_id": peer_id,
			"user_id": user_id,
			"position": Vector3.ZERO,
			"rotation": Vector3.ZERO,
			"state": Protocol.PlayerState.NORMAL
		}
		players[peer_id] = player_data
		
		# Send AUTH_RESPONSE
		var response := _create_packet(Protocol.Opcode.AUTH_RESPONSE, {
			"success": true,
			"peer_id": peer_id,
			"players": _serialize_players()
		})
		_send_to_peer(peer_id, response)
		
		# Broadcast new player to others
		_broadcast_player_join(peer_id, player_data)
		
		player_connected.emit(peer_id, player_data)
		print("[Server] Player authenticated: %s (peer_id: %d)" % [user_id, peer_id])
	else:
		var fail_packet := _create_packet(Protocol.Opcode.AUTH_FAILED, {
			"error": "Invalid session"
		})
		_send_to_peer(peer_id, fail_packet)
		peer.disconnect_peer(peer_id, true)


func _validate_session(token: String) -> bool:
	# Call Nakama RPC to validate session
	var rpc_result = await nakama_client.rpc_async(nakama_session, "validate_session", JSON.stringify({"token": token}))
	return not rpc_result.is_err()


func _handle_player_move(peer_id: int, data: Dictionary) -> void:
	if not players.has(peer_id):
		return
	
	players[peer_id]["position"] = data.get("position", Vector3.ZERO)
	players[peer_id]["rotation"] = data.get("rotation", Vector3.ZERO)
	players[peer_id]["state"] = data.get("state", Protocol.PlayerState.NORMAL)
	
	# Broadcast to other players
	var packet := _create_packet(Protocol.Opcode.PLAYER_MOVE, {
		"peer_id": peer_id,
		"position": players[peer_id]["position"],
		"rotation": players[peer_id]["rotation"]
	})
	_send_to_all_except(peer_id, packet)


func _handle_chat_message(peer_id: int, data: Dictionary) -> void:
	var message: String = data.get("message", "")
	if message.is_empty():
		return
	
	# Broadcast chat message
	var packet := _create_packet(Protocol.Opcode.CHAT_BROADCAST, {
		"peer_id": peer_id,
		"message": message
	})
	_send_to_all(packet)


func _handle_disconnect(peer_id: int) -> void:
	peer.disconnect_peer(peer_id, true)


# Called by Godot's multiplayer system
func _process(delta: float) -> void:
	# Poll packets from ENet
	peer.poll()
	
	# Process incoming packets
	while peer.get_available_peer_count() > 0:
		var packet: PackedByteArray
		var peer_id: int = peer.receive_packet(packet)
		
		if packet.is_empty():
			continue
		
		_process_raw_packet(peer_id, packet)


func _exit_tree() -> void:
	print("[Server] Shutting down...")
	if tick_timer:
		tick_timer.stop()
	if peer:
		peer.close()
