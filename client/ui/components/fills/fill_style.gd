class_name FillStyle
extends Resource

## Style resource for Fill component
## Define colors, borders, corners for different states

## Colors for different states
@export_group("State Colors")
@export var idle_color: Color = Color("#ffb86c")      ## Orange - default state
@export var hover_color: Color = Color("#ff79c6")     ## Pink - hover state
@export var pressed_color: Color = Color("#ff5555")   ## Red - pressed state
@export var disabled_color: Color = Color("#6272a4")  ## Gray - disabled state

## Border settings
@export_group("Border")
@export var border_width: int = 2
@export var idle_border_color: Color = Color("#ffb86c")
@export var hover_border_color: Color = Color("#ff79c6")
@export var pressed_border_color: Color = Color("#ff5555")
@export var disabled_border_color: Color = Color("#6272a4")

## Corner radius
@export_group("Corners")
@export_range(0, 32) var corner_radius_top_left: int = 8
@export_range(0, 32) var corner_radius_top_right: int = 8
@export_range(0, 32) var corner_radius_bottom_left: int = 8
@export_range(0, 32) var corner_radius_bottom_right: int = 8

## Shadow settings
@export_group("Shadow")
@export var shadow_enabled: bool = false
@export var shadow_color: Color = Color(0, 0, 0, 0.5)
@export var shadow_size: int = 4
@export var shadow_offset: Vector2 = Vector2(2, 2)

## Animation settings
@export_group("Animation")
@export var transition_duration: float = 0.15

## Get color for state
func get_color_for_state(state: String) -> Color:
	match state:
		"hover": return hover_color
		"pressed": return pressed_color
		"disabled": return disabled_color
		_: return idle_color

## Get border color for state
func get_border_color_for_state(state: String) -> Color:
	match state:
		"hover": return hover_border_color
		"pressed": return pressed_border_color
		"disabled": return disabled_border_color
		_: return idle_border_color

## Create StyleBoxFlat for specific state
func create_stylebox(state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	
	# Background color
	style.bg_color = get_color_for_state(state)
	
	# Border
	if border_width > 0:
		style.border_color = get_border_color_for_state(state)
		style.set_border_width_all(border_width)
	
	# Corner radius
	style.corner_radius_top_left = corner_radius_top_left
	style.corner_radius_top_right = corner_radius_top_right
	style.corner_radius_bottom_left = corner_radius_bottom_left
	style.corner_radius_bottom_right = corner_radius_bottom_right
	
	# Shadow
	if shadow_enabled:
		style.shadow_color = shadow_color
		style.shadow_size = shadow_size
		style.shadow_offset = shadow_offset
	
	return style

## Apply corner radius preset
func apply_corner_preset(preset: String) -> void:
	match preset:
		"none":
			corner_radius_top_left = 0
			corner_radius_top_right = 0
			corner_radius_bottom_left = 0
			corner_radius_bottom_right = 0
		"all":
			corner_radius_top_left = 8
			corner_radius_top_right = 8
			corner_radius_bottom_left = 8
			corner_radius_bottom_right = 8
		"top":
			corner_radius_top_left = 8
			corner_radius_top_right = 8
			corner_radius_bottom_left = 0
			corner_radius_bottom_right = 0
		"bottom":
			corner_radius_top_left = 0
			corner_radius_top_right = 0
			corner_radius_bottom_left = 8
			corner_radius_bottom_right = 8
		"left":
			corner_radius_top_left = 8
			corner_radius_top_right = 0
			corner_radius_bottom_left = 8
			corner_radius_bottom_right = 0
		"right":
			corner_radius_top_left = 0
			corner_radius_top_right = 8
			corner_radius_bottom_left = 0
			corner_radius_bottom_right = 8
		"pill":
			corner_radius_top_left = 999
			corner_radius_top_right = 999
			corner_radius_bottom_left = 999
			corner_radius_bottom_right = 999