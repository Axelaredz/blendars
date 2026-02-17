extends Control

# RPC Test - проверка работы RPC вызовов на Nakama сервере
# Использует глобальный Nakama autoload

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var test_button: Button = $VBoxContainer/TestButton
@onready var log_label: Label = $VBoxContainer/LogLabel
@onready var rpc_id_input: LineEdit = $VBoxContainer/HBoxContainer/RPCIdInput

var _log_text: String = ""
var _client: NakamaClient
var _session: NakamaSession
var _connected: bool = false

# Настройки подключения
const SERVER_KEY = "wJRUntLkLN12ccYGqNYBn69irzaTTZii44HmGn1lt40="
const HOST = "45.150.9.103"
const PORT = 7350
const SCHEME = "http"

func _ready():
	_log("RPC Test сцена готова")
	_log("Нажмите кнопку для подключения и тестирования RPC")
	rpc_id_input.text = "health"
	test_button.pressed.connect(_on_test_pressed)

func _log(msg: String):
	_log_text += msg + "\n"
	log_label.text = _log_text
	print("[RPCTest] " + msg)

func _on_test_pressed():
	if not _connected:
		_connect_to_server()
	else:
		_call_rpc()

func _connect_to_server():
	test_button.disabled = true
	test_button.text = "Подключение..."
	
	_log("=" .repeat(20))
	_log("Подключение к " + SCHEME + "://" + HOST + ":" + str(PORT))
	
	# Используем глобальный Nakama autoload
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME, 10)
	
	_log("Клиент создан, аутентификация...")
	
	# Анонимная аутентификация
	var device_id = OS.get_unique_id()
	_session = await _client.authenticate_device_async(device_id, "", true)
	_on_auth_completed()

func _on_auth_completed():
	if _session.is_exception():
		var err = _session.get_exception()
		_log("ОШИБКА аутентификации: " + err.message)
		_log("Код ошибки: " + str(err.code))
		status_label.text = "❌ Ошибка подключения"
		status_label.modulate = Color.RED
		test_button.disabled = false
		test_button.text = "Повторить"
	else:
		_log("УСПЕХ! Подключено")
		_log("Token: " + _session.token.left(30) + "...")
		_connected = true
		status_label.text = "✅ Подключено - нажмите 'Тест RPC'"
		status_label.modulate = Color.GREEN
		test_button.text = "Вызвать RPC"
		test_button.disabled = false
		
		# Автоматически вызываем RPC если указан
		if rpc_id_input.text.length() > 0:
			_call_rpc()

func _call_rpc():
	var rpc_id = rpc_id_input.text.strip_edges()
	if rpc_id.is_empty():
		rpc_id = "health"
		rpc_id_input.text = rpc_id
	
	_log("-" .repeat(20))
	_log("Вызов RPC: " + rpc_id)
	test_button.disabled = true
	test_button.text = "Вызов..."
	
	var payload = null
	# Можно добавить тестовый payload если нужно
	# payload = JSON.stringify({"test": "data"})
	
	var result = await _client.rpc_async(_session, rpc_id, payload)
	_on_rpc_completed(result)

func _on_rpc_completed(result):
	test_button.disabled = false
	test_button.text = "Вызвать RPC"
	
	if result == null:
		_log("ПУСТОЙ ответ (null)")
		status_label.text = "⚠️ Пустой ответ от RPC"
		status_label.modulate = Color.YELLOW
	elif typeof(result) == TYPE_DICTIONARY:
		_log("Словарь (успех?): " + JSON.stringify(result))
		
		# Проверяем есть ли данные
		if result.has("payload"):
			var payload = result["payload"]
			_log("Payload: " + str(payload))
			status_label.text = "✅ RPC работает! Ответ: " + str(payload)
			status_label.modulate = Color.GREEN
		elif result.has("error"):
			_log("Ошибка в ответе: " + str(result["error"]))
			status_label.text = "❌ Ошибка RPC: " + str(result["error"])
			status_label.modulate = Color.RED
		else:
			_log("Ответ: " + JSON.stringify(result))
			status_label.text = "✅ RPC вызов выполнен"
			status_label.modulate = Color.GREEN
	elif result is NakamaException:
		_log("Исключение Nakama: " + result.message)
		_log("Код: " + str(result.code))
		status_label.text = "❌ Ошибка: " + result.message
		status_label.modulate = Color.RED
	else:
		_log("Тип результата: " + str(typeof(result)))
		_log("Результат: " + str(result))
		status_label.text = "✅ RPC выполнен"
		status_label.modulate = Color.GREEN
