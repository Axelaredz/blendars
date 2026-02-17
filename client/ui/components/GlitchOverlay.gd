class_name GlitchOverlay
extends ColorRect

func glitch_transition(duration: float = 0.4) -> void:
	var mat = material as ShaderMaterial
	if not mat:
		return
	visible = true
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/intensity", 1.0, duration * 0.3)
	tween.tween_property(mat, "shader_parameter/intensity", 0.0, duration * 0.7)
	tween.tween_callback(func(): visible = false)

func flash(color: Color = Color("#ff79c6", 0.3), duration: float = 0.2) -> void:
	self.color = color
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, duration)
	tween.tween_callback(func(): visible = false)
