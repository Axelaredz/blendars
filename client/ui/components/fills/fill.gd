class_name Fill
extends Control

## Fill component for UI elements
## Modular fill with style resource support + shader support for chamfered corners
## Use as background/decoration in buttons, panels, etc.

signal fill_state_changed(new_state: String)

const FillStyleScript := preload("res://client/ui/components/fills/fill_style.gd")

## Style resource
@export var style: Resource:
	set(value):
		style = value
		_update_appearance()

## Current state
@export var current_state: String = "idle":
	set(value):
		if current_state != value:
			current_state = value
			_animate_to_state(value)

## Corner preset (overrides style corners)
@export var corner_preset: String = "all":
	set(value):
		corner_preset = value
		if style:
			style.apply_corner_preset(value)
			_update_appearance()

## Custom minimum size
@export var fill_size: Vector2 = Vector2(180, 50):
	set(value):
		fill_size = value
		custom_minimum_size = value

## Enable mouse interaction
@export var interactive: bool = false:
	set(value):
		interactive = value
		mouse_filter = Control.MOUSE_FILTER_IGNORE if not value else Control.MOUSE_FILTER_STOP

## === Chamfer (skewed corners) settings ===
@export_group("Chamfer")
@export var chamfer_enabled: bool = false:
	set(value):
		chamfer_enabled = value
		_apply_chamfer_shader()
@export var chamfer_bottom_right: bool = false:
	set(value):
		chamfer_bottom_right = value
		_apply_chamfer_shader()
@export var chamfer_top_left: bool = false:
	set(value):
		chamfer_top_left = value
		_apply_chamfer_shader()
@export_range(4, 64) var chamfer_size: float = 20.0:
	set(value):
		chamfer_size = value
		_apply_chamfer_shader()

## Internal StyleBox
var _stylebox: StyleBoxFlat
var _current_tween: Tween
var _target_bg_color: Color
var _target_border_color: Color
var _shader_material: ShaderMaterial

# State colors for fast lookup
var _valid_states: Array[String] = ["idle", "hover", "pressed", "disabled"]


func _ready() -> void:
	custom_minimum_size = fill_size
	
	# Create default style if not assigned
	if not style:
		style = FillStyleScript.new()
	
	# Setup shader material if needed
	_setup_shader()
	_update_appearance()
	
	# Connect mouse events if interactive
	if interactive:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)


func _setup_shader() -> void:
	# Try to load the chamfer shader
	var shader := load("res://client/ui/shaders/chamfer_button.gdshader") as Shader
	if not shader:
		# Try alternative path
		shader = load("res://client/ui/shaders/cyber_button.gdshader") as Shader
	
	if shader:
		_shader_material = ShaderMaterial.new()
		_shader_material.shader = shader
		material = _shader_material
		_apply_chamfer_shader()


func _apply_chamfer_shader() -> void:
	if not _shader_material:
		return
	
	_shader_material.set_shader_parameter("chamfer_enabled", chamfer_enabled)
	_shader_material.set_shader_parameter("chamfer_bottom_right", chamfer_bottom_right)
	_shader_material.set_shader_parameter("chamfer_top_left", chamfer_top_left)
	_shader_material.set_shader_parameter("chamfer_size", chamfer_size)
	
	# Update colors from style
	if style:
		_shader_material.set_shader_parameter("bg_color", style.get_color_for_state(current_state))
		_shader_material.set_shader_parameter("border_color", style.get_border_color_for_state(current_state))
		_shader_material.set_shader_parameter("border_width", style.border_width)
	
	# Disable stylebox when using chamfer
	if chamfer_enabled:
		_stylebox = null
		queue_redraw()
	else:
		_update_appearance()


func _update_chamfer_colors(state: String) -> void:
	if not _shader_material or not chamfer_enabled:
		return
	
	if style:
		_shader_material.set_shader_parameter("bg_color", style.get_color_for_state(state))
		_shader_material.set_shader_parameter("border_color", style.get_border_color_for_state(state))


func set_chamfer_hover(hover: bool) -> void:
	if not _shader_material or not chamfer_enabled:
		return
	
	_shader_material.set_shader_parameter("hover_amount", 1.0 if hover else 0.0)


func _draw() -> void:
	if _stylebox:
		draw_style_box(_stylebox, Rect2(Vector2.ZERO, size))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


## Update visual appearance from current style
func _update_appearance() -> void:
	if not style:
		return
	
	_stylebox = style.create_stylebox(current_state)
	queue_redraw()


## Animate transition to new state
func _animate_to_state(new_state: String) -> void:
	if not style:
		return
	
	# Cancel previous tween
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	
	# Store target colors for interpolation
	_target_bg_color = style.get_color_for_state(new_state)
	_target_border_color = style.get_border_color_for_state(new_state)
	var duration: float = style.transition_duration
	
	# Handle chamfer shader colors
	if chamfer_enabled and _shader_material:
		# For chamfer, use instant color switch with hover animation
		_shader_material.set_shader_parameter("bg_color", _target_bg_color)
		_shader_material.set_shader_parameter("border_color", _target_border_color)
		_shader_material.set_shader_parameter("hover_amount", 1.0 if new_state == "hover" else 0.0)
		queue_redraw()
		fill_state_changed.emit(new_state)
		return
	
	# Create tween for stylebox
	_current_tween = create_tween()
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_QUART)
	
	# Animate from 0 to 1
	_current_tween.tween_method(_interpolate_colors, 0.0, 1.0, duration)
	
	fill_state_changed.emit(new_state)


## Interpolation callback for tween
func _interpolate_colors(weight: float) -> void:
	if not _stylebox:
		return
	
	_stylebox.bg_color = _stylebox.bg_color.lerp(_target_bg_color, weight)
	_stylebox.border_color = _stylebox.border_color.lerp(_target_border_color, weight)
	queue_redraw()


## Set state directly (no animation)
func set_state(state: String, animate: bool = true) -> void:
	if state not in _valid_states:
		push_warning("Invalid state: %s. Valid: %s" % [state, _valid_states])
		return
	
	if animate:
		current_state = state
	else:
		current_state = state
		_update_appearance()


## Quick state setters
func set_idle() -> void: current_state = "idle"
func set_hover() -> void: current_state = "hover"
func set_pressed() -> void: current_state = "pressed"
func set_disabled() -> void: current_state = "disabled"


## Apply custom colors (overrides style)
func set_custom_color(color: Color, border_color: Color = Color()) -> void:
	if not _stylebox:
		return
	
	_stylebox.bg_color = color
	_stylebox.border_color = border_color if border_color != Color() else color
	queue_redraw()


## Update corner radius at runtime
func set_corner_radius(top_left: int, top_right: int, bottom_left: int, bottom_right: int) -> void:
	if not _stylebox:
		return
	
	_stylebox.corner_radius_top_left = top_left
	_stylebox.corner_radius_top_right = top_right
	_stylebox.corner_radius_bottom_left = bottom_left
	_stylebox.corner_radius_bottom_right = bottom_right
	queue_redraw()


## Set uniform corner radius
func set_uniform_corner_radius(radius: int) -> void:
	set_corner_radius(radius, radius, radius, radius)


# Mouse event handlers
func _on_mouse_entered() -> void:
	if current_state != "disabled":
		current_state = "hover"


func _on_mouse_exited() -> void:
	if current_state != "disabled":
		current_state = "idle"
