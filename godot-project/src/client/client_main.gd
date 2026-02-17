extends Node

# Godot Client - сетевой клиент для подключения к Game Server

## Configuration
@export var game_server_host: String = "127.0.0.1"
@export var game_server_port: int = 7777
@export var nakama_host: String = "127.0.0.1"
@export var nakama_port: int = 7350
@export var server_key: String = "defaultkey"

## Network
var peer: ENetMultiplayerPeer
var is_connected: bool = false

## Nakama
var nakama_client: NakamaClient
var nakama_session: NakamaSession
var nakama_socket: NakamaSocket

## Game State
var local_peer_id: int = 0
var remote_players: Dictionary = {}  # peer_id -> player_data
var my_player_data: Dictionary = {}

## Autoload reference
var network_manager: Node = null

## Signals
signal connected_to_server(peer_id: int)
signal disconnected_from_server()
signal player_joined(peer_id: int, player_data: Dictionary)
signal player_left(peer_id: int)
signal world_updated(players: Dictionary)
signal auth_failed(error: String)

const Protocol = preload("res://src/shared/protocol.gd")

func _ready() -> void:
	print("[Client] Starting Godot Client...")
	
	# Get network manager autoload
	network_manager = get_node("/root/NetworkManager")
	
	# Initialize Nakama client
	_initialize_nakama()


func _initialize_nakama() -> void:
	var http_adapter := NakamaHTTPAdapter.new()
	nakama_client = NakamaClient.new(http_adapter, server_key, "http", nakama_host, nakama_port, 3)
	print("[Client] Nakama client initialized")


func connect_to_game_server(nakama_token: String, user_id: String) -> void:
	print("[Client] Connecting to game server at %s:%d" % [game_server_host, game_server_port])
	
	# First authenticate with Nakama to get valid session
	var auth_result := await _authenticate_with_nakama(nakama_token, user_id)
	if not auth_result:
		auth_failed.emit("Nakama authentication failed")
		return
	
	# Connect to game server via ENet
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(game_server_host, game_server_port)
	
	if err != OK:
		push_error("[Client] Failed to create client: " + str(err))
		auth_failed.emit("Failed to create client connection")
		return
	
	multiplayer.peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Wait for connection
	await get_tree().create_timer(2.0).timeout
	
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		push_error("[Client] Failed to connect to game server")
		auth_failed.emit("Connection to game server failed")
		return
	
	print("[Client] Connected to game server successfully")


func _authenticate_with_nakama(nakama_token: String, user_id: String) -> bool:
	# Validate token with Nakama
	var rpc_result = await nakama_client.rpc_async(nakama_session, "validate_session", JSON.stringify({"token": nakama_token}))
	
	if rpc_result.is_err():
		print("[Client] Nakama validation failed: " + str(rpc_result.error()))
		return false
	
	return true


func _on_peer_connected(id: int) -> void:
	print("[Client] Connected to server with peer_id: %d" % id)
	local_peer_id = id
	is_connected = true
	
	# Send authentication request
	_send_auth_request()
	
	connected_to_server.emit(id)


func _on_peer_disconnected(id: int) -> void:
	print("[Client] Disconnected from server")
	is_connected = false
	remote_players.clear()
	disconnected_from_server.emit()


