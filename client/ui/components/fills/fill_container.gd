class_name FillContainer
extends Control

## Container for Fill component with automatic layout
## Simplified version - manages single fill with state

## Style resource to pass to fill
@export var fill_style: Resource:
	set(value):
		fill_style = value
		if _fill:
			_fill.style = fill_style

## Current state
@export var current_state: String = "idle":
	set(value):
		current_state = value
		if _fill:
			_fill.current_state = value

## Corner preset
@export var corner_preset: String = "all":
	set(value):
		corner_preset = value
		if _fill:
			_fill.corner_preset = value

## Size for the fill
@export var fill_size: Vector2 = Vector2(180, 50):
	set(value):
		fill_size = value
		custom_minimum_size = value
		if _fill:
			_fill.fill_size = value

## Enable mouse interaction on fill
@export var interactive: bool = false:
	set(value):
		interactive = value
		if _fill:
			_fill.interactive = value

## Internal fill reference
var _fill: Fill

const FillScript := preload("res://client/ui/components/fills/fill.gd")


func _ready() -> void:
	custom_minimum_size = fill_size
	_create_fill()


func _create_fill() -> void:
	_fill = FillScript.new()
	_fill.name = "Fill"
	_fill.style = fill_style
	_fill.current_state = current_state
	_fill.corner_preset = corner_preset
	_fill.fill_size = fill_size
	_fill.interactive = interactive
	
	# Fill takes full rect
	_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	add_child(_fill)
	
	# Forward state change signal
	_fill.fill_state_changed.connect(_on_fill_state_changed)


## Set fill state
func set_state(state: String, animate: bool = true) -> void:
	if _fill:
		_fill.set_state(state, animate)


## Quick state setters
func set_idle() -> void:
	if _fill: _fill.set_idle()

func set_hover() -> void:
	if _fill: _fill.set_hover()

func set_pressed() -> void:
	if _fill: _fill.set_pressed()

func set_disabled() -> void:
	if _fill: _fill.set_disabled()


## Set custom colors (overrides style)
func set_custom_color(color: Color, border_color: Color = Color()) -> void:
	if _fill:
		_fill.set_custom_color(color, border_color)


## Get internal fill for advanced customization
func get_fill() -> Fill:
	return _fill


## Signal handler
func _on_fill_state_changed(new_state: String) -> void:
	# Can be overridden in derived classes
	pass