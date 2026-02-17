extends Node

signal match_found(match_info)
signal match_search_started
signal match_search_stopped
signal match_error(error_message)

var nakama_client
var matchmaker_ticket: String = ""
var is_searching: bool = false

# Параметры матчмейкинга
const DEFAULT_MIN_PLAYERS = 2
const DEFAULT_MAX_PLAYERS = 4
const DEFAULT_MATCH_PROPERTIES = {
	"game_mode": "sandbox",
	"region": "EU",
	"ranked": "false"
}

func _ready():
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager:
		nakama_client = network_manager.nakama_client

# Начать поиск матча с заданными параметрами
func start_matchmaking(
	min_players: int = DEFAULT_MIN_PLAYERS, 
	max_players: int = DEFAULT_MAX_PLAYERS, 
	properties: Dictionary = DEFAULT_MATCH_PROPERTIES
) -> bool:
	if not nakama_client:
		match_error.emit("Nakama client not initialized")
		return false
	
	if is_searching:
		match_error.emit("Already searching for a match")
		return false
	
	is_searching = true
	match_search_started.emit()
	
	# Подписываемся на события матчмейкинга
	nakama_client.matchmaker_matched.connect(_on_matchmaker_matched)
	
	# Запускаем поиск матча
	var response = await nakama_client.add_matchmaker(
		min_players,
		max_players,
		properties,
		[],  # query - пустой для простого поиска
		100  # max_attempts
	)
	
	if response.is_exception():
		is_searching = false
		match_search_stopped.emit()
		match_error.emit("Failed to start matchmaking: " + response.exception.message)
		return false
	
	matchmaker_ticket = response.ticket
	print("Matchmaking started with ticket: ", matchmaker_ticket)
	
	return true

# Остановить поиск матча
func stop_matchmaking() -> bool:
	if not nakama_client or not is_searching or matchmaker_ticket.is_empty():
		match_error.emit("Not currently searching for a match")
		return false
	
	var response = await nakama_client.remove_matchmaker(matchmaker_ticket)
	if response.is_exception():
		match_error.emit("Failed to stop matchmaking: " + response.exception.message)
		return false
	
	is_searching = false
	matchmaker_ticket = ""
	match_search_stopped.emit()
	
	return true

# Обработка события найденного матча
func _on_matchmaker_matched(matchmaker_matched):
	if not is_searching:
		return
	
	is_searching = false
	matchmaker_ticket = ""
	
	# Создаем информацию о найденном матче
	var match_info = {
		"match_id": matchmaker_matched.match_id,
		"token": matchmaker_matched.token,
		"host": matchmaker_matched.authoritative,
		"self": matchmaker_matched.self,
		"users": matchmaker_matched.users,
		"properties": matchmaker_matched.string_properties
	}
	
	match_found.emit(match_info)

# Создать прямое приглашение в матч (например, из лобби)
func create_direct_match(user_ids: Array, match_properties: Dictionary = DEFAULT_MATCH_PROPERTIES) -> bool:
	if not nakama_client:
		match_error.emit("Nakama client not initialized")
		return false
	
	# Для прямого матча создаем RPC вызов на сервере
	# который создаст матч и пригласит указанных пользователей
	var rpc_payload = {
		"user_ids": user_ids,
		"properties": match_properties
	}
	
	var response = await nakama_client.rpc("create_direct_match", JSON.stringify(rpc_payload))
	if response.is_exception():
		match_error.emit("Failed to create direct match: " + response.exception.message)
		return false
	
	var result = JSON.parse_string(response.payload)
	if result and result.has("match_info"):
		match_found.emit(result.match_info)
		return true
	else:
		match_error.emit("Invalid response from server")
		return false

# Присоединиться к существующему матчу
func join_match(match_id: String, match_token: String = "") -> bool:
	if not nakama_client:
		match_error.emit("Nakama client not initialized")
		return false
	
	# Используем сокет для присоединения к матчу
	var socket = get_node("/root/NetworkManager").nakama_socket
	if not socket:
		match_error.emit("Socket not initialized")
		return false
	
	# Присоединяемся к матчу
	var join_response = await socket.join_match_by_id(match_id, match_token)
	if join_response.is_exception():
		match_error.emit("Failed to join match: " + join_response.exception.message)
		return false
	
	var match_info = {
		"match_id": join_response.match_id,
		"self": join_response.self,
		"presence": join_response.presence,
		"label": join_response.label,
		"size": join_response.size,
		"authoritative": join_response.authoritative
	}
	
	match_found.emit(match_info)
	return true

# Отправить сообщение в матч
func send_match_message(match_id: String, op_code: int, data: Dictionary) -> bool:
	if not nakama_client:
		match_error.emit("Nakama client not initialized")
		return false
	
	var socket = get_node("/root/NetworkManager").nakama_socket
	if not socket:
		match_error.emit("Socket not initialized")
		return false
	
	var message_data = JSON.stringify(data)
	var response = await socket.send_match_state(match_id, op_code, message_data)
	if response.is_exception():
		match_error.emit("Failed to send match message: " + response.exception.message)
		return false
	
	return true

# Получить список активных матчей (для отладки)
func list_active_matches() -> Array:
	if not nakama_client:
		match_error.emit("Nakama client not initialized")
		return []
	
	# В Nakama нет прямого способа получить список всех активных матчей
	# Это обычно делается через серверную логику или RPC вызовы
	var response = await nakama_client.rpc("list_active_matches", "{}")
	if response.is_exception():
		match_error.emit("Failed to list active matches: " + response.exception.message)
		return []
	
	var result = JSON.parse_string(response.payload)
	return result.matches if result and result.has("matches") else []

# Метод для проверки статуса поиска
func get_matchmaking_status() -> Dictionary:
	return {
		"is_searching": is_searching,
		"ticket": matchmaker_ticket,
		"current_players": 0  # Будет обновляться при получении информации о матче
	}