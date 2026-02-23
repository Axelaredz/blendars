# res://client/ui/ui_kit/tokens/ui_tokens.gd
# AUTOLOAD: Project → Project Settings → Autoload → "UiTokens"
#
# ПРАВИЛО: ВСЕ компоненты UI берут значения ТОЛЬКО отсюда.
# ЗАПРЕЩЕНО хардкодить цвета, размеры, шрифты в компонентах.

class_name UiTokensClass
extends Node

#  🎨 ЦВЕТА — правило 70/20/10

# --- 70% ДОМИНИРУЮЩИЕ (тёмная база) ---
const COLOR_BG_PRIMARY := Color("#0A0A0F")       # глубокий чёрный
const COLOR_BG_SECONDARY := Color("#0D1117")     # тёмно-синий
const COLOR_BG_ELEVATED := Color("#151B23")       # приподнятые панели
const COLOR_BG_HOVER := Color("#1A3A4A33")        # hover-подложка (20% alpha)

# --- 20% ВТОРИЧНЫЕ (средние тона) ---
const COLOR_SURFACE := Color("#1A1F2E")           # поверхность карточек
const COLOR_SURFACE_BORDER := Color("#2A2D35")    # границы
const COLOR_SURFACE_ACTIVE := Color("#1A3A4A")    # активная поверхность
const COLOR_SURFACE_HIGHLIGHT := Color("#243447") # подсветка строки

# --- 10% АКЦЕНТЫ (неон) ---
const COLOR_ACCENT_PRIMARY := Color("#00F0FF")    # циан
const COLOR_ACCENT_SECONDARY := Color("#FF00AA")  # маджента
const COLOR_ACCENT_TERTIARY := Color("#00FF88")   # зелёный
const COLOR_ACCENT_WARNING := Color("#FFB800")    # жёлтый
const COLOR_ACCENT_DANGER := Color("#FF2244")     # красный

# --- ТЕКСТ ---
const COLOR_TEXT_PRIMARY := Color("#E0F0FF")       # основной
const COLOR_TEXT_SECONDARY := Color("#8899AA")     # вторичный
const COLOR_TEXT_DISABLED := Color("#445566")       # неактивный
const COLOR_TEXT_ACCENT := Color("#00F0FF")         # акцентный


#  📏 ПРОСТРАНСТВО (кратно 4px ВСЕГДА)

const SPACE_2XS := 2
const SPACE_XS := 4
const SPACE_SM := 8
const SPACE_MD := 12
const SPACE_LG := 16
const SPACE_XL := 24
const SPACE_2XL := 32
const SPACE_3XL := 48
const SPACE_4XL := 64

#  ✏️ ТИПОГРАФИКА
# --- Размеры шрифтов ---
const FONT_SIZE_MICRO := 9       # HUD-маркеры, декор
const FONT_SIZE_HUD := 10        # системные подписи
const FONT_SIZE_LABEL := 11      # лейблы
const FONT_SIZE_BODY_SM := 12    # мелкий текст
const FONT_SIZE_BODY := 14       # основной текст (70%)
const FONT_SIZE_HEADING_SM := 14 # малый заголовок
const FONT_SIZE_HEADING_MD := 18 # средний заголовок (20%)
const FONT_SIZE_HEADING_LG := 24 # большой заголовок
const FONT_SIZE_DISPLAY := 36    # логотип, название (10%)

# --- Letter spacing ---
const TRACKING_TIGHT := -0.02
const TRACKING_NORMAL := 0.0
const TRACKING_WIDE := 0.05
const TRACKING_ULTRA := 0.15

# --- Пути к шрифтам ---
const FONT_PATH_BODY := "res://client/ui/ui_kit/assets/fonts/font_body.tres"
const FONT_PATH_BODY_SEMI := "res://client/ui/ui_kit/assets/fonts/font_body_semi.tres"
const FONT_PATH_HEADING := "res://client/ui/ui_kit/assets/fonts/font_heading.tres"
const FONT_PATH_DISPLAY := "res://client/ui/ui_kit/assets/fonts/font_display.tres"
const FONT_PATH_MONO := "res://client/ui/ui_kit/assets/fonts/font_mono.tres"

