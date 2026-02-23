# res://client/ui/ui_kit/organisms/hotkey_bar.gd
class_name OrganismHotkeyBar
extends PanelContainer

## Организм: нижняя панель с подсказками клавиш.

@export var hints: Array[Dictionary] = [
	{"key": "ESC", "action": "Выход"},
	{"key": "ENTER", "action": "Выбрать"},
	{"key": "↑↓", "action": "Навигация"},
	{"key": "TAB", "action": "Профиль"},
]

const HOTKEY_HINT_SCENE := preload(
	"res://client/ui/ui_kit/molecules/hotkey_hint.tscn")

@onready var _hbox: HBoxContainer = %HBox


func _ready() -> void:
	# Стиль панели — subtle, 30% вторичная информация
	var style := UiTokens.make_stylebox_flat(
		Color(UiTokens.COLOR_BG_SECONDARY.r,
			  UiTokens.COLOR_BG_SECONDARY.g,
			  UiTokens.COLOR_BG_SECONDARY.b, 0.6),
		UiTokens.COLOR_SURFACE_BORDER,
		UiTokens.BORDER_WIDTH_THIN
	)
	style.border_width_bottom = 0
	style.border_width_left = 0
	style.border_width_right = 0
	add_theme_stylebox_override("panel", style)
	
	_hbox.add_theme_constant_override("separation", UiTokens.SPACE_2XL)
	_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	_build_hints()


func _build_hints() -> void:
	for child in _hbox.get_children():
		child.queue_free()
	
	for hint_data in hints:
		var hint := HOTKEY_HINT_SCENE.instantiate() as MoleculeHotkeyHint
		hint.key_text = hint_data.get("key", "?")
		hint.action_text = hint_data.get("action", "")
		_hbox.add_child(hint)


## Динамическое обновление подсказок при смене контекста
func update_hints(new_hints: Array[Dictionary]) -> void:
	hints = new_hints
	_build_hints()