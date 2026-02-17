extends Node3D

## GameMenu — главное 3D-меню с overlay MainMenu UI
## Анимации: fade-in панели, пульсация куба, вращение neon bars

# Ссылки на 3D-объекты
@onready var cube: MeshInstance3D = $Cube
@onready var neon_bars: Node3D = $NeonBars
@onready var camera: Camera3D = $Camera3D

# Ссылки на UI
@onready var ui_layer: CanvasLayer = $UI
@onready var menu_panel: PanelContainer = $UI/MainMenuPanel
@onready var title_label: Label = $UI/MainMenuPanel/MarginContainer/VBox/TitleLabel
@onready var buttons_vbox: VBoxContainer = $UI/MainMenuPanel/MarginContainer/VBox/ButtonsVBox
@onready var version_label: Label = $UI/MainMenuPanel/MarginContainer/VBox/VersionLabel

# Overlay контейнер для MainMenu
@onready var main_menu_container: Control = $MainMenuOverlay/MainMenuContainer

# Параметры анимации
var rotation_speed: float = 0.5
var float_speed: float = 2.0
var float_amplitude: float = 0.15

# Таймер для анимации кнопок
var button_delay: float = 0.15

# Референс на инстанс MainMenu
var main_menu_instance: Control = null

func _ready() -> void:
	# Инициализация UI — скрываем элементы для анимации появления
	_initialize_ui_for_animation()
	
	# Подключаем сигналы кнопок
	_connect_button_signals()
	
	# Запускаем анимацию появления
	_play_intro_animation()

func _initialize_ui_for_animation() -> void:
	# Панель — начинаем с прозрачностью 0
	var panel_style := menu_panel.get_theme_stylebox("panel")
	if panel_style:
		# Создаём копию стиля для анимации
		var anim_style := panel_style.duplicate()
		anim_style.bg_color.a = 0.0
		menu_panel.add_theme_stylebox_override("panel", anim_style)
	
	# Заголовок — начинаем с прозрачностью 0 и небольшим смещением вверх
	title_label.modulate.a = 0.0
	title_label.position.y -= 30.0
	
	# Кнопки — прячем
	for button in buttons_vbox.get_children():
		if button is Button:
			button.modulate.a = 0.0
			button.position.y += 20.0
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Версия — прячем
	version_label.modulate.a = 0.0

func _connect_button_signals() -> void:
	var play_button: Button = buttons_vbox.get_node_or_null("PlayButton")
	var options_button: Button = buttons_vbox.get_node_or_null("OptionsButton")
	var skins_button: Button = buttons_vbox.get_node_or_null("SkinsButton")
	var quit_button: Button = buttons_vbox.get_node_or_null("QuitButton")
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	if skins_button:
		skins_button.pressed.connect(_on_skins_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _play_intro_animation() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Анимация панели (0.0 — 0.6 секунды)
	var panel_style := menu_panel.get_theme_stylebox("panel")
	if panel_style:
		tween.tween_property(panel_style, "bg_color:a", 0.88, 0.6)
	
	# Анимация заголовка (0.3 — 0.8 секунды)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5).set_delay(0.3)
	tween.parallel().tween_property(title_label, "position:y", title_label.position.y + 30.0, 0.5).set_delay(0.3)
	
	# Анимация кнопок (последовательно, с задержкой 0.15с между каждой)
	var button_index: float = 0.0
	for button in buttons_vbox.get_children():
		if button is Button:
			var delay: float = 0.5 + (button_index * button_delay)
			tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
			tween.parallel().tween_property(button, "position:y", button.position.y + 20.0, 0.4).set_delay(delay)
			button_index += 1.0
	
	# Анимация версии (последней)
	tween.tween_property(version_label, "modulate:a", 0.7, 0.4).set_delay(0.5 + (button_index * button_delay))

func _process(delta: float) -> void:
	# Вращение куба
	if cube:
		cube.rotate_y(rotation_speed * delta)
		cube.rotate_x(0.1 * delta)
		
		# Пульсация свечения куба
		var pulse := (sin(Time.get_ticks_msec() * 0.002) + 1.0) * 0.5
		var mesh := cube.get_surface_override_material(0)
		if mesh and mesh is StandardMaterial3D:
			mesh.emission_energy_multiplier = 2.0 + pulse * 2.0
	
	# Вращение neon bars
	if neon_bars:
		neon_bars.rotate_y(delta * 0.1)
	
	# Небольшое покачивание камеры
	if camera:
		var camera_y := 4.0 + sin(Time.get_ticks_msec() * 0.001) * 0.05
		camera.position.y = camera_y

# Обработчики кнопок
func _on_play_pressed() -> void:
	print("[GameMenu] Нажата кнопка ИГРАТЬ")
	_load_main_menu_overlay()

func _load_main_menu_overlay() -> void:
	# Скрываем 3D панель меню
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_panel, "modulate:a", 0.0, 0.4)
	
	# После анимации показываем MainMenu overlay
	tween.tween_callback(_show_main_menu)

func _show_main_menu() -> void:
	# Скрываем 3D меню
	menu_panel.visible = false
	main_menu_container.visible = true
	
	# Загружаем MainMenu.tscn
	var main_menu_scene := load("res://client/ui/MainMenu.tscn")
	if main_menu_scene:
		main_menu_instance = main_menu_scene.instantiate()
		main_menu_container.add_child(main_menu_instance)
		
		# Анимация появления
		main_menu_instance.modulate.a = 0.0
		var fade_tween := create_tween()
		fade_tween.tween_property(main_menu_instance, "modulate:a", 1.0, 0.3)
		
		# Подключаем сигнал закрытия если есть
		if main_menu_instance.has_method("set_close_callback"):
			main_menu_instance.set_close_callback(_on_main_menu_closed)
	else:
		push_error("[GameMenu] Не удалось загрузить MainMenu.tscn")

func _on_main_menu_closed() -> void:
	# Возвращаемся к 3D меню
	if main_menu_instance:
		var tween := create_tween()
		tween.tween_property(main_menu_instance, "modulate:a", 0.0, 0.3)
		tween.tween_callback(_return_to_3d_menu)

func _return_to_3d_menu() -> void:
	# Удаляем MainMenu
	if main_menu_instance:
		main_menu_instance.queue_free()
		main_menu_instance = null
	
	main_menu_container.visible = false
	menu_panel.visible = true
	
	# Анимация появления 3D меню
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.4)

func _on_options_pressed() -> void:
	print("[GameMenu] Нажата кнопка НАСТРОЙКИ")
	# TODO: Переход к экрану настроек

func _on_skins_pressed() -> void:
	print("[GameMenu] Нажата кнопка СКИНЫ")
	# TODO: Переход к экрану выбора скинов

func _on_quit_pressed() -> void:
	print("[GameMenu] Нажата кнопка ВЫХОД")
	# Анимация перед выходом
	var tween := create_tween()
	tween.tween_property(menu_panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(get_tree().quit)

# Переход между сценами (для будущего использования)
func _transition_to_scene(scene_path: String) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade out
	tween.tween_property(menu_panel, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)
