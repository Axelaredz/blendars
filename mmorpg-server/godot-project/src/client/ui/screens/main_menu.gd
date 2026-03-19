# res://screens/main_menu.gd
extends Control

## Экран: Главное меню BLEND ARS.
## Подставляет конкретные организмы в слоты шаблона.
## Здесь живёт вся бизнес-логика экрана.

const LAYOUT_SCENE := preload(
	"res://client/ui/ui_kit/templates/layout_main_menu.tscn")
const TITLE_BAR_SCENE := preload(
	"res://client/ui/ui_kit/organisms/title_bar.tscn")
const MAIN_NAV_SCENE := preload(
	"res://client/ui/ui_kit/organisms/main_nav.tscn")
const HOTKEY_BAR_SCENE := preload(
	"res://client/ui/ui_kit/organisms/hotkey_bar.tscn")

var _layout: TemplateMainMenu
var _title_bar: OrganismTitleBar
var _main_nav: OrganismMainNav
var _hotkey_bar: OrganismHotkeyBar


func _ready() -> void:
	_build_screen()
	_connect_signals()
	
	# Анимация появления (10% — cinematic)
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0,
		UiTokens.ANIM_DURATION_CINEMATIC)


func _build_screen() -> void:
	# 1. Создаём шаблон
	_layout = LAYOUT_SCENE.instantiate() as TemplateMainMenu
	add_child(_layout)
	
	# 2. Подставляем организмы в слоты
	
	# --- TitleBar → title_slot ---
	_title_bar = TITLE_BAR_SCENE.instantiate() as OrganismTitleBar
	_title_bar.game_title = "BLEND ARS"
	_title_bar.version_text = "v0.7.2"
	_layout.title_slot.add_child(_title_bar)
	
	# --- MainNav → nav_slot ---
	_main_nav = MAIN_NAV_SCENE.instantiate() as OrganismMainNav
	_main_nav.menu_items = [
		{"id": "campaign", "label": "КАМПАНИЯ"},
		{"id": "arsenal", "label": "АРСЕНАЛ"},
		{"id": "multiplayer", "label": "МУЛЬТИПЛЕЕР"},
		{"id": "settings", "label": "НАСТРОЙКИ",
		 "disabled": false},
	]
	_layout.nav_slot.add_child(_main_nav)
	
	# --- 3D Viewport → viewport_slot ---
	_setup_3d_viewport()
	
	# --- HotkeyBar → bottom_slot ---
	_hotkey_bar = HOTKEY_BAR_SCENE.instantiate() as OrganismHotkeyBar
	_hotkey_bar.hints = [
		{"key": "ESC", "action": "Выход"},
		{"key": "ENTER", "action": "Выбрать"},
		{"key": "↑↓", "action": "Навигация"},
		{"key": "TAB", "action": "Профиль"},
	]
	_layout.bottom_slot.add_child(_hotkey_bar)


func _setup_3d_viewport() -> void:
	# SubViewportContainer для 3D-сцены с юнитом
	var viewport_container := SubViewportContainer.new()
	viewport_container.anchors_preset = Control.PRESET_FULL_RECT
	viewport_container.stretch = true
	
	var sub_viewport := SubViewport.new()
	sub_viewport.transparent_bg = true
	sub_viewport.size = Vector2i(1920, 1080)
	sub_viewport.render_target_update_mode = \
		SubViewport.UPDATE_ALWAYS
	
	viewport_container.add_child(sub_viewport)
	
	# Загружаем 3D-сцену с платформой и юнитом
	var unit_scene := load(
		"res://scenes/unit_preview.tscn") as PackedScene
	if unit_scene:
		var unit_instance := unit_scene.instantiate()
		sub_viewport.add_child(unit_instance)
	
	_layout.viewport_slot.add_child(viewport_container)


func _connect_signals() -> void:
	_main_nav.navigation_selected.connect(_on_nav_selected)
	_main_nav.navigation_hovered.connect(_on_nav_hovered)


func _on_nav_selected(item_id: String) -> void:
	match item_id:
		"campaign":
			_transition_to("res://screens/campaign.tscn")
		"arsenal":
			_transition_to("res://screens/arsenal_screen.tscn")
		"multiplayer":
			_transition_to("res://screens/multiplayer.tscn")
		"settings":
			_transition_to("res://screens/settings_screen.tscn")
		"exit":
			_confirm_exit()


func _on_nav_hovered(item_id: String) -> void:
	# Можно менять 3D-превью или подсказки
	pass


func _transition_to(scene_path: String) -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0,
		UiTokens.ANIM_DURATION_SLOW)
	tw.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)


func _confirm_exit() -> void:
	# Здесь можно показать модальное окно подтверждения
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC
		_confirm_exit()