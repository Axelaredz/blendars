# Менеджер лобби для управления сетевыми играми
extends Node

# Сигналы для уведомления других частей игры о событиях в лобби
signal lobby_created(lobby_info)  # Лобби создано
signal lobby_joined(lobby_info)   # Игрок присоединился к лобби
signal lobby_left(lobby_id)       # Игрок покинул лобби
signal player_joined_lobby(lobby_id, user_id, username)  # Игрок вошёл в лобби
signal player_left_lobby(lobby_id, user_id)             # Игрок вышел из лобби
signal lobby_list_updated(lobby_list)                   # Список доступных лобби обновлён
signal error_occurred(message)                          # Произошла ошибка

# Клиент Nakama для взаимодействия с сервером
var nakama_client
# ID текущего лобби
var current_lobby_id: String = ""
# Информация о текущем лобби
var current_lobby_info: Dictionary = {}

# Константы для настроек лобби
const LOBBY_NAME_MAX_LENGTH = 32  # Максимальная длина имени лобби
const MAX_LOBBY_SIZE = 8          # Максимальное количество игроков в лобби
const LOBBY_ROOM_LABEL = "lobby"  # Метка для комнаты лобби

# Инициализация менеджера лобби
func _ready():
	# Получаем ссылку на NetworkManager для доступа к Nakama клиенту
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager:
		nakama_client = network_manager.nakama_client

# Создание нового лобби
# lobby_name - имя лобби
# max_players - максимальное количество игроков (по умолчанию 4)
# is_private - является ли лобби приватным (по умолчанию false)
func create_lobby(lobby_name: String, max_players: int = 4, is_private: bool = false) -> bool:
	# Проверяем, инициализирован ли клиент Nakama
	if not nakama_client:
		error_occurred.emit("Nakama клиент не инициализирован")
		return false

	# Проверяем корректность имени лобби
	if lobby_name.length() == 0 or lobby_name.length() > LOBBY_NAME_MAX_LENGTH:
		error_occurred.emit("Имя лобби должно быть от 1 до %d символов" % LOBBY_NAME_MAX_LENGTH)
		return false

	# Проверяем корректность максимального количества игроков
	if max_players < 2 or max_players > MAX_LOBBY_SIZE:
		error_occurred.emit("Максимальное количество игроков должно быть от 2 до %d" % MAX_LOBBY_SIZE)
		return false

	# Создаем мета-данные для лобби
	var lobby_metadata = {
		"name": lobby_name,         # Имя лобби
		"max_players": max_players, # Максимальное количество игроков
		"is_private": is_private,   # Приватный ли лобби
		"created_by": get_current_user_id(),  # ID создателя
		"game_mode": "sandbox"      # Режим игры для матчемейкинга
	}

	# Создаем группу для лобби (в Nakama группы используются для управления доступом)
	var response = await nakama_client.create_group(
		lobby_name,        # Имя группы
		"",                # Описание (пустое)
		"",                # URL аватара (пустой)
		max_players,       # Максимальное количество участников
		not is_private,    # Открытый (если не приватный)
		lobby_metadata     # Метаданные
	)

	if response.is_exception():
		error_occurred.emit("Не удалось создать лобби: " + response.exception.message)
		return false

	var lobby_group = response

	# Присоединяем создателя к лобби
	var join_response = await nakama_client.join_group(lobby_group.id)
	if join_response.is_exception():
		error_occurred.emit("Не удалось присоединиться к созданному лобби: " + join_response.exception.message)
		return false

	# Сохраняем информацию о текущем лобби
	current_lobby_id = lobby_group.id
	current_lobby_info = {
		"id": lobby_group.id,                    # ID лобби
		"name": lobby_name,                      # Имя лобби
		"max_players": max_players,              # Максимальное количество игроков
		"is_private": is_private,                # Приватный ли лобби
		"players": [get_current_user_id()],      # Список игроков (создатель)
		"created_by": get_current_user_id()      # ID создателя
	}

	# Вызываем сигнал о создании лобби
	lobby_created.emit(current_lobby_info)
	
	# Обновляем список игроков, чтобы отследить создателя как первого игрока
	await _update_lobby_players()
	
	return true

