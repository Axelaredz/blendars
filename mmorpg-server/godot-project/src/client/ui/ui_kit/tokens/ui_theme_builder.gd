# res://client/ui/ui_kit/tokens/ui_theme_builder.gd
class_name UiThemeBuilder
extends RefCounted

## Строит Theme resource из токенов.
## Вызывается ОДИН раз при старте.
## Результат кэшируется и переиспользуется.

static var _cached_theme: Theme = null


static func get_theme() -> Theme:
    if _cached_theme:
        return _cached_theme
    _cached_theme = _build()
    return _cached_theme


static func _build() -> Theme:
    var theme := Theme.new()

    # ══════════════════════════════════
    #  Шрифты по умолчанию
    # ══════════════════════════════════

    var font_body: Font = load(UiTokens.FONT_PATH_BODY_SEMI)
    var font_mono: Font = load(UiTokens.FONT_PATH_MONO)
    var font_heading: Font = load(UiTokens.FONT_PATH_HEADING)

    theme.default_font = font_body
    theme.default_font_size = UiTokens.FONT_SIZE_BODY

    # ══════════════════════════════════
    #  Label — базовый
    # ══════════════════════════════════

    theme.set_color("font_color", "Label",
        UiTokens.COLOR_TEXT_PRIMARY)
    theme.set_color("font_shadow_color", "Label",
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.15))
    theme.set_constant("shadow_offset_x", "Label", 0)
    theme.set_constant("shadow_offset_y", "Label", 0)
    # Тень = glow эффект при offset 0,0

    # ══════════════════════════════════
    #  Type Variations — КЛЮЧЕВАЯ ФИЧА
    # ══════════════════════════════════

    # --- LabelSecondary ---
    theme.add_type("LabelSecondary")
    theme.set_type_variation("LabelSecondary", "Label")
    theme.set_color("font_color", "LabelSecondary",
        UiTokens.COLOR_TEXT_SECONDARY)
    theme.set_font_size("font_size", "LabelSecondary",
        UiTokens.FONT_SIZE_BODY_SM)

    # --- LabelDisabled ---
    theme.add_type("LabelDisabled")
    theme.set_type_variation("LabelDisabled", "Label")
    theme.set_color("font_color", "LabelDisabled",
        UiTokens.COLOR_TEXT_DISABLED)

    # --- LabelAccent ---
    theme.add_type("LabelAccent")
    theme.set_type_variation("LabelAccent", "Label")
    theme.set_color("font_color", "LabelAccent",
        UiTokens.COLOR_ACCENT_PRIMARY)
    theme.set_color("font_shadow_color", "LabelAccent",
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.3))

    # --- LabelHeading ---
    theme.add_type("LabelHeading")
    theme.set_type_variation("LabelHeading", "Label")
    theme.set_font("font", "LabelHeading", font_heading)
    theme.set_font_size("font_size", "LabelHeading",
        UiTokens.FONT_SIZE_HEADING_MD)
    theme.set_color("font_color", "LabelHeading",
        UiTokens.COLOR_TEXT_PRIMARY)

    # --- LabelDisplay (10% — заголовок игры) ---
    theme.add_type("LabelDisplay")
    theme.set_type_variation("LabelDisplay", "Label")
    theme.set_font("font", "LabelDisplay", font_heading)
    theme.set_font_size("font_size", "LabelDisplay",
        UiTokens.FONT_SIZE_DISPLAY)
    theme.set_color("font_color", "LabelDisplay",
        UiTokens.COLOR_TEXT_PRIMARY)
    theme.set_color("font_shadow_color", "LabelDisplay",
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.4))

    # --- LabelHUD (10% — моно, системный) ---
    theme.add_type("LabelHUD")
    theme.set_type_variation("LabelHUD", "Label")
    theme.set_font("font", "LabelHUD", font_mono)
    theme.set_font_size("font_size", "LabelHUD",
        UiTokens.FONT_SIZE_HUD)
    theme.set_color("font_color", "LabelHUD",
        UiTokens.COLOR_TEXT_DISABLED)

    # --- LabelMicro ---
    theme.add_type("LabelMicro")
    theme.set_type_variation("LabelMicro", "Label")
    theme.set_font("font", "LabelMicro", font_mono)
    theme.set_font_size("font_size", "LabelMicro",
        UiTokens.FONT_SIZE_MICRO)
    theme.set_color("font_color", "LabelMicro",
        Color(UiTokens.COLOR_TEXT_DISABLED, 0.5))

    # ══════════════════════════════════
    #  Button
    # ══════════════════════════════════

    var btn_normal := _make_btn_style(
        UiTokens.COLOR_SURFACE,
        UiTokens.COLOR_SURFACE_BORDER)
    var btn_hover := _make_btn_style(
        UiTokens.COLOR_SURFACE_ACTIVE,
        UiTokens.COLOR_ACCENT_PRIMARY)
    var btn_pressed := _make_btn_style(
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.2),
        UiTokens.COLOR_ACCENT_PRIMARY)
    var btn_disabled := _make_btn_style(
        Color(UiTokens.COLOR_SURFACE, 0.3),
        Color(UiTokens.COLOR_SURFACE_BORDER, 0.3))
    var btn_focus := btn_hover.duplicate()

    theme.set_stylebox("normal", "Button", btn_normal)
    theme.set_stylebox("hover", "Button", btn_hover)
    theme.set_stylebox("pressed", "Button", btn_pressed)
    theme.set_stylebox("disabled", "Button", btn_disabled)
    theme.set_stylebox("focus", "Button", btn_focus)

    theme.set_color("font_color", "Button",
        UiTokens.COLOR_TEXT_PRIMARY)
    theme.set_color("font_hover_color", "Button",
        UiTokens.COLOR_ACCENT_PRIMARY)
    theme.set_color("font_pressed_color", "Button",
        UiTokens.COLOR_ACCENT_PRIMARY)
    theme.set_color("font_disabled_color", "Button",
        UiTokens.COLOR_TEXT_DISABLED)

    # --- CyberButton (вариация с неоновой рамкой) ---
    theme.add_type("CyberButton")
    theme.set_type_variation("CyberButton", "Button")

    var cyber_normal := _make_btn_style(
        Color.TRANSPARENT,
        UiTokens.COLOR_ACCENT_PRIMARY, 1)
    var cyber_hover := _make_btn_style(
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.1),
        UiTokens.COLOR_ACCENT_PRIMARY, 2)
    var cyber_pressed := _make_btn_style(
        Color(UiTokens.COLOR_ACCENT_PRIMARY, 0.25),
        UiTokens.COLOR_ACCENT_PRIMARY, 2)

    theme.set_stylebox("normal", "CyberButton", cyber_normal)
    theme.set_stylebox("hover", "CyberButton", cyber_hover)
    theme.set_stylebox("pressed", "CyberButton", cyber_pressed)

    # --- DangerButton ---
    theme.add_type("DangerButton")
    theme.set_type_variation("DangerButton", "Button")

    var danger_normal := _make_btn_style(
        Color.TRANSPARENT,
        UiTokens.COLOR_ACCENT_DANGER, 1)
    var danger_hover := _make_btn_style(
        Color(UiTokens.COLOR_ACCENT_DANGER, 0.1),
        UiTokens.COLOR_ACCENT_DANGER, 2)

    theme.set_stylebox("normal", "DangerButton", danger_normal)
    theme.set_stylebox("hover", "DangerButton", danger_hover)
    theme.set_color("font_color", "DangerButton",
        UiTokens.COLOR_ACCENT_DANGER)

    # ══════════════════════════════════
    #  PanelContainer
    # ══════════════════════════════════

    var panel_style := UiTokens.make_stylebox_flat(
        UiTokens.COLOR_BG_ELEVATED,
        UiTokens.COLOR_SURFACE_BORDER,
        UiTokens.BORDER_WIDTH_THIN)
    theme.set_stylebox("panel", "PanelContainer", panel_style)

    # --- PanelTransparent ---
    theme.add_type("PanelTransparent")
    theme.set_type_variation("PanelTransparent", "PanelContainer")
    theme.set_stylebox("panel", "PanelTransparent",
        StyleBoxEmpty.new())

    # --- PanelSurface ---
    theme.add_type("PanelSurface")
    theme.set_type_variation("PanelSurface", "PanelContainer")
    var surface_style := UiTokens.make_stylebox_flat(
        UiTokens.COLOR_SURFACE,
        UiTokens.COLOR_SURFACE_BORDER,
        UiTokens.BORDER_WIDTH_THIN,
        UiTokens.RADIUS_SM)
    theme.set_stylebox("panel", "PanelSurface", surface_style)

    # ══════════════════════════════════
    #  Separator
    # ══════════════════════════════════

    var sep_style := StyleBoxFlat.new()
    sep_style.bg_color = UiTokens.COLOR_SURFACE_BORDER
    sep_style.content_margin_top = 0
    sep_style.content_margin_bottom = 0
    theme.set_stylebox("separator", "HSeparator", sep_style)
    theme.set_constant("separation", "HSeparator", 1)

    # ══════════════════════════════════
    #  ProgressBar
    # ══════════════════════════════════

    var prog_bg := StyleBoxFlat.new()
    prog_bg.bg_color = UiTokens.COLOR_SURFACE
    prog_bg.corner_radius_top_left = 1
    prog_bg.corner_radius_top_right = 1
    prog_bg.corner_radius_bottom_left = 1
    prog_bg.corner_radius_bottom_right = 1

    var prog_fill := prog_bg.duplicate()
    prog_fill.bg_color = UiTokens.COLOR_ACCENT_PRIMARY

    theme.set_stylebox("background", "ProgressBar", prog_bg)
    theme.set_stylebox("fill", "ProgressBar", prog_fill)

    # ══════════════════════════════════
    #  HSlider
    # ══════════════════════════════════

    var slider_bg := StyleBoxFlat.new()
    slider_bg.bg_color = UiTokens.COLOR_SURFACE
    slider_bg.content_margin_top = 2
    slider_bg.content_margin_bottom = 2

    var slider_fill := slider_bg.duplicate()
    slider_fill.bg_color = UiTokens.COLOR_ACCENT_PRIMARY

    theme.set_stylebox("slider", "HSlider", slider_bg)
    theme.set_stylebox("grabber_area", "HSlider", slider_fill)

    # ══════════════════════════════════
    #  ScrollBar, LineEdit, etc.
    # ══════════════════════════════════

    _style_line_edit(theme)
    _style_scroll(theme)

    return theme


