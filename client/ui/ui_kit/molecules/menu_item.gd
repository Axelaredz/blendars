# res://client/ui/ui_kit/molecules/menu_item.gd
@tool
class_name MoleculeMenuItem
extends PanelContainer

## Молекула: пункт меню.
## Состоит из AccentBar + опциональной иконки + текста.
## Испускает сигнал при клике. Поддерживает keyboard navigation.

signal item_pressed(item_id: String)
signal item_hovered(item_id: String)

@export var item_id: String = ""
@export var label_text: String = "МЕНЮ":
	set(value):
		label_text = value
		if _label:
			_label.text = value

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if _icon:
			_icon.texture = value
			_icon.visible = value != null

@export var is_active: bool = false:
	set(value):
		is_active = value
		_update_state()

@export var is_disabled: bool = false:
	set(value):
		is_disabled = value
		_update_state()

@export_enum("default", "danger") var variant: String = "default"

# Ноды
@onready var _hbox: HBoxContainer = %HBox
@onready var _accent_bar: AtomAccentBar = %AccentBar
@onready var _icon: TextureRect = %Icon
@onready var _label: Label = %Label

# State
var _is_hovered: bool = false

# StyleBox кэш
var _style_default: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_active: StyleBoxFlat
var _style_disabled: StyleBoxFlat


func _ready() -> void:
	_build_styles()
	_setup_signals()
	_update_state()
	
	# Настройка Label
	_label.text = label_text
	_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY_SEMI))
	_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_BODY)
	
	# Настройка Icon
	if _icon:
		_icon.custom_minimum_size = Vector2(
			UiTokens.ICON_SIZE_MD, UiTokens.ICON_SIZE_MD)
		_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_icon.visible = icon_texture != null
	
	# Контейнер
	custom_minimum_size.y = 44
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _build_styles() -> void:
	# DEFAULT — прозрачный фон
	_style_default = UiTokens.make_stylebox_empty(UiTokens.SPACE_LG)
	
	# HOVER — подсветка + акцентная полоса
	_style_hover = UiTokens.make_stylebox_hover(
		UiTokens.COLOR_ACCENT_DANGER if variant == "danger"
		else UiTokens.COLOR_ACCENT_PRIMARY
	)
	
	# ACTIVE — более яркий
	_style_active = UiTokens.make_stylebox_flat(
		UiTokens.COLOR_BG_HOVER,
		UiTokens.COLOR_ACCENT_PRIMARY,
		UiTokens.ACCENT_BAR_WIDTH
	)
	_style_active.border_width_right = 0
	_style_active.border_width_top = 0
	_style_active.border_width_bottom = 0
	
	# DISABLED — тусклый
	_style_disabled = UiTokens.make_stylebox_empty(UiTokens.SPACE_LG)


func _setup_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _update_state() -> void:
	if not is_inside_tree():
		return
	
	if is_disabled:
		add_theme_stylebox_override("panel", _style_disabled)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_TEXT_DISABLED)
		_accent_bar.hide_bar()
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		return
	
	if is_active:
		add_theme_stylebox_override("panel", _style_active)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_ACCENT_PRIMARY)
		_accent_bar.accent_color = UiTokens.COLOR_ACCENT_PRIMARY
		_accent_bar.show_bar()
		return
	
	if _is_hovered:
		add_theme_stylebox_override("panel", _style_hover)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_TEXT_PRIMARY)
		var hover_color: Color = (
			UiTokens.COLOR_ACCENT_DANGER if variant == "danger"
			else UiTokens.COLOR_ACCENT_PRIMARY
		)
		_accent_bar.accent_color = hover_color
		_accent_bar.show_bar()
		return
	
	# DEFAULT
	add_theme_stylebox_override("panel", _style_default)
	_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_SECONDARY)
	_accent_bar.hide_bar()


func _on_mouse_entered() -> void:
	if is_disabled:
		return
	_is_hovered = true
	_update_state()
	item_hovered.emit(item_id)


func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_state()


func _on_focus_entered() -> void:
	if is_disabled:
		return
	_is_hovered = true
	_update_state()
	item_hovered.emit(item_id)


func _on_focus_exited() -> void:
	_is_hovered = false
	_update_state()


func _on_gui_input(event: InputEvent) -> void:
	if is_disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_do_press()
	
	if event is InputEventKey:
		if event.keycode == KEY_ENTER and event.pressed:
			_do_press()


func _do_press() -> void:
	# Мини-анимация нажатия (10% яркий эффект)
	var tw := create_tween()
	tw.tween_property(_label, "modulate",
		Color(1.5, 1.5, 1.5), UiTokens.ANIM_DURATION_INSTANT)
	tw.tween_property(_label, "modulate",
		Color.WHITE, UiTokens.ANIM_DURATION_FAST)
	
	item_pressed.emit(item_id)