# Присоединение к лобби по ID
# lobby_id - ID лобби, к которому нужно присоединиться
func join_lobby(lobby_id: String) -> bool:
	# Проверяем, инициализирован ли клиент Nakama
	if not nakama_client:
		error_occurred.emit("Nakama клиент не инициализирован")
		return false

	# Проверяем, что ID лобби не пустой
	if lobby_id.is_empty():
		error_occurred.emit("ID лобби не может быть пустым")
		return false

	# Присоединяемся к группе лобби
	var response = await nakama_client.join_group(lobby_id)
	if response.is_exception():
		error_occurred.emit("Не удалось присоединиться к лобби: " + response.exception.message)
		return false

	# Получаем информацию о лобби
	var lobby_info_response = await nakama_client.get_group(lobby_id)
	if lobby_info_response.is_exception():
		error_occurred.emit("Не удалось получить информацию о лобби: " + lobby_info_response.exception.message)
		return false

	var lobby_info = lobby_info_response

	# Сохраняем информацию о текущем лобби
	current_lobby_id = lobby_id
	current_lobby_info = {
		"id": lobby_info.id,                 # ID лобби
		"name": lobby_info.name,             # Имя лобби
		"max_players": lobby_info.max_count, # Максимальное количество игроков
		"is_private": not lobby_info.open,   # Приватный ли лобби
		"players": [],                       # Список игроков (будет обновлен позже)
		"created_by": lobby_info.creator_id # ID создателя лобби
	}

	# Получаем список участников
	await _update_lobby_players()

	# Вызываем сигнал о присоединении к лобби
	lobby_joined.emit(current_lobby_info)
	
	return true

# Покидание текущего лобби
func leave_lobby() -> bool:
	# Проверяем, инициализирован ли клиент Nakama и есть ли текущий лобби
	if not nakama_client or current_lobby_id.is_empty():
		error_occurred.emit("Нет подключения к лобби или Nakama клиент не инициализирован")
		return false

	# Получаем ID текущего пользователя перед тем, как покинуть лобби
	var current_user_id = get_current_user_id()

	# Покидаем группу лобби
	var response = await nakama_client.leave_group(current_lobby_id)
	if response.is_exception():
		error_occurred.emit("Не удалось покинуть лобби: " + response.exception.message)
		return false

	# Вызываем сигнал о покидании лобби
	lobby_left.emit(current_lobby_id)

	# Вызываем сигнал о том, что игрок покинул лобби
	player_left_lobby.emit(current_lobby_id, current_user_id)

	# Сбрасываем информацию о текущем лобби
	current_lobby_id = ""
	current_lobby_info = {}

	return true

# Получение списка доступных лобби
# filters - фильтры для поиска лобби (необязательный параметр)
func get_available_lobbies(filters: Dictionary = {}) -> Array:
	# Проверяем, инициализирован ли клиент Nakama
	if not nakama_client:
		error_occurred.emit("Nakama клиент не инициализирован")
		return []

	# По умолчанию ищем открытые лобби
	var limit: int = filters.get("limit", 100)        # Ограничение на количество результатов
	var name_filter: String = filters.get("name", "") # Фильтр по имени
	var lang_filter: String = filters.get("lang", "") # Фильтр по языку
	var members: int = filters.get("members", 0)      # Минимальное количество участников

	# Запрашиваем список групп (лобби) с сервера
	var response = await nakama_client.list_groups(name_filter, limit, lang_filter, members)
	if response.is_exception():
		error_occurred.emit("Не удалось получить список лобби: " + response.exception.message)
		return []

	# Формируем список доступных лобби
	var available_lobbies = []
	for group in response.groups:
		# Пропускаем приватные лобби
		if not group.open:
			continue

		# Создаем информацию о лобби
		var lobby_info = {
			"id": group.id,              # ID лобби
			"name": group.name,          # Имя лобби
			"max_players": group.max_count,      # Максимальное количество игроков
			"current_players": group.edge_count, # Текущее количество игроков
			"created_by": group.creator_id       # ID создателя
		}
		available_lobbies.append(lobby_info)

	# Вызываем сигнал об обновлении списка лобби
	lobby_list_updated.emit(available_lobbies)
	return available_lobbies

# Приглашение игрока в лобби
# user_id - ID пользователя, которого нужно пригласить
func invite_player_to_lobby(user_id: String) -> bool:
	# Проверяем, инициализирован ли клиент Nakama и есть ли текущий лобби
	if not nakama_client or current_lobby_id.is_empty():
		error_occurred.emit("Нет подключения к лобби или Nakama клиент не инициализирован")
		return false

	# Добавляем пользователя в группу лобби
	var response = await nakama_client.add_group_users(current_lobby_id, [user_id])
	if response.is_exception():
		error_occurred.emit("Не удалось пригласить игрока: " + response.exception.message)
		return false

	# Отправляем уведомление приглашенному игроку (опционально)
	var _notification_content = {
		"type": "lobby_invite",      # Тип уведомления
		"lobby_id": current_lobby_id, # ID лобби
		"inviter": get_current_user_id() # ID пригласившего
	}

	# Отправка уведомлений требует асинхронного вызова, что может вызвать проблемы в автозагрузке
	# Пока отключим эту функцию
	# var notification_response = await nakama_client.send_notification(
	# 	[user_id],
	# 	"Вас пригласили в лобби!",
	# 	1,  // код уведомления
	# 	_notification_content,
	# 	30  // постоянное уведомление
	# )
	#
	# if notification_response.is_exception():
	# 	print("Предупреждение: Не удалось отправить уведомление о приглашении: " + notification_response.exception.message)

	return true

