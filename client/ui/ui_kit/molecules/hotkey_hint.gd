# res://client/ui/ui_kit/molecules/hotkey_hint.gd
@tool
class_name MoleculeHotkeyHint
extends HBoxContainer

## Молекула: подсказка клавиши [ESC] Выход

@export var key_text: String = "ESC":
	set(value):
		key_text = value
		if _key_label:
			_key_label.text = value

@export var action_text: String = "Выход":
	set(value):
		action_text = value
		if _action_label:
			_action_label.text = value

@onready var _key_badge: PanelContainer = %KeyBadge
@onready var _key_label: Label = %KeyLabel
@onready var _action_label: Label = %ActionLabel


func _ready() -> void:
	# Spacing
	add_theme_constant_override("separation", UiTokens.SPACE_SM)
	
	# Key Badge стиль
	var badge_style := UiTokens.make_stylebox_flat(
		UiTokens.COLOR_SURFACE,
		UiTokens.COLOR_SURFACE_BORDER,
		UiTokens.BORDER_WIDTH_THIN,
		UiTokens.RADIUS_SM,
		UiTokens.SPACE_XS
	)
	badge_style.content_margin_left = UiTokens.SPACE_SM
	badge_style.content_margin_right = UiTokens.SPACE_SM
	badge_style.content_margin_top = UiTokens.SPACE_2XS
	badge_style.content_margin_bottom = UiTokens.SPACE_2XS
	_key_badge.add_theme_stylebox_override("panel", badge_style)
	
	# Key Label (mono шрифт)
	_key_label.text = key_text
	_key_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_MONO))
	_key_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_HUD)
	_key_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_SECONDARY)
	
	# Action Label
	_action_label.text = action_text
	_action_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY))
	_action_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_LABEL)
	_action_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_DISABLED)
	_action_label.uppercase = true