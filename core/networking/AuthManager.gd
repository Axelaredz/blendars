extends Node

signal authentication_success(session)
signal authentication_failed(error)

var nakama_client
var session

func _ready():
	# Ждем, пока NetworkManager инициализирует клиента
	await get_tree().process_frame
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager:
		nakama_client = network_manager.nakama_client

# Аутентификация через VK (через серверную обработку токена)
func authenticate_vk(vk_access_token: String):
	if not nakama_client:
		push_error("Nakama client not initialized")
		authentication_failed.emit("Nakama client not initialized")
		return false
	
	# Используем authenticate_oauth для VK
	# В реальной реализации сервер Nakama должен быть настроен на прием VK токенов
	var response = await nakama_client.authenticate_oauth("vk", vk_access_token, true)
	if response.is_exception():
		authentication_failed.emit(response.exception.message)
		return false
	
	session = response
	authentication_success.emit(session)
	return true

# Аутентификация через Telegram (через серверную обработку данных)
func authenticate_telegram(telegram_user_data: Dictionary):
	if not nakama_client:
		push_error("Nakama client not initialized")
		authentication_failed.emit("Nakama client not initialized")
		return false
	
	# Для Telegram используем RPC вызов для проверки данных на сервере
	# Это более безопасно, чем отправка подписи клиента
	var rpc_payload = {
		"user_data": telegram_user_data
	}
	
	var response = await nakama_client.rpc("auth_telegram", JSON.stringify(rpc_payload))
	if response.is_exception():
		authentication_failed.emit(response.exception.message)
		return false
	
	# Если RPC успешен, используем результат для аутентификации
	var result = JSON.parse_string(response.payload)
	if result and result.has("session"):
		session = result.session
		authentication_success.emit(session)
		return true
	else:
		authentication_failed.emit("Invalid response from server")
		return false

# Альтернативный метод аутентификации через custom ID (для тестирования)
func authenticate_with_custom_id(custom_id: String):
	if not nakama_client:
		push_error("Nakama client not initialized")
		authentication_failed.emit("Nakama client not initialized")
		return false
	
	var response = await nakama_client.authenticate_custom(custom_id, true)
	if response.is_exception():
		authentication_failed.emit(response.exception.message)
		return false
	
	session = response
	authentication_success.emit(session)
	return true

# Метод для получения информации о пользователе после аутентификации
func get_account_info():
	if not session:
		push_error("Not authenticated")
		return null
	
	var response = await nakama_client.get_account(session)
	if response.is_exception():
		push_error("Failed to get account info: " + response.exception.message)
		return null
	
	return response

# Метод для обновления токена сессии
func refresh_session():
	if not session or not nakama_client:
		return false
	
	var response = await nakama_client.session_refresh(session)
	if response.is_exception():
		authentication_failed.emit(response.exception.message)
		return false
	
	session = response
	return true
