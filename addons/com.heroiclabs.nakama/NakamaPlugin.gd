@tool
extends EditorPlugin

func _enter_tree():
	# Инициализация плагина
	add_autoload_singleton("Nakama", "res://addons/com.heroiclabs.nakama/Nakama.gd")

func _exit_tree():
	# Очистка при отключении плагина
	remove_autoload_singleton("Nakama")