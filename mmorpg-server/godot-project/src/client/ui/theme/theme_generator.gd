@tool
extends EditorScript

func _run() -> void:
	var theme = Theme.new()

	# === COLORS ===
	var bg = Color("#282a36")
	var current = Color("#44475a")
	var fg = Color("#f8f8f2")
	var comment = Color("#6272a4")
	var purple = Color("#bd93f9")
	var pink = Color("#ff79c6")
	var cyan = Color("#8be9fd")
	var green = Color("#50fa7b")
	var red = Color("#ff5555")
	var orange = Color("#ffb86c")
	var yellow = Color("#f1fa8c")

	# === BUTTON ===
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = purple
	btn_normal.corner_radius_top_left = 4
	btn_normal.corner_radius_top_right = 16
	btn_normal.corner_radius_bottom_left = 16
	btn_normal.corner_radius_bottom_right = 4
	btn_normal.content_margin_left = 24
	btn_normal.content_margin_right = 24
	btn_normal.content_margin_top = 12
	btn_normal.content_margin_bottom = 12
	theme.set_stylebox("normal", "Button", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = pink
	btn_hover.border_width_left = 2
	btn_hover.border_width_right = 2
	btn_hover.border_width_top = 2
	btn_hover.border_width_bottom = 2
	btn_hover.border_color = fg
	theme.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = comment
	btn_pressed.border_width_left = 2
	btn_pressed.border_width_right = 2
	btn_pressed.border_width_top = 2
	btn_pressed.border_width_bottom = 2
	btn_pressed.border_color = cyan
	btn_pressed.content_margin_top = 14
	btn_pressed.content_margin_bottom = 10
	theme.set_stylebox("pressed", "Button", btn_pressed)

	var btn_disabled = btn_normal.duplicate()
	btn_disabled.bg_color = Color(current, 0.5)
	theme.set_stylebox("disabled", "Button", btn_disabled)

	var btn_focus = btn_normal.duplicate()
	btn_focus.border_width_left = 2
	btn_focus.border_width_right = 2
	btn_focus.border_width_top = 2
	btn_focus.border_width_bottom = 2
	btn_focus.border_color = cyan
	theme.set_stylebox("focus", "Button", btn_focus)

	theme.set_color("font_color", "Button", fg)
	theme.set_color("font_hover_color", "Button", fg)
	theme.set_color("font_pressed_color", "Button", fg)
	theme.set_color("font_disabled_color", "Button", comment)

	# === LABEL ===
	theme.set_color("font_color", "Label", fg)
	theme.set_font_size("font_size", "Label", 16)

	# === PANEL ===
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = bg
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = purple
	panel_style.corner_radius_top_left = 0
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 0
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# === LINE EDIT ===
	var le_normal = StyleBoxFlat.new()
	le_normal.bg_color = current
	le_normal.border_width_left = 4
	le_normal.border_width_right = 1
	le_normal.border_width_top = 1
	le_normal.border_width_bottom = 1
	le_normal.border_color = cyan
	le_normal.corner_radius_top_left = 0
	le_normal.corner_radius_top_right = 0
	le_normal.corner_radius_bottom_left = 0
	le_normal.corner_radius_bottom_right = 0
	le_normal.content_margin_left = 12
	le_normal.content_margin_right = 8
	le_normal.content_margin_top = 8
	le_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "LineEdit", le_normal)

	var le_focus = le_normal.duplicate()
	le_focus.border_color = purple
	le_focus.border_width_right = 2
	le_focus.border_width_top = 2
	le_focus.border_width_bottom = 2
	theme.set_stylebox("focus", "LineEdit", le_focus)

	theme.set_color("font_color", "LineEdit", fg)
	theme.set_color("font_placeholder_color", "LineEdit", comment)
	theme.set_color("caret_color", "LineEdit", cyan)
	theme.set_color("selection_color", "LineEdit", Color(purple, 0.4))

	# === TAB CONTAINER ===
	var tab_panel = StyleBoxFlat.new()
	tab_panel.bg_color = bg
	tab_panel.border_width_left = 1
	tab_panel.border_width_right = 1
	tab_panel.border_width_top = 0
	tab_panel.border_width_bottom = 1
	tab_panel.border_color = current
	theme.set_stylebox("panel", "TabContainer", tab_panel)

	var tab_selected = StyleBoxFlat.new()
	tab_selected.bg_color = current
	tab_selected.border_width_bottom = 2
	tab_selected.border_color = purple
	tab_selected.corner_radius_top_left = 4
	tab_selected.corner_radius_top_right = 4
	tab_selected.content_margin_left = 16
	tab_selected.content_margin_right = 16
	tab_selected.content_margin_top = 8
	tab_selected.content_margin_bottom = 8
	theme.set_stylebox("tab_selected", "TabContainer", tab_selected)

	var tab_unselected = StyleBoxFlat.new()
	tab_unselected.bg_color = bg
	tab_unselected.corner_radius_top_left = 4
	tab_unselected.corner_radius_top_right = 4
	tab_unselected.content_margin_left = 16
	tab_unselected.content_margin_right = 16
	tab_unselected.content_margin_top = 8
	tab_unselected.content_margin_bottom = 8
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected)

	var tab_hovered = tab_unselected.duplicate()
	tab_hovered.bg_color = current
	tab_hovered.border_width_bottom = 2
	tab_hovered.border_color = pink
	theme.set_stylebox("tab_hovered", "TabContainer", tab_hovered)

	theme.set_color("font_selected_color", "TabContainer", fg)
	theme.set_color("font_unselected_color", "TabContainer", comment)
	theme.set_color("font_hovered_color", "TabContainer", pink)

	# === SCROLL CONTAINER / SCROLLBAR ===
	var scroll_bg = StyleBoxFlat.new()
	scroll_bg.bg_color = Color(current, 0.3)
	scroll_bg.content_margin_left = 4
	scroll_bg.content_margin_right = 4
	theme.set_stylebox("scroll", "VScrollBar", scroll_bg)

	var scroll_grabber = StyleBoxFlat.new()
	scroll_grabber.bg_color = comment
	scroll_grabber.corner_radius_top_left = 2
	scroll_grabber.corner_radius_top_right = 2
	scroll_grabber.corner_radius_bottom_left = 2
	scroll_grabber.corner_radius_bottom_right = 2
	theme.set_stylebox("grabber", "VScrollBar", scroll_grabber)

	var scroll_grabber_hl = scroll_grabber.duplicate()
	scroll_grabber_hl.bg_color = purple
	theme.set_stylebox("grabber_highlight", "VScrollBar", scroll_grabber_hl)

	var scroll_grabber_pressed = scroll_grabber.duplicate()
	scroll_grabber_pressed.bg_color = pink
	theme.set_stylebox("grabber_pressed", "VScrollBar", scroll_grabber_pressed)

	# === CHECK BUTTON ===
	theme.set_color("font_color", "CheckButton", fg)
	theme.set_color("font_hover_color", "CheckButton", pink)
	theme.set_color("font_pressed_color", "CheckButton", cyan)

	# === OPTION BUTTON ===
	var opt_normal = StyleBoxFlat.new()
	opt_normal.bg_color = current
	opt_normal.border_width_left = 1
	opt_normal.border_width_right = 1
	opt_normal.border_width_top = 1
	opt_normal.border_width_bottom = 1
	opt_normal.border_color = comment
	opt_normal.corner_radius_top_left = 4
	opt_normal.corner_radius_bottom_left = 4
	opt_normal.content_margin_left = 12
	opt_normal.content_margin_right = 12
	opt_normal.content_margin_top = 8
	opt_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "OptionButton", opt_normal)

	var opt_hover = opt_normal.duplicate()
	opt_hover.border_color = purple
	theme.set_stylebox("hover", "OptionButton", opt_hover)

	var opt_pressed = opt_normal.duplicate()
	opt_pressed.border_color = pink
	theme.set_stylebox("pressed", "OptionButton", opt_pressed)

	theme.set_color("font_color", "OptionButton", fg)
	theme.set_color("font_hover_color", "OptionButton", pink)

	# === HSEPARATOR ===
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = comment
	sep_style.content_margin_top = 1
	sep_style.content_margin_bottom = 1
	theme.set_stylebox("separator", "HSeparator", sep_style)
	theme.set_constant("separation", "HSeparator", 8)

	# === POPUP MENU ===
	var popup_panel = StyleBoxFlat.new()
	popup_panel.bg_color = bg
	popup_panel.border_width_left = 1
	popup_panel.border_width_right = 1
	popup_panel.border_width_top = 1
	popup_panel.border_width_bottom = 1
	popup_panel.border_color = comment
	theme.set_stylebox("panel", "PopupMenu", popup_panel)

	var popup_hover = StyleBoxFlat.new()
	popup_hover.bg_color = current
	theme.set_stylebox("hover", "PopupMenu", popup_hover)

	theme.set_color("font_color", "PopupMenu", fg)
	theme.set_color("font_hover_color", "PopupMenu", pink)

	# === SAVE ===
	ResourceSaver.save(theme, "res://client/ui/theme/dracula_theme.tres")
	print("Theme saved to res://client/ui/theme/dracula_theme.tres")
