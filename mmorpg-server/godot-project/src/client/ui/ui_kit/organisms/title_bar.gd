# res://client/ui/ui_kit/organisms/title_bar.gd
class_name OrganismTitleBar
extends PanelContainer

## Организм: верхняя панель с названием игры.
## B L E N D   A R S
##     ═══════════
##                          v0.7.2

@export var game_title: String = "BLEND ARS"
@export var version_text: String = "v0.7.2"
@export var show_decorative_line: bool = true

@onready var _title_label: Label = %TitleLabel
@onready var _version_label: Label = %VersionLabel
@onready var _deco_line: ColorRect = %DecoLine


func _ready() -> void:
	# Панель
	var style := UiTokens.make_stylebox_flat(
		Color.TRANSPARENT, Color.TRANSPARENT, 0, 0, 0
	)
	add_theme_stylebox_override("panel", style)
	
	# Заголовок (10% — декоративный шрифт)
	_title_label.text = _format_title(game_title)
	_title_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_DISPLAY))
	_title_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_DISPLAY)
	_title_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_PRIMARY)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Glow шейдер на заголовке
	var glow_shader := load("res://client/ui/ui_kit/fx/glow_text.gdshader") as Shader
	if glow_shader:
		var mat := ShaderMaterial.new()
		mat.shader = glow_shader
		mat.set_shader_parameter("glow_color",
			UiTokens.COLOR_ACCENT_PRIMARY)
		mat.set_shader_parameter("glow_strength", 0.4)
		_title_label.material = mat
	
	# Версия (10% — micro text)
	_version_label.text = version_text
	_version_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_MONO))
	_version_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_MICRO)
	_version_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_DISABLED)
	
	# Декоративная линия под заголовком
	_deco_line.color = UiTokens.COLOR_ACCENT_PRIMARY
	_deco_line.custom_minimum_size = Vector2(200, 1)
	_deco_line.modulate.a = 0.5
	_deco_line.visible = show_decorative_line


## Добавляет пробелы между буквами для DISPLAY стиля
func _format_title(title: String) -> String:
	var chars := title.split("")
	return " ".join(chars)