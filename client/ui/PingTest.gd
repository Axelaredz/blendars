@tool
extends Control

@onready var status_label = $VBoxContainer/StatusLabel
@onready var ping_button = $VBoxContainer/PingButton

var nakama_client

func _ready():
	var network_manager = get_node("/root/NetworkManager")
	if network_manager and network_manager.nakama_client:
		nakama_client = network_manager.nakama_client
		status_label.text = "Client initialized, ready to ping server"
	else:
		status_label.text = "ERROR: Nakama client not initialized"
	
	ping_button.pressed.connect(_on_ping_pressed)

func _on_ping_pressed():
	if not nakama_client:
		status_label.text = "Cannot ping: Nakama client not initialized"
		return
	
	status_label.text = "Pinging server..."
	
	# Простой вызов для проверки соединения
	var response = await nakama_client.healthcheck()
	if response.is_exception():
		status_label.text = "Ping failed: " + response.exception.message
	else:
		status_label.text = "Ping successful! Server is responsive."