func _send_auth_request() -> void:
	# Send AUTH_REQUEST with Nakama token
	var auth_data := {
		"token": nakama_session.token if nakama_session else "",
		"user_id": nakama_session.user_id if nakama_session else ""
	}
	
	var packet := _create_packet(Protocol.Opcode.AUTH_REQUEST, auth_data)
	peer.send(packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


func _create_packet(opcode: int, data: Dictionary) -> PackedByteArray:
	var json := JSON.stringify(data)
	var bytes := json.to_utf8_buffer()
	
	var packet := PackedByteArray()
	packet.resize(4)
	packet.encode_s32(0, opcode)
	packet.append_array(bytes)
	
	return packet


func _process(delta: float) -> void:
	if not is_connected:
		return
	
	# Poll packets
	peer.poll()
	
	while peer.get_available_peer_count() > 0:
		var packet: PackedByteArray
		var peer_id: int = peer.receive_packet(packet)
		
		if packet.is_empty():
			continue
		
		_process_packet(packet)


func _process_packet(packet: PackedByteArray) -> void:
	if packet.size() < 4:
		return
	
	var opcode := packet.decode_s32(0)
	var data_bytes := packet.slice(4)
	var json_string := data_bytes.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(json_string)
	var data: Dictionary = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	
	match opcode:
		Protocol.Opcode.AUTH_RESPONSE:
			_handle_auth_response(data)
		Protocol.Opcode.AUTH_FAILED:
			_handle_auth_failed(data)
		Protocol.Opcode.PLAYER_JOIN:
			_handle_player_join(data)
		Protocol.Opcode.PLAYER_LEAVE:
			_handle_player_leave(data)
		Protocol.Opcode.PLAYER_MOVE:
			_handle_player_move(data)
		Protocol.Opcode.WORLD_UPDATE:
			_handle_world_update(data)
		Protocol.Opcode.CHAT_BROADCAST:
			_handle_chat_broadcast(data)


func _handle_auth_response(data: Dictionary) -> void:
	print("[Client] Authentication successful!")
	
	if data.has("players"):
		var players: Array = data["players"] as Array
		for player in players:
			var p: Dictionary = player as Dictionary
			if p.has("peer_id") and p["peer_id"] != local_peer_id:
				remote_players[p["peer_id"]] = p
				player_joined.emit(p["peer_id"], p)
	
	connected_to_server.emit(local_peer_id)


func _handle_auth_failed(data: Dictionary) -> void:
	var error: String = data.get("error", "Unknown error")
	print("[Client] Authentication failed: " + error)
	auth_failed.emit(error)
	peer.disconnect_peer(0, true)


func _handle_player_join(data: Dictionary) -> void:
	var peer_id: int = data.get("peer_id", -1)
	var player_data: Dictionary = data.get("player", {})
	
	if peer_id > 0 and peer_id != local_peer_id:
		remote_players[peer_id] = player_data
		player_joined.emit(peer_id, player_data)
		print("[Client] Player joined: %d" % peer_id)


func _handle_player_leave(data: Dictionary) -> void:
	var peer_id: int = data.get("peer_id", -1)
	
	if peer_id > 0:
		remote_players.erase(peer_id)
		player_left.emit(peer_id)
		print("[Client] Player left: %d" % peer_id)


func _handle_player_move(data: Dictionary) -> void:
	var peer_id: int = data.get("peer_id", -1)
	
	if peer_id > 0 and peer_id != local_peer_id:
		if not remote_players.has(peer_id):
			remote_players[peer_id] = {}
		
		remote_players[peer_id]["position"] = data.get("position", Vector3.ZERO)
		remote_players[peer_id]["rotation"] = data.get("rotation", Vector3.ZERO)


func _handle_world_update(data: Dictionary) -> void:
	if data.has("players"):
		var players: Array = data["players"]
		for player in players:
			var p: Dictionary = player as Dictionary
			var peer_id: int = p.get("peer_id", -1)
			
			if peer_id > 0 and peer_id != local_peer_id:
				remote_players[peer_id] = p
		
		world_updated.emit(remote_players)


func _handle_chat_broadcast(data: Dictionary) -> void:
	var peer_id: int = data.get("peer_id", -1)
	var message: String = data.get("message", "")
	var sender_name: String = "Player %d" % peer_id
	
	if remote_players.has(peer_id) and remote_players[peer_id].has("display_name"):
		sender_name = remote_players[peer_id]["display_name"]
	
	print("[Chat] %s: %s" % [sender_name, message])


## Public API

func send_player_position(position: Vector3, rotation: Vector3) -> void:
	if not is_connected:
		return
	
	var move_data := {
		"position": position,
		"rotation": rotation
	}
	
	var packet := _create_packet(Protocol.Opcode.PLAYER_MOVE, move_data)
	peer.send(packet, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)


func send_chat_message(message: String) -> void:
	if not is_connected:
		return
	
	var chat_data := {
		"message": message
	}
	
	var packet := _create_packet(Protocol.Opcode.CHAT_MESSAGE, chat_data)
	peer.send(packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)


func disconnect_from_game_server() -> void:
	if is_connected:
		var packet := _create_packet(Protocol.Opcode.DISCONNECT, {})
		peer.send(packet, MultiplayerPeer.TRANSFER_MODE_RELIABLE)
		peer.disconnect_peer(0, true)
		is_connected = false
		remote_players.clear()
		print("[Client] Disconnected from game server")


func get_connected_players() -> Dictionary:
	return remote_players.duplicate(true)
