@tool
extends Node

# Constants for Nakama connection
const SERVER_KEY := "defaultkey"
const HOST := "45.150.9.103"
const PORT := 7350
const SCHEME := "http"

# Current session and socket variables
var session: NakamaSession = null
var socket: NakamaSocket = null
var client: NakamaClient = null

# Reconnection timer
var _reconnect_timer: Timer = null

# Signals for connection status
signal connected
signal disconnected
signal socket_ready
signal socket_closed
signal connection_failed(error: String)
signal match_state_updated(op_code: int, data: Dictionary, sender_id: String)

func _ready():
	# Initialize the Nakama client
	client = NakamaClient.new(
		NakamaHTTPAdapter.new(),
		SERVER_KEY,
		SCHEME,
		HOST,
		PORT,
		3
	)

# Alias for connect_to_server - used by TestConnection.gd
func connect_to_server() -> bool:
	return await authenticate_async()

func authenticate_async() -> bool:
	# Try to load saved session token
	var auth_file_path := "user://auth.save"
	var auth_token: String = ""

	if FileAccess.file_exists(auth_file_path):
		var read_file := FileAccess.open(auth_file_path, FileAccess.READ)
		if read_file:
			auth_token = read_file.get_as_text()
			read_file.close()

	# Check if we have a saved session and try to restore it
	if !auth_token.is_empty():
		session = client.session_from_token(auth_token)
		if session:
			# Session is valid, emit connected signal
			connected.emit()

			# Connect socket automatically after successful authentication
			await connect_socket_async()
			return true

	# If no valid session, authenticate with device ID
	var device_id := OS.get_unique_id()

	if device_id.is_empty():
		push_error("Failed to get unique device ID")
		return false

	# Attempt authentication with device ID
	var auth_result = await client.authenticate_device_async(device_id, "", true)
	if auth_result.is_err():
		var err_msg := str(auth_result.error())
		push_error("Authentication failed: " + err_msg)
		connection_failed.emit(err_msg)
		return false

	# Store the session
	session = auth_result.ok()

	# Save the session token to file
	var write_file := FileAccess.open(auth_file_path, FileAccess.WRITE)
	if write_file:
		write_file.store_string(session.token)
		write_file.close()
	else:
		push_error("Failed to save authentication token to file")

	# Emit connected signal
	connected.emit()

	# Connect socket automatically after successful authentication
	await connect_socket_async()
	return true

func connect_socket_async() -> bool:
	if !session:
		push_error("Cannot connect socket: no active session")
		return false

	# Create socket from client
	socket = NakamaSocket.new(
		NakamaSocketAdapter.new(),
		HOST,
		PORT,
		"ws",
		true
	)

	# Connect to the server using the current session
	var connect_result = await socket.connect_async(session)
	if connect_result.is_err():
		var err_msg := str(connect_result.error())
		push_error("Socket connection failed: " + err_msg)
		connection_failed.emit(err_msg)
		return false

	# Subscribe to socket signals
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_error)
	socket.received_match_state.connect(_on_socket_match_state)

	# Emit socket ready signal
	socket_ready.emit()

	return true

func _on_socket_closed():
	# Emit socket closed signal
	socket_closed.emit()

	# Start reconnection watchdog
	_start_reconnection_watchdog()

func _on_socket_error(error_data):
	push_error("Socket error: " + str(error_data))

func _start_reconnection_watchdog():
	# Stop any existing reconnection timer
	if _reconnect_timer:
		_reconnect_timer.stop()
		_reconnect_timer.timeout.disconnect(_attempt_reconnect)
		_reconnect_timer.queue_free()

	# Create a new timer for reconnection attempts
	_reconnect_timer = Timer.new()
	add_child(_reconnect_timer)
	_reconnect_timer.wait_time = 3.0  # Try to reconnect every 3 seconds
	_reconnect_timer.timeout.connect(_attempt_reconnect)
	_reconnect_timer.start()

func _attempt_reconnect():
	if session:
		# Try to reconnect the socket
		var reconnect_result = await connect_socket_async()
		if reconnect_result:
			# Successfully reconnected, stop the watchdog
			if _reconnect_timer:
				_reconnect_timer.stop()
				_reconnect_timer.timeout.disconnect(_attempt_reconnect)
				_reconnect_timer.queue_free()
				_reconnect_timer = null

func join_match_async(match_id: String = ""):
	if !socket:
		push_error("Cannot join match: socket not connected")
		return null

	var result

	if match_id.is_empty():
		# Create a new match
		result = await socket.create_match_async()
	else:
		# Join existing match
		result = await socket.join_match_async(match_id)

	if result.is_err():
		push_error("Match operation failed: " + str(result.error()))
		return null

	return result.ok()

func send_match_state(op_code: int, data: Dictionary):
	if !socket:
		push_error("Cannot send match state: socket not connected")
		return

	# Convert dictionary to JSON string, then to bytes
	var json_string := JSON.stringify(data)
	var data_bytes := json_string.to_utf8_buffer()

	# Send match state
	socket.send_match_state(op_code, data_bytes)

func _on_socket_match_state(match_state):
	# Parse JSON from bytes
	var json_string: String = match_state.data.get_string_from_utf8()
	var json_result = JSON.parse_string(json_string)

	if json_result == null:
		push_error("Failed to parse match state JSON: " + json_string)
		return

	if typeof(json_result) != TYPE_DICTIONARY:
		push_error("Parsed match state is not a dictionary: " + str(json_result))
		return

	# Emit the match state updated signal
	match_state_updated.emit(match_state.op_code, json_result, match_state.user_id)

func disconnect_from_server():
	if socket:
		socket.close()
		socket = null

	if session:
		session = null

	# Stop reconnection timer if active
	if _reconnect_timer:
		_reconnect_timer.stop()
		_reconnect_timer.timeout.disconnect(_attempt_reconnect)
		_reconnect_timer.queue_free()
		_reconnect_timer = null

	# Clear saved session
	var auth_file_path := "user://auth.save"
	if FileAccess.file_exists(auth_file_path):
		DirAccess.open("user://").remove(auth_file_path.trim_prefix("user:///"))

	# Emit disconnected signal
	disconnected.emit()
