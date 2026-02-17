extends Node

signal connected
signal connection_failed(error)
signal disconnected

var nakama_client
var nakama_socket
var session

const DEFAULT_HOST := "45.150.9.103"
const DEFAULT_PORT := 7350
const DEFAULT_SERVER_KEY := "defaultkey"

func _ready():
	# Используем deferred вызов для инициализации после полной загрузки плагинов
	call_deferred("_init_nakama")

func _init_nakama():
	# Проверяем, что autoloaded Nakama singleton доступен
	if not Nakama:
		push_error("Nakama singleton not available. Make sure the plugin is enabled.")
		return

	# Создаем клиента через методы singleton
	nakama_client = Nakama.create_client(
		DEFAULT_SERVER_KEY,
		DEFAULT_HOST,
		DEFAULT_PORT,
		"http",  # scheme
		10  # timeout
	)

	if not nakama_client:
		push_error("Failed to create Nakama client")

func connect_to_server():
	if nakama_client == null:
		push_error("Nakama client not initialized")
		return false

	var response = await nakama_client.authenticate_device(OS.get_unique_id())
	if response.is_exception():
		connection_failed.emit(response.exception.message)
		return false

	session = response

	# Создаём сокетное соединение для реального времени
	nakama_socket = Nakama.create_socket_from(nakama_client)
	nakama_socket.connect("closed", Callable(self, "_on_socket_closed"))

	var socket_response = await nakama_socket.connect_async(session)
	if socket_response.is_exception():
		connection_failed.emit(socket_response.exception.message)
		return false

	connected.emit()
	return true

func _on_socket_closed():
	disconnected.emit()

func disconnect_from_server():
	if nakama_socket:
		await nakama_socket.close()
	if nakama_client:
		nakama_client = null
		session = null
