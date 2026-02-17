@tool
class_name CyberButton
extends Button

@export var glitch_on_hover: bool = true
@export var glitch_intensity: float = 0.05
@export var accent_color: Color = Color("#bd93f9")

@onready var glitch_overlay: ColorRect = $GlitchOverlay

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	
	if glitch_overlay and glitch_overlay.material:
		glitch_overlay.material.set_shader_parameter("intensity", 0.0)

func _on_mouse_entered() -> void:
	if not glitch_on_hover:
		return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(glitch_overlay, "modulate:a", 0.3, 0.15)
	tween.tween_property(glitch_overlay.material, "shader_parameter/intensity", glitch_intensity, 0.15)
	tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.15)

func _on_mouse_exited() -> void:
	if not glitch_on_hover:
		return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.2)
	tween.tween_property(glitch_overlay.material, "shader_parameter/intensity", 0.0, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _on_pressed() -> void:
	var flash = glitch_overlay.duplicate()
	add_child(flash)
	flash.modulate = Color("#8be9fd", 0.8)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)
