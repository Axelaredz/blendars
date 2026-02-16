extends Node

# Минимальная реализация Nakama клиента для Godot
# Вместо стороннего аддона используем прямые HTTP вызовы к Nakama API

signal connected
signal disconnected
signal authentication_failed(error_message: String)
signal session_updated(session: Dictionary)

var server_url := "http://127.0.0.1:7350"
var api_key := "defaultkey"
var base_url: String = ""
var session_token: String = ""
var refresh_token: String = ""
var user_id: String = ""
var username: String = ""

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	base_url = server_url

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	#print("Request completed: ", result, ", code: ", response_code)
	#var response_body = body.get_string_from_utf8()
	#print("Response: ", response_body)
	pass

# Аутентификация через устройство (fallback вариант)
func authenticate_device(device_id: String = "", username: String = "", create: bool = true) -> Dictionary:
	var endpoint = base_url + "/v2/account/authenticate/device"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Basic %s" % _encode_base64(api_key + ":")
	]
	
	var device_id_final = device_id if !device_id.is_empty() else OS.get_unique_id()
	var payload = {
		"deviceId": device_id_final,
		"username": username if !username.is_empty() else device_id_final,
		"create": create
	}.to_json()
	
	var result = await _make_request(endpoint, headers, payload, "POST")
	
	if result.has("error"):
		authentication_failed.emit(str(result.error))
		return {}
	
	session_token = result.token
	refresh_token = result.refresh_token
	user_id = result.user_id
	username = result.username
	
	session_updated.emit({
		"token": session_token,
		"refresh_token": refresh_token,
		"user_id": user_id,
		"username": username
	})
	
	connected.emit()
	return result

# Аутентификация по email
func authenticate_email(email: String, password: String, username: String = "", create: bool = true) -> Dictionary:
	var endpoint = base_url + "/v2/account/authenticate/email"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Basic %s" % _encode_base64(api_key + ":")
	]
	
	var payload = {
		"email": email,
		"password": password,
		"username": username,
		"create": create
	}.to_json()
	
	var result = await _make_request(endpoint, headers, payload, "POST")
	
	if result.has("error"):
		authentication_failed.emit(str(result.error))
		return {}
	
	session_token = result.token
	refresh_token = result.refresh_token
	user_id = result.user_id
	username = result.username
	
	session_updated.emit({
		"token": session_token,
		"refresh_token": refresh_token,
		"user_id": user_id,
		"username": username
	})
	
	connected.emit()
	return result

# Аутентификация по username
func authenticate_username(username: String, password: String, create: bool = true) -> Dictionary:
	var endpoint = base_url + "/v2/account/authenticate/username"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Basic %s" % _encode_base64(api_key + ":")
	]
	
	var payload = {
		"username": username,
		"password": password,
		"create": create
	}.to_json()
	
	var result = await _make_request(endpoint, headers, payload, "POST")
	
	if result.has("error"):
		authentication_failed.emit(str(result.error))
		return {}
	
	session_token = result.token
	refresh_token = result.refresh_token
	user_id = result.user_id
	username = result.username
	
	session_updated.emit({
		"token": session_token,
		"refresh_token": refresh_token,
		"user_id": user_id,
		"username": result.username
	})
	
	connected.emit()
	return result

# Получить информацию о пользователе
func get_account() -> Dictionary:
	if session_token.is_empty():
		printerr("Нет активной сессии для получения аккаунта")
		return {}
	
	var endpoint = base_url + "/v2/account"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % session_token
	]
	
	return await _make_request(endpoint, headers, "", "GET")

# Вызов RPC функции
func rpc(id: String, payload: String = "") -> Dictionary:
	if session_token.is_empty():
		printerr("Нет активной сессии для RPC вызова")
		return {}
	
	var endpoint = base_url + "/v2/rpc/%s" % id
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % session_token
	]
	
	var json_payload = ""
	if !payload.is_empty():
		json_payload = payload.to_json()
	else:
		json_payload = {}.to_json()
	
	return await _make_request(endpoint, headers, json_payload, "POST")

# Создать сокетное соединение (заглушка - для полноценной реализации потребуется WebSocket)
func create_socket_connection() -> NakamaSocket:
	return NakamaSocket.new(base_url.replace("http", "ws"), session_token)

# Внутренний метод для выполнения HTTP запросов
func _make_request(url: String, headers: Array, body: String, method: String) -> Dictionary:
	# Устанавливаем таймаут
	http_request.timeout = 10
	
	var request_headers = headers.duplicate()
	
	var body_bytes = []
	if body != "":
		body_bytes = body.to_utf8_buffer()
	
	var error = await http_request.request(url, request_headers, method, body_bytes)
	
	if error != OK:
		return {"error": "Network request failed with error code: %d" % error}
	
	# Ждем завершения запроса
	var result = await http_request.request_completed
	
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		return {"error": "Request failed with result: %d" % result[0]}
	
	var response_code = result[1]
	var response_body = result[3].get_string_from_utf8()
	
	# Проверяем успешность запроса
	if response_code >= 200 and response_code < 300:
		# Пытаемся распарсить JSON ответ
		var json_result = JSON.parse_string(response_body)
		if json_result != null:
			return json_result
		else:
			return {"error": "Failed to parse JSON response", "raw_response": response_body}
	else:
		return {"error": "Request failed with status code: %d, body: %s" % [response_code, response_body]}

# Вспомогательная функция для Base64 кодирования
func _encode_base64(text: String) -> String:
	return text.to_utf8_buffer().to_base64()

# Проверка валидности сессии
func is_session_valid() -> bool:
	return !session_token.is_empty()

# Обновление сессии (не реализовано в этой версии)
func refresh_session():
	# Здесь должна быть реализация обновления токена через refresh_token
	pass

# Отключение
func disconnect():
	session_token = ""
	refresh_token = ""
	user_id = ""
	username = ""
	disconnected.emit()