extends Node

# Реализация WebSocket сокета для Nakama
# Этот класс будет использоваться для реального времени взаимодействия

signal connected
signal disconnected
signal received_error(error_message: String)
signal received_channel_message(message)
signal received_match_state(state)
signal received_match_presence_event(event)
signal received_status_presence_event(event)

var ws: WebSocketPeer
var socket_url: String
var auth_token: String
var is_connected: bool = false
var connection_attempts: int = 0
var max_reconnect_attempts: int = 5

func _init(ws_url: String, token: String):
	socket_url = ws_url
	auth_token = token
	ws = WebSocketPeer.new()
	
	# Заменяем протокол и добавляем токен авторизации
	socket_url = socket_url.replace("http", "ws") + "/ws?token=" + auth_token

func _process(_delta):
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.poll()
		_process_messages()
	elif ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			disconnected.emit()
			
			# Попытка переподключения
			if connection_attempts < max_reconnect_attempts:
				connection_attempts += 1
				await get_tree().create_timer(2.0).timeout
				await connect_to_server()
	elif ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		ws.poll()

func connect_to_server() -> bool:
	var err = ws.connect_to_url(socket_url)
	if err != OK:
		printerr("Ошибка подключения к WebSocket: ", err)
		received_error.emit("WebSocket connection error: %d" % err)
		return false
	
	while ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		ws.poll()
		await get_tree().process_frame
		
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		is_connected = true
		connection_attempts = 0  # Сброс попыток подключения при успешном подключении
		connected.emit()
		return true
	else:
		printerr("Не удалось установить WebSocket соединение")
		received_error.emit("Failed to establish WebSocket connection")
		return false

func disconnect_from_server():
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.close()
	is_connected = false
	disconnected.emit()

func _process_messages():
	while ws.get_available_packet_count():
		var packet = ws.get_packet()
		var json_string = packet.get_string_from_utf8()
		var json = JSON.parse_string(json_string)
		
		if json == null:
			continue
			
		# Обработка различных типов сообщений от Nakama
		if json.has("cid"):
			# Это ответ на наш запрос
			_handle_response(json)
		elif json.has("channel_message"):
			# Сообщение в канале
			received_channel_message.emit(json.channel_message)
		elif json.has("match_data"):
			# Данные матча
			received_match_state.emit(json.match_data)
		elif json.has("match_presence_event"):
			# Изменение присутствия в матче
			received_match_presence_event.emit(json.match_presence_event)
		elif json.has("status_presence_event"):
			# Изменение статуса пользователя
			received_status_presence_event.emit(json.status_presence_event)

func _handle_response(data):
	# Обработка ответов на наши запросы
	pass

# Отправка данных через сокет
func send_json(data: Dictionary) -> bool:
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		printerr("Попытка отправить данные в закрытом сокете")
		return false
	
	var json_string = data.to_json()
	var err = ws.send_text(json_string)
	return err == OK

# Отправка сообщения в канал
func send_channel_message(channel_id: String, content: Dictionary) -> bool:
	var data = {
		"id": randi(),
		"joins": [],
		"leaves": [],
		"channel_message_send": {
			"channel_id": channel_id,
			"content": content
		}
	}
	return send_json(data)

# Присоединиться к каналу
func join_chat_channel(channel_type: int, target: String, persistence: bool = true, hidden: bool = false) -> bool:
	var data = {
		"id": randi(),
		"joins": [],
		"leaves": [],
		"channel_join": {
			"target": target,
			"type": channel_type,
			"persistence": persistence,
			"hidden": hidden
		}
	}
	return send_json(data)

# Покинуть канал
func leave_chat_channel(channel_type: int, target: String) -> bool:
	var data = {
		"id": randi(),
		"joins": [],
		"leaves": [],
		"channel_leave": {
			"target": target,
			"type": channel_type
		}
	}
	return send_json(data)

# Создать матч
func create_match(match_label: String = "") -> bool:
	var data = {
		"id": randi(),
		"match_create": {
			"name": match_label
		}
	}
	return send_json(data)

# Присоединиться к матчу
func join_match(match_id: String, metadata: Dictionary = {}) -> bool:
	var data = {
		"id": randi(),
		"match_join": {
			"match_id": match_id,
			"metadata": metadata
		}
	}
	return send_json(data)

# Покинуть матч
func leave_match(match_id: String) -> bool:
	var data = {
		"id": randi(),
		"match_leave": {
			"match_id": match_id
		}
	}
	return send_json(data)

# Отправить данные в матч
func send_match_data(match_id: String, op_code: int, data: Dictionary, reliable: bool = true) -> bool:
	var match_data = {
		"match_id": match_id,
		"op_code": op_code,
		"data": data.to_json(),
		"reliable": reliable
	}
	
	var payload = {
		"id": randi(),
		"match_data_send": match_data
	}
	
	return send_json(payload)

# Отправить статус пользователя
func update_status(status: String) -> bool:
	var data = {
		"id": randi(),
		"status_follow": [],
		"status_unfollow": [],
		"status_update": {
			"status": status
		}
	}
	return send_json(data)