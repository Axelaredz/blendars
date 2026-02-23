# res://client/ui/ui_kit/molecules/stat_line.gd
@tool
class_name MoleculeStatLine
extends HBoxContainer

## Молекула: строка характеристики с прогресс-баром.
## БРОНЯ ████████░░░░ 78/100

@export var stat_name: String = "STAT":
	set(value):
		stat_name = value
		if _stat_label:
			_stat_label.text = value

@export_range(0, 100) var stat_value: int = 50:
	set(value):
		stat_value = value
		_update_bar()

@export var stat_max: int = 100

@export var bar_color: Color = UiTokens.COLOR_ACCENT_PRIMARY:
	set(value):
		bar_color = value
		_update_bar()

@onready var _stat_label: Label = %StatLabel
@onready var _progress: ProgressBar = %ProgressBar
@onready var _value_label: Label = %StatValue


func _ready() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_SM)
	
	# Label (имя стата)
	_stat_label.text = stat_name
	_stat_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY_SEMI))
	_stat_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_LABEL)
	_stat_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_SECONDARY)
	_stat_label.uppercase = true
	_stat_label.custom_minimum_size.x = 80
	
	# ProgressBar стилизация
	_progress.min_value = 0
	_progress.max_value = stat_max
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.custom_minimum_size.y = 6
	_style_progress_bar()
	
	# Value label (mono)
	_value_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_MONO))
	_value_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_BODY_SM)
	_value_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_SECONDARY)
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_value_label.custom_minimum_size.x = 48
	
	_update_bar()


func _style_progress_bar() -> void:
	# Фон бара
	var bg := StyleBoxFlat.new()
	bg.bg_color = UiTokens.COLOR_SURFACE
	bg.corner_radius_top_left = 1
	bg.corner_radius_top_right = 1
	bg.corner_radius_bottom_left = 1
	bg.corner_radius_bottom_right = 1
	_progress.add_theme_stylebox_override("background", bg)
	
	# Заполнение
	var fill := StyleBoxFlat.new()
	fill.bg_color = bar_color
	fill.corner_radius_top_left = 1
	fill.corner_radius_top_right = 1
	fill.corner_radius_bottom_left = 1
	fill.corner_radius_bottom_right = 1
	_progress.add_theme_stylebox_override("fill", fill)


func _update_bar() -> void:
	if not is_inside_tree():
		return
	
	_progress.value = stat_value
	_value_label.text = "%d" % stat_value
	_style_progress_bar()


## Анимированное изменение значения (20% — мягкая анимация)
func animate_to(new_value: int, duration: float = 0.5) -> void:
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.tween_method(
		func(v: int): stat_value = v,
		stat_value, new_value, duration
	)