#  🔲 РАЗМЕРЫ И ФОРМЫ

const RADIUS_NONE := 0
const RADIUS_SM := 2
const RADIUS_MD := 4

const BORDER_WIDTH_THIN := 1
const BORDER_WIDTH_ACCENT := 2
const ACCENT_BAR_WIDTH := 3

const ICON_SIZE_SM := 16
const ICON_SIZE_MD := 20
const ICON_SIZE_LG := 24

#  💫 АНИМАЦИЯ

const ANIM_DURATION_INSTANT := 0.08  # мгновенная реакция
const ANIM_DURATION_FAST := 0.15     # hover, focus
const ANIM_DURATION_NORMAL := 0.25   # переходы
const ANIM_DURATION_SLOW := 0.4      # появление панелей
const ANIM_DURATION_CINEMATIC := 0.8 # экранные переходы

const ANIM_EASE_DEFAULT := Tween.EASE_OUT
const ANIM_TRANS_DEFAULT := Tween.TRANS_CUBIC
const ANIM_TRANS_BOUNCE := Tween.TRANS_BACK


#  📊 POST-FX НАСТРОЙКИ (10% правило)

const FX_SCANLINE_OPACITY := 0.08    # еле заметные
const FX_NOISE_OPACITY := 0.04       # минимальный
const FX_VIGNETTE_INTENSITY := 0.5   # мягкое затемнение
const FX_CHROMATIC_STRENGTH := 0.002 # только на краях


#  🛠️ HELPER-МЕТОДЫ

## Создаёт StyleBoxFlat с токенами
func make_stylebox_flat(
	bg_color: Color = COLOR_BG_ELEVATED,
	border_color: Color = Color.TRANSPARENT,
	border_width: int = 0,
	corner_radius: int = RADIUS_SM,
	content_margins: int = SPACE_MD
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.border_width_left = border_width
	sb.border_width_right = border_width
	sb.border_width_top = border_width
	sb.border_width_bottom = border_width
	sb.corner_radius_top_left = corner_radius
	sb.corner_radius_top_right = corner_radius
	sb.corner_radius_bottom_left = corner_radius
	sb.corner_radius_bottom_right = corner_radius
	sb.content_margin_left = content_margins
	sb.content_margin_right = content_margins
	sb.content_margin_top = content_margins
	sb.content_margin_bottom = content_margins
	return sb

## Создаёт StyleBoxFlat для hover с акцентной левой полосой
func make_stylebox_hover(
	accent_color: Color = COLOR_ACCENT_PRIMARY
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_BG_HOVER
	sb.border_color = accent_color
	sb.border_width_left = ACCENT_BAR_WIDTH
	sb.border_width_right = 0
	sb.border_width_top = 0
	sb.border_width_bottom = 0
	sb.corner_radius_top_left = 0
	sb.corner_radius_top_right = RADIUS_SM
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = RADIUS_SM
	sb.content_margin_left = SPACE_LG
	sb.content_margin_right = SPACE_LG
	sb.content_margin_top = SPACE_MD
	sb.content_margin_bottom = SPACE_MD
	return sb


## Создаёт пустой StyleBoxEmpty
func make_stylebox_empty(margins: int = 0) -> StyleBoxEmpty:
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = margins
	sb.content_margin_right = margins
	sb.content_margin_top = margins
	sb.content_margin_bottom = margins
	return sb


## Универсальный tween для UI-элементов
func tween_property(
	node: Node,
	property: String,
	value: Variant,
	duration: float = ANIM_DURATION_FAST
) -> Tween:
	var tw := node.create_tween()
	tw.set_ease(ANIM_EASE_DEFAULT)
	tw.set_trans(ANIM_TRANS_DEFAULT)
	tw.tween_property(node, property, value, duration)
	return tw