# ── Хелперы ──

static func _make_btn_style(
    bg: Color,
    border: Color,
    border_w: int = 0
) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.set_border_width_all(border_w)
    sb.set_corner_radius_all(UiTokens.RADIUS_SM)
    sb.content_margin_left = UiTokens.SPACE_LG
    sb.content_margin_right = UiTokens.SPACE_LG
    sb.content_margin_top = UiTokens.SPACE_SM
    sb.content_margin_bottom = UiTokens.SPACE_SM
    return sb


static func _style_line_edit(theme: Theme) -> void:
    var le_normal := UiTokens.make_stylebox_flat(
        UiTokens.COLOR_SURFACE,
        UiTokens.COLOR_SURFACE_BORDER,
        UiTokens.BORDER_WIDTH_THIN,
        UiTokens.RADIUS_SM,
        UiTokens.SPACE_SM)
    var le_focus := le_normal.duplicate()
    le_focus.border_color = UiTokens.COLOR_ACCENT_PRIMARY

    theme.set_stylebox("normal", "LineEdit", le_normal)
    theme.set_stylebox("focus", "LineEdit", le_focus)
    theme.set_color("font_color", "LineEdit",
        UiTokens.COLOR_TEXT_PRIMARY)
    theme.set_color("font_placeholder_color", "LineEdit",
        UiTokens.COLOR_TEXT_DISABLED)
    theme.set_color("caret_color", "LineEdit",
        UiTokens.COLOR_ACCENT_PRIMARY)


static func _style_scroll(theme: Theme) -> void:
    var scroll_bg := StyleBoxFlat.new()
    scroll_bg.bg_color = UiTokens.COLOR_BG_SECONDARY
    var scroll_grab := StyleBoxFlat.new()
    scroll_grab.bg_color = UiTokens.COLOR_SURFACE_BORDER
    scroll_grab.set_corner_radius_all(2)

    theme.set_stylebox("scroll", "VScrollBar", scroll_bg)
    theme.set_stylebox("grabber", "VScrollBar", scroll_grab)