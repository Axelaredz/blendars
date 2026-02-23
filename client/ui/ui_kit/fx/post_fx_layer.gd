# res://client/ui/ui_kit/fx/post_fx_layer.gd
class_name PostFXLayer
extends CanvasLayer

## Комбинированный пост-эффект слой.
## Добавь как дочерний узел к любому экрану.
## ВСЕ эффекты = 10% правило, не доминируют.

@export var enable_scanlines: bool = true
@export var enable_noise: bool = true
@export var enable_vignette: bool = true
@export var enable_chromatic: bool = true

@onready var _scanline_rect: ColorRect = $ScanlineRect
@onready var _noise_rect: ColorRect = $NoiseRect
@onready var _vignette_rect: ColorRect = $VignetteRect
@onready var _aberration_rect: ColorRect = $AberrationRect


func _ready() -> void:
	layer = 100  # Поверх всего UI
	
	_setup_rect(_scanline_rect,
		"res://client/ui/ui_kit/fx/crt_scanlines.gdshader", enable_scanlines)
	_setup_rect(_noise_rect,
		"res://client/ui/ui_kit/fx/noise_grain.gdshader", enable_noise)
	_setup_rect(_vignette_rect,
		"res://client/ui/ui_kit/fx/vignette.gdshader", enable_vignette)
	_setup_rect(_aberration_rect,
		"res://client/ui/ui_kit/fx/chromatic_aberration.gdshader",
		enable_chromatic)
	
	# Применяем значения из токенов
	_apply_token_values()


func _setup_rect(
	rect: ColorRect,
	shader_path: String,
	enabled: bool
) -> void:
	rect.visible = enabled
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.anchors_preset = Control.PRESET_FULL_RECT
	
	var shader := load(shader_path) as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		rect.material = mat


func _apply_token_values() -> void:
	if _scanline_rect.material:
		_scanline_rect.material.set_shader_parameter(
			"opacity", UiTokens.FX_SCANLINE_OPACITY)
	
	if _noise_rect.material:
		_noise_rect.material.set_shader_parameter(
			"intensity", UiTokens.FX_NOISE_OPACITY)
	
	if _vignette_rect.material:
		_vignette_rect.material.set_shader_parameter(
			"intensity", UiTokens.FX_VIGNETTE_INTENSITY)
	
	if _aberration_rect.material:
		_aberration_rect.material.set_shader_parameter(
			"strength", UiTokens.FX_CHROMATIC_STRENGTH)


## Включить/выключить эффект на лету
func set_effect(effect_name: String, enabled: bool) -> void:
	match effect_name:
		"scanlines":
			_scanline_rect.visible = enabled
		"noise":
			_noise_rect.visible = enabled
		"vignette":
			_vignette_rect.visible = enabled
		"chromatic":
			_aberration_rect.visible = enabled