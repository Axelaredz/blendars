extends Node

# Система матчмейкинга - управляет подбором игроков в игры
# Использует Nakama's built-in matchmaker functionality

signal match_found(match_id: String, match_info: Dictionary)
signal match_search_started
signal match_search_stopped
signal match_search_error(error_message: String)

var network_manager = null
var is_searching = false
var current_ticket: String = ""

func _ready():
	network_manager = get_node("/root/NetworkManager")
	if not network_manager:
		push_error("NetworkManager не найден!")
		return

# Начать поиск матча с заданными параметрами
func start_matchmaking(properties: Dictionary, min_players: int = 2, max_players: int = 4) -> bool:
	if is_searching:
		print("Поиск уже запущен")
		return false
	
	if not network_manager or not network_manager.is_connected:
		match_search_error.emit("Нет подключения к серверу")
		return false
	
	# Подготавливаем параметры для матчмейкинга
	var matchmaker_properties = {}
	
	# Преобразуем свойства в строковые значения, как того требует Nakama
	for key in properties:
		matchmaker_properties[key] = str(properties[key])
	
	var matchmaker_query = "+properties.game_mode:" + matchmaker_properties.get("game_mode", "*")
	
	# Добавляем дополнительные параметры к запросу
	if matchmaker_properties.has("region"):
		matchmaker_query += " +properties.region:" + matchmaker_properties.region
	
	if matchmaker_properties.has("skill_level"):
		# Для скилла используем диапазонный поиск
		var skill = int(matchmaker_properties.skill_level)
		matchmaker_query += " +properties.skill_level:>" + str(skill - 50) + " +properties.skill_level:<" + str(skill + 50)
	
	# Отправляем запрос на матчмейкинг
	var result = await network_manager.nakama_client.rpc("matchmaker_add", {
		"query": matchmaker_query,
		"min_count": min_players,
		"max_count": max_players,
		"string_properties": matchmaker_properties
	}.to_json())
	
	if result == null or not result.has("ticket"):
		match_search_error.emit("Не удалось начать поиск матча")
		return false
	
	current_ticket = result.ticket
	is_searching = true
	match_search_started.emit()
	
	print("Начат поиск матча с билетом: ", current_ticket)
	
	# Запускаем таймер для проверки состояния поиска
	await _check_matchmaking_status()
	
	return true

# Остановить текущий поиск матча
func stop_matchmaking() -> bool:
	if not is_searching or current_ticket.is_empty():
		print("Нет активного поиска для остановки")
		return false
	
	if not network_manager or not network_manager.is_connected:
		match_search_error.emit("Нет подключения к серверу")
		return false
	
	var result = await network_manager.nakama_client.rpc("matchmaker_remove", {
		"ticket": current_ticket
	}.to_json())
	
	if result == null:
		match_search_error.emit("Не удалось остановить поиск матча")
		return false
	
	current_ticket = ""
	is_searching = false
	match_search_stopped.emit()
	
	print("Поиск матча остановлен")
	return true

# Проверяет статус поиска матча
func _check_matchmaking_status():
	while is_searching:
		# В реальной реализации здесь будет проверка статуса через RPC или сокет
		# Nakama автоматически уведомляет о найденном матче через сокет
		await get_tree().create_timer(1.0).timeout

# Обработчик события найденного матча (вызывается из NetworkManager)
func handle_match_found(match_data: Dictionary):
	if not is_searching:
		return
	
	is_searching = false
	current_ticket = ""
	
	match_found.emit(match_data.match_id, match_data)
	
	print("Найден матч: ", match_data.match_id)

# Пример использования системы матчмейкинга
func example_usage():
	# Начинаем поиск матча с определенными параметрами
	var search_params = {
		"game_mode": "coop",
		"region": "eu",
		"skill_level": 1000,
		"team_size": 2
	}
	
	var success = await start_matchmaking(search_params, 2, 4)
	if success:
		print("Поиск матча запущен успешно")
	else:
		print("Ошибка запуска поиска матча")