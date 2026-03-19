# res://client/ui/ui_kit/atoms/dot_indicator.gd
@tool
class_name AtomDotIndicator
extends ColorRect

## Атом: круглый индикатор статуса.

@export_enum("online", "offline", "warning", "danger")
var status: String = "online":
	set(value):
		status = value
		_apply_color()

const STATUS_COLORS := {
	"online": UiTokens.COLOR_ACCENT_TERTIARY,
	"offline": UiTokens.COLOR_TEXT_DISABLED,
	"warning": UiTokens.COLOR_ACCENT_WARNING,
	"danger": UiTokens.COLOR_ACCENT_DANGER,
}

func _ready() -> void:
	custom_minimum_size = Vector2(8, 8)
	size = Vector2(8, 8)
	# Делаем круглым через шейдер
	var shader_code := "
		shader_type canvas_item;
		void fragment() {
			float dist = distance(UV, vec2(0.5));
			if (dist > 0.5) discard;
		}
	"
	var shader := Shader.new()
	shader.code = shader_code
	material = ShaderMaterial.new()
	material.shader = shader
	_apply_color()


func _apply_color() -> void:
	if STATUS_COLORS.has(status):
		color = STATUS_COLORS[status]