# Получение текущего имени пользователя
func get_current_username() -> String:
	var auth_manager = get_node_or_null("/root/AuthManager")
	if auth_manager and auth_manager.session:
		return auth_manager.session.username if auth_manager.session.has("username") else "Unknown"
	return "Unknown"

# Получение текущего ID пользователя
func get_current_user_id() -> String:
	# Получаем ссылку на AuthManager для доступа к сессии
	var auth_manager = get_node_or_null("/root/AuthManager")
	if auth_manager and auth_manager.session:
		return auth_manager.session.user_id
	return ""

# Обновление списка игроков в лобби
func _update_lobby_players():
	# Проверяем, есть ли текущий ID лобби
	if current_lobby_id.is_empty():
		return

	# Сохраняем старый список игроков для сравнения
	var old_player_list = current_lobby_info.players.duplicate() if current_lobby_info.has("players") else []

	# Получаем список пользователей в группе лобби
	var response = await nakama_client.list_group_users(current_lobby_id, "asc", 100)
	if response.is_exception():
		print("Не удалось получить список игроков в лобби: " + response.exception.message)
		return

	# Формируем список ID игроков
	var player_ids = []
	for user_group in response.users:
		player_ids.append(user_group.user.id)

	# Обновляем список игроков в информации о лобби
	current_lobby_info.players = player_ids

	# Проверяем, кто присоединился и кто покинул лобби
	_check_player_changes(old_player_list, player_ids)

# Проверка изменений в составе игроков
func _check_player_changes(old_list: Array, new_list: Array):
	# Проверяем, кто покинул лобби
	for old_player in old_list:
		if not new_list.has(old_player):
			# Вызываем сигнал о том, что игрок покинул лобби
			player_left_lobby.emit(current_lobby_id, old_player)

	# Проверяем, кто присоединился к лобби
	for new_player in new_list:
		if not old_list.has(new_player):
			# Вызываем сигнал о том, что игрок присоединился к лобби
			# Получаем имя пользователя для передачи в сигнал
			var username = _get_username_by_id(new_player)
			player_joined_lobby.emit(current_lobby_id, new_player, username)

# Получение имени пользователя по ID
func _get_username_by_id(user_id: String) -> String:
	# В реальности этот метод должен запрашивать имя пользователя с сервера
	# или иметь доступ к кэшированной информации о пользователях
	# Пока возвращаем просто ID, в реальном приложении нужно получать настоящее имя
	return user_id

# Отправка сообщения в лобби (для чата или синхронизации состояния)
# _content - содержимое сообщения (временно не используется)
# _sender_username - имя отправителя (по умолчанию пустая строка, временно не используется)
func send_lobby_message(_content: String, _sender_username: String = ""):
	# Проверяем, инициализирован ли клиент Nakama и есть ли текущий лобби
	if not nakama_client or current_lobby_id.is_empty():
		error_occurred.emit("Невозможно отправить сообщение: нет подключения к лобби или Nakama клиент не инициализирован")
		return false

	# Для чата в лобби можно использовать групповые сообщения
	# Временно закомментируем эту функцию, так как она может вызывать проблемы
	# var response = await nakama_client.join_chat(current_lobby_id, 2, false, false)  # 2 = GROUP chat type
	# if response.is_exception():
	# 	error_occurred.emit("Не удалось присоединиться к чату лобби: " + response.exception.message)
	# 	return false

	# var chat_socket = nakama_client.create_socket()
	# var chat_join_response = await chat_socket.join_chat(response.id)
	# if chat_join_response.is_exception():
	# 	error_occurred.emit("Не удалось присоединиться к чату: " + chat_join_response.exception.message)
	# 	return false

	# # Отправляем сообщение
	# var message_response = await chat_socket.send_chat_message(chat_join_response.id, _content)
	# if message_response.is_exception():
	# 	error_occurred.emit("Не удалось отправить сообщение: " + message_response.exception.message)
	# 	return false

	# return true
	error_occurred.emit("Функция чата временно отключена из-за проблем с инициализацией")
	return false

# Начало игры (переход из лобби в игровую сессию)
func start_game():
	# Проверяем, инициализирован ли клиент Nakama и есть ли текущий лобби
	if not nakama_client or current_lobby_id.is_empty():
		error_occurred.emit("Невозможно начать игру: нет подключения к лобби или Nakama клиент не инициализирован")
		return false

	# Проверяем, достаточно ли игроков для начала игры
	if current_lobby_info.players.size() < 2:
		error_occurred.emit("Для начала игры требуется как минимум 2 игрока")
		return false

	# Здесь будет логика создания игровой сессии
	# В реальной игре это может быть создание комнаты через Nakama Matchmaker
	# или передача данных о лобби в игровой сервер

	var game_start_data = {
		"lobby_id": current_lobby_id,      # ID лобби
		"players": current_lobby_info.players,  # Список игроков
		"game_mode": "sandbox",            # Режим игры
		"map": "default_map"               # Карта для игры
	}

	# Возвращаем данные для начала игры
	# В реальной реализации здесь будет создание match или передача в игровой сервер
	return game_start_data
