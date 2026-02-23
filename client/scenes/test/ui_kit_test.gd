extends Control

## UI Kit Test Scene
## Demonstrates Fill and CyberButton component capabilities

const FillScript := preload("res://client/ui/components/fills/fill.gd")

# Fill nodes
@onready var fill_default: Control = $MarginContainer/VBoxContainer/HBoxContainer/FillDefault
@onready var fill_primary: Control = $MarginContainer/VBoxContainer/HBoxContainer/FillPrimary

@onready var fill_all: Control = $MarginContainer/VBoxContainer/HBoxContainer2/FillAll
@onready var fill_top: Control = $MarginContainer/VBoxContainer/HBoxContainer2/FillTop
@onready var fill_bottom: Control = $MarginContainer/VBoxContainer/HBoxContainer2/FillBottom
@onready var fill_pill: Control = $MarginContainer/VBoxContainer/HBoxContainer2/FillPill

@onready var fill_small: Control = $MarginContainer/VBoxContainer/HBoxContainer4/FillSmall
@onready var fill_medium: Control = $MarginContainer/VBoxContainer/HBoxContainer4/FillMedium
@onready var fill_large: Control = $MarginContainer/VBoxContainer/HBoxContainer4/FillLarge
@onready var fill_xlarge: Control = $MarginContainer/VBoxContainer/HBoxContainer4/FillXLarge

# State control buttons
@onready var btn_idle: Button = $MarginContainer/VBoxContainer/HBoxContainer3/BtnIdle
@onready var btn_hover: Button = $MarginContainer/VBoxContainer/HBoxContainer3/BtnHover
@onready var btn_pressed: Button = $MarginContainer/VBoxContainer/HBoxContainer3/BtnPressed
@onready var btn_disabled: Button = $MarginContainer/VBoxContainer/HBoxContainer3/BtnDisabled

# CyberButton nodes
@onready var btn_cyber: Control = $MarginContainer/VBoxContainer/ButtonHBox/BtnCyber
@onready var btn_primary: Control = $MarginContainer/VBoxContainer/ButtonHBox/BtnPrimary
@onready var btn_danger: Control = $MarginContainer/VBoxContainer/ButtonHBox/BtnDanger

@onready var btn_pill: Control = $MarginContainer/VBoxContainer/ButtonHBox2/BtnPill
@onready var btn_sharp: Control = $MarginContainer/VBoxContainer/ButtonHBox2/BtnSharp
@onready var btn_top_corners: Control = $MarginContainer/VBoxContainer/ButtonHBox2/BtnTopCorners

@onready var btn_small: Control = $MarginContainer/VBoxContainer/ButtonHBox3/BtnSmall
@onready var btn_medium_btn: Control = $MarginContainer/VBoxContainer/ButtonHBox3/BtnMedium
@onready var btn_large: Control = $MarginContainer/VBoxContainer/ButtonHBox3/BtnLarge

@onready var click_counter_label: Label = $MarginContainer/VBoxContainer/ClickCounterLabel

var _all_fills: Array[Control] = []
var _all_buttons: Array[Control] = []
var _click_count: int = 0


func _ready() -> void:
	_collect_fills()
	_collect_buttons()
	_connect_state_buttons()
	_connect_cyber_buttons()


func _collect_fills() -> void:
	_all_fills = [
		fill_default, fill_primary,
		fill_all, fill_top, fill_bottom, fill_pill,
		fill_small, fill_medium, fill_large, fill_xlarge
	]


func _collect_buttons() -> void:
	_all_buttons = [
		btn_cyber, btn_primary, btn_danger,
		btn_pill, btn_sharp, btn_top_corners,
		btn_small, btn_medium_btn, btn_large
	]


func _connect_state_buttons() -> void:
	btn_idle.pressed.connect(_on_btn_idle)
	btn_hover.pressed.connect(_on_btn_hover)
	btn_pressed.pressed.connect(_on_btn_pressed)
	btn_disabled.pressed.connect(_on_btn_disabled)


func _connect_cyber_buttons() -> void:
	for button in _all_buttons:
		if button.has_signal("cyber_button_pressed"):
			button.cyber_button_pressed.connect(_on_cyber_button_pressed.bind(button))
		if button.has_signal("cyber_button_state_changed"):
			button.cyber_button_state_changed.connect(_on_button_state_changed.bind(button))


func _on_btn_idle() -> void:
	_set_all_fills_state("idle")


func _on_btn_hover() -> void:
	_set_all_fills_state("hover")


func _on_btn_pressed() -> void:
	_set_all_fills_state("pressed")


func _on_btn_disabled() -> void:
	_set_all_fills_state("disabled")


func _set_all_fills_state(state: String) -> void:
	for fill in _all_fills:
		if fill.has_method("set_state"):
			fill.set_state(state, true)


func _on_cyber_button_pressed(button: Control) -> void:
	_click_count += 1
	click_counter_label.text = "Click count: %d" % _click_count
	print("[UIKitTest] Button '%s' pressed! Total clicks: %d" % [button.name, _click_count])


func _on_button_state_changed(new_state: String, button: Control) -> void:
	print("[UIKitTest] Button '%s' changed state to: %s" % [button.name, new_state])