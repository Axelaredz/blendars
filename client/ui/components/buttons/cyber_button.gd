class_name CyberButton
extends Control

## CyberButton - modular button using Fill component
## Supports states: idle, hover, pressed, disabled
## Emits signals for interaction

signal cyber_button_pressed
signal cyber_button_button_down
signal cyber_button_button_up
signal cyber_button_state_changed(new_state: String)

const FillScript := preload("res://client/ui/components/fills/fill.gd")
const FillStyleScript := preload("res://client/ui/components/fills/fill_style.gd")

## Style resource for the fill
@export var fill_style: Resource:
	set(value):
		fill_style = value
		if _fill:
			_fill.style = fill_style

## Button text
@export var text: String = "Button":
	set(value):
		text = value
		if _label:
			_label.text = value

## Font size
@export var font_size: int = 16:
	set(value):
		font_size = value
		if _label:
			_label.add_theme_font_size_override(&"font_size", value)

## Text color for different states
@export_group("Text Colors")
@export var idle_text_color: Color = Color("#f8f8f2")
@export var hover_text_color: Color = Color("#282a36")
@export var pressed_text_color: Color = Color("#282a36")
@export var disabled_text_color: Color = Color("#6272a4")

## Corner preset
@export var corner_preset: String = "all":
	set(value):
		corner_preset = value
		if _fill:
			_fill.corner_preset = value

## Chamfer (skewed corners) - passed to Fill
@export_group("Chamfer")
@export var chamfer_enabled: bool = false:
	set(value):
		chamfer_enabled = value
		if _fill:
			_fill.chamfer_enabled = value
@export var chamfer_bottom_right: bool = false:
	set(value):
		chamfer_bottom_right = value
		if _fill:
			_fill.chamfer_bottom_right = value
@export var chamfer_top_left: bool = false:
	set(value):
		chamfer_top_left = value
		if _fill:
			_fill.chamfer_top_left = value
@export_range(4, 64) var chamfer_size: float = 20.0:
	set(value):
		chamfer_size = value
		if _fill:
			_fill.chamfer_size = value

## Button size
@export var button_size: Vector2 = Vector2(180, 50):
	set(value):
		button_size = value
		custom_minimum_size = value

## Disabled state
@export var disabled: bool = false:
	set(value):
		disabled = value
		if disabled:
			_set_state("disabled")
		else:
			_set_state("idle")

## Internal nodes
var _fill: Control
var _label: Label
var _current_state: String = "idle"
var _is_pressed: bool = false

# Action handling
@export var action: StringName = &""


func _ready() -> void:
	custom_minimum_size = button_size
	_setup_nodes()
	_connect_signals()
	_set_state("idle")


func _setup_nodes() -> void:
	# Create Fill background
	_fill = FillScript.new()
	_fill.name = "Fill"
	_fill.style = fill_style
	_fill.corner_preset = corner_preset
	_fill.fill_size = button_size
	_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Apply chamfer settings
	_fill.chamfer_enabled = chamfer_enabled
	_fill.chamfer_bottom_right = chamfer_bottom_right
	_fill.chamfer_top_left = chamfer_top_left
	_fill.chamfer_size = chamfer_size
	
	add_child(_fill)
	
	# Create Label
	_label = Label.new()
	_label.name = "Label"
	_label.text = text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", font_size)
	_label.add_theme_color_override(&"font_color", idle_text_color)
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)


func _connect_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


# === State Management ===

func _set_state(new_state: String) -> void:
	if _current_state == new_state:
		return
	
	_current_state = new_state
	
	# Update fill state
	if _fill and _fill.has_method("set_state"):
		_fill.set_state(new_state, true)
	
	# Update text color
	_update_text_color()
	
	cyber_button_state_changed.emit(new_state)


func _update_text_color() -> void:
	if not _label:
		return
	
	match _current_state:
		"hover":
			_label.add_theme_color_override(&"font_color", hover_text_color)
		"pressed":
			_label.add_theme_color_override(&"font_color", pressed_text_color)
		"disabled":
			_label.add_theme_color_override(&"font_color", disabled_text_color)
		_:
			_label.add_theme_color_override(&"font_color", idle_text_color)


# === Mouse Events ===

func _on_mouse_entered() -> void:
	if disabled:
		return
	_set_state("hover")


func _on_mouse_exited() -> void:
	if disabled:
		return
	_is_pressed = false
	_set_state("idle")


func _on_gui_input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pressed = true
				_set_state("pressed")
				cyber_button_button_down.emit()
			else:
				if _is_pressed:
					_is_pressed = false
					cyber_button_pressed.emit()
					# Return to hover if still over button
					if get_rect().has_point(get_local_mouse_position()):
						_set_state("hover")
					else:
						_set_state("idle")
				cyber_button_button_up.emit()
	
	elif event is InputEventMouseMotion:
		if _is_pressed:
			# Drag outside while pressed
			if not get_rect().has_point(get_local_mouse_position()):
				_set_state("idle")
			else:
				_set_state("pressed")


# === Public API ===

## Set button state programmatically
func set_state(state: String) -> void:
	_set_state(state)


## Press the button programmatically
func press() -> void:
	if not disabled:
		cyber_button_pressed.emit()


## Get current state
func get_state() -> String:
	return _current_state


## Set text at runtime
func set_text(new_text: String) -> void:
	text = new_text


## Set style at runtime
func set_style(style: Resource) -> void:
	fill_style = style
