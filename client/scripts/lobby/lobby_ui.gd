extends Control

# UI контроллер для экрана лобби
# Управляет отображением информации о лобби и взаимодействием с ним

@onready var lobby_manager = preload("res://client/scripts/lobby/lobby_manager.gd").new()

@onready var lobby_list_container: VBoxContainer = $LobbyList/ScrollContainer/VBoxContainer
@onready var lobby_info_panel: Panel = $LobbyInfo
@onready var player_list: VBoxContainer = $LobbyInfo/PlayerList/ScrollContainer/VBoxContainer
@onready var lobby_name_label: Label = $LobbyInfo/LobbyNameLabel
@onready var player_count_label: Label = $LobbyInfo/PlayerCountLabel
@onready var create_lobby_button: Button = $CreateLobbyButton
@onready var join_lobby_button: Button = $JoinLobbyButton
@onready var leave_lobby_button: Button = $LeaveLobbyButton
@onready var start_game_button: Button = $StartGameButton
@onready var lobby_code_input: LineEdit = $LobbyCodeInput

var network_manager = null

func _ready():
	network_manager = get_node("/root/NetworkManager")
	if not network_manager:
		printerr("NetworkManager не найден!")
		return
	
	# Подписываемся на события лобби
	lobby_manager.lobby_created.connect(_on_lobby_created)
	lobby_manager.lobby_joined.connect(_on_lobby_joined)
	lobby_manager.lobby_left.connect(_on_lobby_left)
	lobby_manager.player_joined.connect(_on_player_joined)
	lobby_manager.player_left.connect(_on_player_left)
	lobby_manager.lobby_list_received.connect(_on_lobby_list_received)
	lobby_manager.error_occurred.connect(_on_error_occurred)
	
	# Подписываемся на кнопки
	create_lobby_button.pressed.connect(_on_create_lobby_pressed)
	join_lobby_button.pressed.connect(_on_join_lobby_pressed)
	leave_lobby_button.pressed.connect(_on_leave_lobby_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	
	# Изначально скрываем панель информации о лобби
	lobby_info_panel.visible = false
	leave_lobby_button.visible = false
	start_game_button.visible = false

func _on_create_lobby_pressed():
	if not network_manager or not network_manager.is_connected:
		printerr("Нет подключения к серверу")
		return
	
	# Создаем лобби с параметрами по умолчанию
	var success = await lobby_manager.create_lobby("Новый лобби", 4, false, {"game_mode": "coop"})
	if not success:
		printerr("Не удалось создать лобби")

func _on_join_lobby_pressed():
	if not network_manager or not network_manager.is_connected:
		printerr("Нет подключения к серверу")
		return
	
	var code = lobby_code_input.text.strip_edges()
	if code.is_empty():
		printerr("Введите код лобби")
		return
	
	var success = await lobby_manager.join_lobby_by_code(code)
	if not success:
		printerr("Не удалось присоединиться к лобби")

func _on_leave_lobby_pressed():
	var success = await lobby_manager.leave_current_lobby()
	if not success:
		printerr("Не удалось покинуть лобби")

func _on_start_game_pressed():
	var success = await lobby_manager.start_game_in_lobby({"difficulty": "normal"})
	if not success:
		printerr("Не удалось начать игру")

func _on_lobby_created(lobby_id: String, lobby_info: Dictionary):
	print("Лобби создано: ", lobby_id)
	lobby_info_panel.visible = true
	leave_lobby_button.visible = true
	start_game_button.visible = true
	update_lobby_info(lobby_info)

func _on_lobby_joined(lobby_id: String, lobby_info: Dictionary):
	print("Присоединились к лобби: ", lobby_id)
	lobby_info_panel.visible = true
	leave_lobby_button.visible = true
	start_game_button.visible = true
	update_lobby_info(lobby_info)

func _on_lobby_left(lobby_id: String):
	print("Покинули лобби: ", lobby_id)
	lobby_info_panel.visible = false
	leave_lobby_button.visible = false
	start_game_button.visible = false
	player_list.get_children().call("queue_free")  # Очищаем список игроков

func _on_player_joined(lobby_id: String, user_id: String, username: String):
	print("Игрок присоединился: ", username)
	var player_label = Label.new()
	player_label.text = username
	player_list.add_child(player_label)

func _on_player_left(lobby_id: String, user_id: String, username: String):
	print("Игрок покинул лобби: ", username)
	# Находим и удаляем метку игрока
	for child in player_list.get_children():
		if child is Label and child.text == username:
			child.queue_free()

func _on_lobby_list_received(lobbies: Array):
	# Очищаем старый список
	lobby_list_container.get_children().call("queue_free")
	
	# Добавляем новые лобби
	for lobby in lobbies:
		var lobby_item = HBoxContainer.new()
		
		var name_label = Label.new()
		name_label.text = lobby.name
		lobby_item.add_child(name_label)
		
		var count_label = Label.new()
		count_label.text = str(lobby.current_players) + "/" + str(lobby.max_players)
		lobby_item.add_child(count_label)
		
		var join_button = Button.new()
		join_button.text = "Присоединиться"
		# Прикрепляем ID лобби к кнопке для последующего использования
		join_button.set_meta("lobby_id", lobby.lobby_id)
		join_button.pressed.connect(_on_lobby_join_button_pressed.bind(lobby.lobby_id))
		lobby_item.add_child(join_button)
		
		lobby_list_container.add_child(lobby_item)

func _on_lobby_join_button_pressed(lobby_id: String):
	var success = await lobby_manager.join_lobby_by_id(lobby_id)
	if not success:
		printerr("Не удалось присоединиться к лобби")

func _on_error_occurred(error_message: String):
	printerr("Ошибка лобби системы: ", error_message)

func update_lobby_info(lobby_info: Dictionary):
	lobby_name_label.text = lobby_info.name
	player_count_label.text = str(lobby_info.current_players) + "/" + str(lobby_info.max_players)
	
	# Очищаем старый список игроков
	player_list.get_children().call("queue_free")
	
	# Добавляем новых игроков
	if lobby_info.has("players"):
		for player in lobby_info.players:
			var player_label = Label.new()
			player_label.text = player.username
			player_list.add_child(player_label)