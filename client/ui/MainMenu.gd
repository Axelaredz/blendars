extends MainMenu
## Blendars Main Menu — cyberpunk sci-fi style
## Extends Maaack's MainMenu base class for full addon functionality.

@onready var _title_label: Label = $TitleLabel
@onready var _menu_panel: PanelContainer = $MenuContainer/MenuHBox/LeftPanel
@onready var _buttons_box: BoxContainer = %MenuButtonsBoxContainer

func _ready() -> void:
	# Packed scenes for Options и Credits из аддона
	options_packed_scene = load("res://addons/maaacks_menus_template/examples/scenes/windows/main_menu_options_window.tscn")
	credits_packed_scene = load("res://addons/maaacks_menus_template/examples/scenes/windows/main_menu_credits_window.tscn")

	# Применяем шрифты
	var font_bold := load("res://client/ui/fonts/Exo2-BoldItalic.woff2") as FontFile
	var font_semi := load("res://client/ui/fonts/Exo2-SemiBoldItalic.woff2") as FontFile

	if _title_label and font_bold:
		_title_label.add_theme_font_override("font", font_bold)
		_title_label.add_theme_font_size_override("font_size", 80)

	if _buttons_box and font_semi:
		for child in _buttons_box.get_children():
			if child is Button:
				child.add_theme_font_override("font", font_semi)
				child.add_theme_font_size_override("font_size", 18)

	# Вызываем родительский ready (скрывает кнопки без сцен)
	super._ready()

	# Анимация появления
	_play_entrance()

func _play_entrance() -> void:
	if _title_label:
		_title_label.modulate.a = 0.0
	if _menu_panel:
		_menu_panel.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)

	if _title_label:
		tween.tween_property(_title_label, "modulate:a", 1.0, 0.7)

	if _menu_panel:
		tween.tween_property(_menu_panel, "modulate:a", 1.0, 0.6).set_delay(0.3)

	if _buttons_box:
		var btns := _buttons_box.get_children()
		for i in btns.size():
			if btns[i] is Button:
				btns[i].modulate.a = 0.0
				tween.tween_property(btns[i], "modulate:a", 1.0, 0.3).set_delay(0.5 + i * 0.12)
