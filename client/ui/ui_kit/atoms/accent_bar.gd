# res://client/ui/ui_kit/atoms/accent_bar.gd
@tool
class_name AtomAccentBar
extends ColorRect

## Атом: вертикальная акцентная полоса 3px.
## Используется в MenuItem для обозначения hover/active.

@export var accent_color: Color = UiTokens.COLOR_ACCENT_PRIMARY:
	set(value):
		accent_color = value
		color = accent_color

@export var bar_visible: bool = false:
	set(value):
		bar_visible = value
		_update_visibility()

@export var animate: bool = true


func _ready() -> void:
	custom_minimum_size.x = UiTokens.ACCENT_BAR_WIDTH
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	color = accent_color
	
	if not bar_visible:
		modulate.a = 0.0


func _update_visibility() -> void:
	if not is_inside_tree():
		return
	
	if animate:
		var tw := create_tween()
		tw.set_ease(UiTokens.ANIM_EASE_DEFAULT)
		tw.set_trans(UiTokens.ANIM_TRANS_DEFAULT)
		tw.tween_property(self, "modulate:a",
			1.0 if bar_visible else 0.0,
			UiTokens.ANIM_DURATION_FAST
		)
	else:
		modulate.a = 1.0 if bar_visible else 0.0


func show_bar() -> void:
	bar_visible = true


func hide_bar() -> void:
	bar_visible = false