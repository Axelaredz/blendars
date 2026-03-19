extends Control

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var connect_button: Button = $VBoxContainer/ConnectButton
@onready var join_match_button: Button = $VBoxContainer/JoinMatchButton
@onready var send_data_button: Button = $VBoxContainer/SendDataButton
@onready var disconnect_button: Button = $VBoxContainer/DisconnectButton
@onready var log_text: RichTextLabel = $VBoxContainer/LogText

var match_id: String = ""

func _ready():
	# Connect to NetworkManager signals
	NetworkManager.connected.connect(_on_connected)
	NetworkManager.disconnected.connect(_on_disconnected)
	NetworkManager.socket_ready.connect(_on_socket_ready)
	NetworkManager.socket_closed.connect(_on_socket_closed)
	NetworkManager.match_state_updated.connect(_on_match_state_updated)
	
	update_ui()
	log_message("NetworkManager готов к тестированию")

func update_ui():
	if NetworkManager.session:
		status_label.text = "Статус: Аутентифицирован"
		connect_button.disabled = true
		join_match_button.disabled = false
		send_data_button.disabled = false
		disconnect_button.disabled = false
	else:
		status_label.text = "Статус: Не аутентифицирован"
		connect_button.disabled = false
		join_match_button.disabled = true
		send_data_button.disabled = true
		disconnect_button.disabled = true

func log_message(message: String):
	log_text.text += "- " + message + "\n"
	log_text.scroll_to_line(log_text.get_line_count() - 1)

func _on_connected():
	log_message("Успешно подключено к серверу")
	update_ui()

func _on_disconnected():
	log_message("Отключено от сервера")
	update_ui()

func _on_socket_ready():
	log_message("Сокет подключен")
	update_ui()

func _on_socket_closed():
	log_message("Сокет закрыт")
	update_ui()

func _on_match_state_updated(op_code: int, data: Dictionary, sender_id: String):
	log_message("Получены данные матча - OP: " + str(op_code) + ", От: " + sender_id + ", Данные: " + str(data))

func _on_connect_button_pressed():
	# Попробовать аутентифицироваться
	await authenticate_and_connect()

func _on_join_match_button_pressed():
	# Присоединиться к матчу
	await join_match()

func _on_send_data_button_pressed():
	# Отправить тестовые данные
	send_test_data()

func _on_disconnect_button_pressed():
	NetworkManager.disconnect_from_server()
	log_message("Отключен от сервера")
	update_ui()

func authenticate_and_connect():
	log_message("Попытка аутентификации...")
	var success = await NetworkManager.authenticate_async()
	if success:
		log_message("Аутентификация успешна")
	else:
		log_message("Ошибка аутентификации")

func join_match():
	log_message("Попытка присоединиться к матчу...")
	var match = await NetworkManager.join_match_async(match_id)
	if match:
		match_id = match.id
		log_message("Присоединился к матчу: " + match_id)
	else:
		log_message("Ошибка присоединения к матчу")

func send_test_data():
	var test_data = {
		"player_x": randf_range(0, 100),
		"player_y": randf_range(0, 100),
		"action": "move",
		"timestamp": Time.get_ticks_msec()
	}
	
	NetworkManager.send_match_state(1, test_data)
	log_message("Отправлены тестовые данные: " + str(test_data))