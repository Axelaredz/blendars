extends Node3D

@export var rotation_speed: float = 0.15

@onready var platform: Node3D = $Platform
@onready var play_button: Button = $UI/MenuPanel/VBox/PlayButton
@onready var settings_button: Button = $UI/MenuPanel/VBox/SettingsButton
@onready var quit_button: Button = $UI/MenuPanel/VBox/QuitButton
@onready var title_label: Label = $UI/TitleLabel
@onready var menu_panel: PanelContainer = $UI/MenuPanel

var buttons: Array[Button]

func _ready() -> void:
	# Загружаем шрифты с кириллицей
	var _font_semibold_italic = load("res://client/ui/fonts/Exo2-SemiBoldItalic.woff2")
	var _font_bold_italic = load("res://client/ui/fonts/Exo2-BoldItalic.woff2")
	
	buttons = [play_button, settings_button, quit_button]
	
	# Применяем шрифты - кнопки: SemiBold Italic (500), заголовок: Bold Italic (700)
	for btn in buttons:
		btn.add_theme_font_override("font", _font_semibold_italic)
	
	title_label.add_theme_font_override("font", _font_bold_italic)
	
	# Подключаем кнопки
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Анимация появления
	_animate_entrance()

func _process(delta: float) -> void:
	if platform:
		platform.rotate_y(rotation_speed * delta)

func _animate_entrance() -> void:
	title_label.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.4).set_delay(0.3)
	
	for i in buttons.size():
		buttons[i].modulate.a = 0.0
		tween.tween_property(buttons[i], "modulate:a", 1.0, 0.3).set_delay(0.5 + i * 0.15)

func _on_play_pressed() -> void:
	print("Переход на AuthScreen (скоро)")

func _on_settings_pressed() -> void:
	print("Переход на SettingsScreen (скоро)")

func _on_quit_pressed() -> void:
	get_tree().quit()
