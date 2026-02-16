extends Node

# Network manager singleton для управления подключением к Nakama
# Важно: инициализируется до остальных сетевых компонентов

signal connected
signal disconnected
signal authentication_failed(error_message: String)
signal lobby_joined(lobby_id: String)
signal lobby_left(lobby_id: String)
signal match_found(match_data: Dictionary)

var nakama_client = null
var nakama_socket = null

# Настройки подключения
var server_url := "http://127.0.0.1:7350"
var api_key := "defaultkey"

# Текущее состояние
var is_connected := false
var current_lobby_id: String = ""

func _ready():
	_initialize_nakama_client()

func _initialize_nakama_client():
	nakama_client = preload("res://client/autoload/nakama_client.gd").new()
	add_child(nakama_client)
	
	# Подписываемся на события клиента
	nakama_client.connected.connect(_on_connected)
	nakama_client.disconnected.connect(_on_disconnected)
	nakama_client.authentication_failed.connect(_on_authentication_failed)

func connect_to_server() -> void:
	if is_connected:
		print("Уже подключен к серверу")
		return
	
	# Попробуем использовать анонимную аутентификацию как fallback
	var device_id = OS.get_unique_id()
	var response = await nakama_client.authenticate_device(device_id, "", true)
	
	if response.is_empty():
		printerr("Ошибка аутентификации")
		return
	
	is_connected = true
	connected.emit()

func disconnect_from_server() -> void:
	if nakama_socket:
		nakama_socket.disconnect_from_server()
	nakama_client.disconnect()
	is_connected = false
	disconnected.emit()

func _on_connected():
	is_connected = true
	connected.emit()
	
	# Создаем сокетное соединение после успешной аутентификации
	nakama_socket = nakama_client.create_socket_connection()
	add_child(nakama_socket)
	
	# Подписываемся на события сокета
	nakama_socket.received_channel_message.connect(_on_channel_message)
	nakama_socket.received_match_state.connect(_on_match_state)
	nakama_socket.received_match_presence_event.connect(_on_match_presence_event)
	nakama_socket.disconnected.connect(_on_socket_disconnected)
	
	# Также подписываемся на matchmaker события
	nakama_socket.received_match_presence_event.connect(_on_matchmaker_matched)

func _on_disconnected():
	is_connected = false
	disconnected.emit()

func _on_authentication_failed(error_message: String):
	authentication_failed.emit(error_message)

func _on_socket_disconnected():
	is_connected = false
	disconnected.emit()

# Заглушка для обработки сообщений
func _on_channel_message(channel_message):
	pass

# Обработчик состояния матча
func _on_match_state(match_state):
	# Обработка игровых данных матча
	pass

# Обработчик событий присутствия в матче
func _on_match_presence_event(presence_event):
	# Обработка изменений состава игроков в матче
	pass

# Обработчик событий матчмейкинга
func _on_matchmaker_matched(presence_event):
	# Проверяем, является ли это событием найденного матча
	if presence_event.has("room") and presence_event.room.began:
		# Это начало нового матча через матчмейкинг
		var match_data = {
			"match_id": presence_event.room.id,
			"users": presence_event.joins,
			"host_user_id": presence_event.room.self.id if presence_event.has("room") and presence_event.room.has("self") else ""
		}
		match_found.emit(match_data)

func authenticate_with_email(email: String, password: String) -> bool:
	var response = await nakama_client.authenticate_email(email, password, "", true)
	
	if response.is_empty():
		return false
	
	is_connected = true
	connected.emit()
	
	# Создаем сокетное соединение после успешной аутентификации
	nakama_socket = nakama_client.create_socket_connection()
	add_child(nakama_socket)
	
	# Подписываемся на события сокета
	nakama_socket.received_channel_message.connect(_on_channel_message)
	nakama_socket.received_match_state.connect(_on_match_state)
	nakama_socket.received_match_presence_event.connect(_on_match_presence_event)
	nakama_socket.disconnected.connect(_on_socket_disconnected)
	
	# Также подписываемся на matchmaker события
	nakama_socket.received_match_presence_event.connect(_on_matchmaker_matched)
	
	return true

func authenticate_with_username(username: String, password: String) -> bool:
	var response = await nakama_client.authenticate_username(username, password, "", true)
	
	if response.is_empty():
		return false
	
	is_connected = true
	connected.emit()
	
	# Создаем сокетное соединение после успешной аутентификации
	nakama_socket = nakama_client.create_socket_connection()
	add_child(nakama_socket)
	
	# Подписываемся на события сокета
	nakama_socket.received_channel_message.connect(_on_channel_message)
	nakama_socket.received_match_state.connect(_on_match_state)
	nakama_socket.received_match_presence_event.connect(_on_match_presence_event)
	nakama_socket.disconnected.connect(_on_socket_disconnected)
	
	# Также подписываемся на matchmaker события
	nakama_socket.received_match_presence_event.connect(_on_matchmaker_matched)
	
	return true

# Метод для получения профиля пользователя
func get_user_profile() -> Dictionary:
	var response = await nakama_client.get_account()
	if response.is_empty():
		printerr("Ошибка получения профиля")
		return {}
	
	return {
		"user_id": response.user.id,
		"username": response.user.username,
		"display_name": response.user.display_name,
		"avatar_url": response.user.avatar_url
	}

# RPC вызовы
func rpc_call(rpc_name: String, payload: String = ""):
	var response = await nakama_client.rpc(rpc_name, payload)
	if response.is_empty():
		printerr("RPC вызов не удался")
		return null
	
	return response