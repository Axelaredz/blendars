extends Node

# Nakama клиент для Godot 4.6 используя официальный плагин
# Этот класс оборачивает официальный Nakama GDScript API для удобства использования

signal connected
signal disconnected
signal authentication_failed(error_message: String)
signal session_updated(session: Dictionary)

# Импортируем официальные классы Nakama
var NakamaApi = load("res://addons/com.heroiclabs.nakama/api/NakamaAPI.gd")
var NakamaClient = load("res://addons/com.heroiclabs.nakama/client/NakamaClient.gd")
var NakamaSession = load("res://addons/com.heroiclabs.nakama/api/NakamaSession.gd")

var server_url := "http://127.0.0.1:7350"
var api_key := "defaultkey"
var port: int = 7350
var ssl: bool = false

var client = null
var session = null

func _ready():
	_initialize_client()

func _initialize_client():
	client = NakamaClient.new(NakamaApi.new(server_url, port, api_key, ssl))

# Аутентификация через устройство (fallback вариант)
func authenticate_device(device_id: String = "", username: String = "", create: bool = true) -> Dictionary:
	var device_id_final = device_id if !device_id.is_empty() else OS.get_unique_id()
	
	var result = await client.authenticate_device(device_id_final, username, create)
	if result.is_exception():
		authentication_failed.emit(result.get_exception().message)
		return {}
	
	session = result.get()
	session_updated.emit({
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	})
	
	connected.emit()
	return {
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	}

# Аутентификация по email
func authenticate_email(email: String, password: String, username: String = "", create: bool = true) -> Dictionary:
	var result = await client.authenticate_email(email, password, username, create)
	if result.is_exception():
		authentication_failed.emit(result.get_exception().message)
		return {}
	
	session = result.get()
	session_updated.emit({
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	})
	
	connected.emit()
	return {
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	}

# Аутентификация по username
func authenticate_username(username: String, password: String, create: bool = true) -> Dictionary:
	var result = await client.authenticate_username(username, password, create)
	if result.is_exception():
		authentication_failed.emit(result.get_exception().message)
		return {}
	
	session = result.get()
	session_updated.emit({
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	})
	
	connected.emit()
	return {
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	}

# Получить информацию о пользователе
func get_account() -> Dictionary:
	if not session:
		printerr("Нет активной сессии для получения аккаунта")
		return {}
	
	var result = await client.get_account(session)
	if result.is_exception():
		printerr("Ошибка получения аккаунта: ", result.get_exception().message)
		return {}
	
	var account = result.get()
	return {
		"user": {
			"id": account.id,
			"username": account.username,
			"display_name": account.display_name,
			"avatar_url": account.avatar_url,
			"lang_tag": account.lang_tag,
			"location": account.location,
			"timezone": account.timezone,
			"metadata": account.metadata,
			"facebook_id": account.facebook_id,
			"google_id": account.google_id,
			"gamecenter_id": account.gamecenter_id,
			"steam_id": account.steam_id,
			"online": account.online,
			"edge_count": account.edge_count,
			"create_time": account.create_time,
			"update_time": account.update_time
		}
	}

# Вызов RPC функции
func rpc(id: String, payload: String = "") -> Dictionary:
	if not session:
		printerr("Нет активной сессии для RPC вызова")
		return {}
	
	var result = await client.rpc_func(session, id, payload)
	if result.is_exception():
		printerr("Ошибка RPC вызова: ", result.get_exception().message)
		return {}
	
	var rpc_response = result.get()
	return {
		"payload": rpc_response.payload,
		"response": rpc_response
	}

# Создать сокетное соединение
func create_socket_connection():
	var NakamaSocket = load("res://addons/com.heroiclabs.nakama/socket/NakamaSocket.gd")
	return NakamaSocket.new(client.http_adapter.base_url.replace("http", "ws"), session.token)

# Проверка валидности сессии
func is_session_valid() -> bool:
	return session != null and not session.is_expired()

# Обновление сессии
func refresh_session():
	if not session or not session.can_refresh():
		printerr("Сессия не может быть обновлена")
		return
	
	var result = await client.session_refresh(session)
	if result.is_exception():
		printerr("Ошибка обновления сессии: ", result.get_exception().message)
		return
	
	session = result.get()
	session_updated.emit({
		"token": session.token,
		"refresh_token": session.refresh_token,
		"user_id": session.user_id,
		"username": session.username
	})

# Отключение
func disconnect():
	session = null
	disconnected.emit()