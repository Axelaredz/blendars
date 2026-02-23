# res://client/ui/ui_kit/atoms/text_body.gd
@tool
class_name AtomTextBody
extends Label

## Атом: основной текст интерфейса.
## Использует Exo 2 SemiBold Italic, 16px.
## Это 70% всей типографики в интерфейсе.

@export var text_color_override: Color = Color.TRANSPARENT:
	set(value):
		text_color_override = value
		_apply_style()

@export_enum("primary", "secondary", "disabled", "accent") 
var color_preset: String = "primary":
	set(value):
		color_preset = value
		_apply_style()

@export var enable_glow: bool = false:
	set(value):
		enable_glow = value
		_apply_style()


func _ready() -> void:
	_apply_style()


func _apply_style() -> void:
	# Шрифт
	var font_res := load(UiTokens.FONT_PATH_BODY_SEMI) as Font
	if font_res:
		add_theme_font_override("font", font_res)
	
	add_theme_font_size_override("font_size", UiTokens.FONT_SIZE_BODY)
	
	# Цвет по пресету
	var target_color: Color
	if text_color_override != Color.TRANSPARENT:
		target_color = text_color_override
	else:
		match color_preset:
			"primary":
				target_color = UiTokens.COLOR_TEXT_PRIMARY
			"secondary":
				target_color = UiTokens.COLOR_TEXT_SECONDARY
			"disabled":
				target_color = UiTokens.COLOR_TEXT_DISABLED
			"accent":
				target_color = UiTokens.COLOR_ACCENT_PRIMARY
	
	add_theme_color_override("font_color", target_color)
	
	# Свечение через шейдер (10% правило — только когда enable_glow=true)
	if enable_glow and not material:
		var shader := load("res://client/ui/ui_kit/fx/glow_text.gdshader") as Shader
		if shader:
			var mat := ShaderMaterial.new()
			mat.shader = shader
			mat.set_shader_parameter("glow_color", UiTokens.COLOR_ACCENT_PRIMARY)
			mat.set_shader_parameter("glow_strength", 0.3)
			material = mat
	elif not enable_glow:
		material = null