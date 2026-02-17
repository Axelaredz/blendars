extends Control

# Health Check - простейшая проверка соединения с Nakama сервером
# Использует глобальный Nakama autoload

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var connect_button: Button = $VBoxContainer/ConnectButton
@onready var log_label: Label = $VBoxContainer/LogLabel

var _log_text: String = ""
var _client: NakamaClient
var _session: NakamaSession

# Настройки подключения
const SERVER_KEY = "wJRUntLkLN12ccYGqNYBn69irzaTTZii44HmGn1lt40="
const HOST = "45.150.9.103"
const PORT = 7350
const SCHEME = "http"

func _ready():
	_log("HealthCheck сцена готова")
	_log("Нажмите кнопку для проверки соединения")
	connect_button.pressed.connect(_on_connect_pressed)

func _log(msg: String):
	_log_text += msg + "\n"
	log_label.text = _log_text
	print("[HealthCheck] " + msg)

func _on_connect_pressed():
	connect_button.disabled = true
	_connect_to_server()

func _connect_to_server():
	_log("=" .repeat(20))
	_log("Подключение к " + SCHEME + "://" + HOST + ":" + str(PORT))
	_log("Server Key: " + SERVER_KEY)
	
	# Используем глобальный Nakama autoload
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME, 10)
	
	_log("Клиент создан, пробуем анонимную аутентификацию...")
	
	# Пробуем анонимную аутентификацию для проверки доступности
	var device_id = OS.get_unique_id()
	_authenticate_device(device_id)

func _authenticate_device(p_device_id: String):
	_log("Аутентификация с device_id: " + p_device_id)
	
	var session = await _client.authenticate_device_async(p_device_id, "", true)
	_on_auth_completed(session)

func _on_auth_completed(p_session: NakamaSession):
	_session = p_session
	
	if _session.is_exception():
		var err = _session.get_exception()
		_log("ОШИБКА: " + err.message)
		_log("Код ошибки: " + str(err.code))
		_log("Это обычно означает, что сервер недоступен или неправильный server key")
		status_label.text = "❌ Сервер недоступен"
		status_label.modulate = Color.RED
	else:
		_log("УСПЕХ! Сессия создана")
		_log("Token: " + _session.token.left(50) + "...")
		status_label.text = "✅ Сервер доступен!"
		status_label.modulate = Color.GREEN
		
		# Делаем простой RPC вызов для проверки
		_test_rpc()

func _test_rpc():
	_log("Тестируем RPC вызов...")
	
	var result = await _client.rpc_async(_session, "health", null)
	_on_rpc_completed(result)

func _on_rpc_completed(result):
	if result and typeof(result) == TYPE_DICTIONARY:
		_log("RPC ответ: " + JSON.stringify(result))
		status_label.text = "✅ Сервер работает!"
		status_label.modulate = Color.GREEN
	elif result is NakamaException:
		_log("RPC ошибка: " + result.message)
		status_label.text = "⚠️ Соединение есть, но RPC недоступен"
		status_label.modulate = Color.YELLOW
	else:
		_log("RPC результат: " + str(result))
		status_label.text = "✅ Сервер работает!"
		status_label.modulate = Color.GREEN
	
	connect_button.disabled = false
