@tool
extends Control

@onready var status_label = $VBoxContainer/StatusLabel
@onready var vk_auth_button = $VBoxContainer/VKAuthButton
@onready var vk_token_input = $VBoxContainer/VKTokenInput

var auth_manager

func _ready():
	auth_manager = get_node("/root/AuthManager")
	auth_manager.authentication_success.connect(_on_authentication_success)
	auth_manager.authentication_failed.connect(_on_authentication_failed)
	
	vk_auth_button.pressed.connect(_on_vk_auth_pressed)

func _on_vk_auth_pressed():
	var vk_token = vk_token_input.text
	if vk_token.is_empty():
		status_label.text = "Please enter VK access token"
		return
	
	status_label.text = "Attempting VK authentication..."
	
	# Пытаемся аутентифицироваться через VK
	var success = await auth_manager.authenticate_vk(vk_token)
	if not success:
		status_label.text = "VK authentication failed"

func _on_authentication_success(session):
	status_label.text = "VK authentication successful!"
	print("User authenticated via VK with session: ", session.token)

func _on_authentication_failed(error_msg):
	status_label.text = "VK authentication failed: " + str(error_msg)
	print("VK authentication error: ", error_msg)