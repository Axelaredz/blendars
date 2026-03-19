# res://client/ui/ui_kit/atoms/divider.gd
@tool
class_name AtomDivider
extends ColorRect

## Атом: горизонтальная разделительная линия.

@export var divider_color: Color = UiTokens.COLOR_SURFACE_BORDER:
	set(value):
		divider_color = value
		color = divider_color


func _ready() -> void:
	color = divider_color
	custom_minimum_size.y = 1
	size_flags_horizontal = Control.SIZE_EXPAND_FILL