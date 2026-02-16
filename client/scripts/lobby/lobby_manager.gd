extends Node

# Менеджер лобби - центральный узел для управления сессиями
# Создает RPC вызовы для создания/поиска/присоединения к лобби

signal lobby_created(lobby_id: String, lobby_info: Dictionary)
signal lobby_joined(lobby_id: String, lobby_info: Dictionary)
signal lobby_left(lobby_id: String)
signal player_joined(lobby_id: String, user_id: String, username: String)
signal player_left(lobby_id: String, user_id: String, username: String)
signal lobby_list_received(lobbies: Array)
signal invite_sent(invite_data: Dictionary)
signal error_occurred(error_message: String)

var network_manager = null
var current_lobby_id: String = ""
var current_lobby_info: Dictionary = {}

func _ready():
	network_manager = get_node("/root/NetworkManager")
	if not network_manager:
		push_error("NetworkManager не найден!")
		return

func create_lobby(lobby_name: String, max_players: int = 4, is_private: bool = false, custom_properties: Dictionary = {}) -> bool:
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var lobby_data = {
		"name": lobby_name,
		"max_players": max_players,
		"is_private": is_private,
		"custom_properties": custom_properties
	}
	
	var result = await network_manager.rpc_call("create_lobby", lobby_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось создать лобби")
		return false
	
	var lobby_info = result.payload
	current_lobby_id = lobby_info.lobby_id
	current_lobby_info = lobby_info
	
	lobby_created.emit(current_lobby_id, current_lobby_info)
	return true

func join_lobby_by_id(lobby_id: String) -> bool:
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var join_data = {
		"lobby_id": lobby_id
	}
	
	var result = await network_manager.rpc_call("join_lobby", join_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось присоединиться к лобби")
		return false
	
	var lobby_info = result.payload
	current_lobby_id = lobby_info.lobby_id
	current_lobby_info = lobby_info
	
	lobby_joined.emit(current_lobby_id, current_lobby_info)
	return true

func join_lobby_by_code(lobby_code: String) -> bool:
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var join_data = {
		"code": lobby_code
	}
	
	var result = await network_manager.rpc_call("join_lobby_by_code", join_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось присоединиться к лобби по коду")
		return false
	
	var lobby_info = result.payload
	current_lobby_id = lobby_info.lobby_id
	current_lobby_info = lobby_info
	
	lobby_joined.emit(current_lobby_id, current_lobby_info)
	return true

func leave_current_lobby() -> bool:
	if current_lobby_id.is_empty():
		error_occurred.emit("Не состою в лобби")
		return false
	
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var leave_data = {
		"lobby_id": current_lobby_id
	}
	
	var result = await network_manager.rpc_call("leave_lobby", leave_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось покинуть лобби")
		return false
	
	lobby_left.emit(current_lobby_id)
	current_lobby_id = ""
	current_lobby_info = {}
	
	return true

func search_public_lobbies(filter_params: Dictionary = {}) -> Array:
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return []
	
	var search_data = {
		"filter": filter_params
	}
	
	var result = await network_manager.rpc_call("search_lobbies", search_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось получить список лобби")
		return []
	
	var lobbies = result.payload.lobbies if result.payload.has("lobbies") else []
	lobby_list_received.emit(lobbies)
	return lobbies

func get_lobby_info(lobby_id: String) -> Dictionary:
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return {}
	
	var info_data = {
		"lobby_id": lobby_id
	}
	
	var result = await network_manager.rpc_call("get_lobby_info", info_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось получить информацию о лобби")
		return {}
	
	return result.payload

func send_invite(to_user_id: String, lobby_id: String = "") -> bool:
	var target_lobby_id = lobby_id if not lobby_id.is_empty() else current_lobby_id
	if target_lobby_id.is_empty():
		error_occurred.emit("Не указан ID лобби для приглашения")
		return false
	
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var invite_data = {
		"to_user_id": to_user_id,
		"lobby_id": target_lobby_id
	}
	
	var result = await network_manager.rpc_call("send_lobby_invite", invite_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось отправить приглашение")
		return false
	
	invite_sent.emit(result.payload)
	return true

func start_game_in_lobby(settings: Dictionary = {}) -> bool:
	if current_lobby_id.is_empty():
		error_occurred.emit("Не состою в лобби")
		return false
	
	if not network_manager or not network_manager.is_connected:
		error_occurred.emit("Нет подключения к серверу")
		return false
	
	var start_data = {
		"lobby_id": current_lobby_id,
		"settings": settings
	}
	
	var result = await network_manager.rpc_call("start_game", start_data.to_json())
	if result == null:
		error_occurred.emit("Не удалось начать игру")
		return false
	
	# Переключаемся в игровую сессию
	return true

# Обработчик входящих событий от сокета
func handle_lobby_event(event_data: Dictionary):
	match event_data.event_type:
		"player_joined":
			player_joined.emit(
				event_data.lobby_id,
				event_data.player.user_id,
				event_data.player.username
			)
		"player_left":
			player_left.emit(
				event_data.lobby_id,
				event_data.player.user_id,
				event_data.player.username
			)
		"lobby_updated":
			if event_data.lobby_id == current_lobby_id:
				current_lobby_info = event_data.lobby_info
		_:
			print("Неизвестный тип события лобби: ", event_data.event_type)