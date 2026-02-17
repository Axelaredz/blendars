@tool
class_name CyberPanel
extends PanelContainer

@export var accent_color: Color = Color("#bd93f9"):
	set(value):
		accent_color = value
		_update_border_color()

@onready var scanline_overlay: ColorRect = $ScanlineOverlay

func _ready() -> void:
	_update_border_color()

func _update_border_color() -> void:
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var copy = style.duplicate()
		copy.border_color = accent_color
		add_theme_stylebox_override("panel", copy)

func animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(self, "position:x", position.x, 0.4).from(position.x - 30.0)
