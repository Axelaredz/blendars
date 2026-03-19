# res://client/ui/ui_kit/organisms/main_nav.gd
class_name OrganismMainNav
extends PanelContainer

## Организм: вертикальная навигационная панель.
## Управляет коллекцией MenuItem.
## Обеспечивает keyboard navigation (↑↓, Enter).

signal navigation_selected(item_id: String)
signal navigation_hovered(item_id: String)

## Определение пунктов меню
@export var menu_items: Array[Dictionary] = []:
	set(value):
		menu_items = value
		if is_inside_tree():
			_rebuild_items()

# Сцена молекулы
const MENU_ITEM_SCENE := preload("res://client/ui/ui_kit/molecules/menu_item.tscn")
const DIVIDER_SCENE := preload("res://client/ui/ui_kit/atoms/divider.tscn")

@onready var _vbox: VBoxContainer = %VBox
@onready var _section_label: Label = %SectionLabel
@onready var _items_container: VBoxContainer = %ItemsContainer
@onready var _exit_item: MoleculeMenuItem = %ExitItem

var _item_nodes: Array[MoleculeMenuItem] = []
var _focused_index: int = -1
var _active_id: String = ""


func _ready() -> void:
	_apply_panel_style()
	_setup_section_label()
	_rebuild_items()
	_setup_exit_item()
	
	# Keyboard input
	set_process_unhandled_key_input(true)


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(
		UiTokens.COLOR_BG_ELEVATED.r,
		UiTokens.COLOR_BG_ELEVATED.g,
		UiTokens.COLOR_BG_ELEVATED.b,
		0.85
	)
	style.border_color = UiTokens.COLOR_SURFACE_BORDER
	style.border_width_right = UiTokens.BORDER_WIDTH_THIN
	style.content_margin_top = UiTokens.SPACE_XL
	style.content_margin_bottom = UiTokens.SPACE_XL
	add_theme_stylebox_override("panel", style)
	
	custom_minimum_size.x = 280


func _setup_section_label() -> void:
	_section_label.text = "НАВИГАЦИЯ"
	_section_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY_SEMI))
	_section_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_LABEL)
	_section_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_DISABLED)
	_section_label.uppercase = true


func _rebuild_items() -> void:
	# Очистка
	for child in _items_container.get_children():
		child.queue_free()
	_item_nodes.clear()
	
	# Создание
	for item_data in menu_items:
		var item := MENU_ITEM_SCENE.instantiate() as MoleculeMenuItem
		item.item_id = item_data.get("id", "")
		item.label_text = item_data.get("label", "???")
		item.is_disabled = item_data.get("disabled", false)
		
		if item_data.has("icon"):
			item.icon_texture = load(item_data["icon"])
		
		# Подключаем сигналы молекулы
		item.item_pressed.connect(_on_item_pressed)
		item.item_hovered.connect(_on_item_hovered)
		
		_items_container.add_child(item)
		_item_nodes.append(item)
	
	# Если есть сохранённый active — применяем
	if _active_id != "":
		set_active(_active_id)


func _setup_exit_item() -> void:
	_exit_item.item_id = "exit"
	_exit_item.label_text = "ВЫХОД"
	_exit_item.variant = "danger"
	_exit_item.item_pressed.connect(_on_item_pressed)
	_exit_item.item_hovered.connect(_on_item_hovered)


## Установить активный пункт
func set_active(item_id: String) -> void:
	_active_id = item_id
	for item in _item_nodes:
		item.is_active = (item.item_id == item_id)


## Keyboard navigation
func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				_move_focus(-1)
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_move_focus(1)
				get_viewport().set_input_as_handled()
			KEY_ENTER:
				if _focused_index >= 0 and _focused_index < _item_nodes.size():
					_item_nodes[_focused_index]._do_press()
				get_viewport().set_input_as_handled()


func _move_focus(direction: int) -> void:
	var total := _item_nodes.size()
	if total == 0:
		return
	
	_focused_index = wrapi(_focused_index + direction, 0, total)
	
	# Пропускаем disabled
	var attempts := 0
	while _item_nodes[_focused_index].is_disabled and attempts < total:
		_focused_index = wrapi(_focused_index + direction, 0, total)
		attempts += 1
	
	_item_nodes[_focused_index].grab_focus()


func _on_item_pressed(item_id: String) -> void:
	set_active(item_id)
	navigation_selected.emit(item_id)


func _on_item_hovered(item_id: String) -> void:
	navigation_hovered.emit(item_id)