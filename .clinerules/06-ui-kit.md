

# BLEND ARS — Правила модульного UI для Godot 4.6
## Инструкция для ИИ-агента

---

## 📋 ПРЕАМБУЛА

```
ТЫ — AI-агент, создающий модульный UI kit в Godot 4.6.
Стиль: киберпанк / sci-fi.
Проект: игра "BLEND ARS".

ВСЕГДА следуй этому документу как единственному источнику правды.
При конфликте между "красиво" и "модульно" — выбирай МОДУЛЬНО.
При конфликте между "сложно" и "просто" — выбирай ПРОСТО.

Язык: GDScript (НЕ C#).
Версия: Godot 4.6 stable.
```

---

## 🏗️ АРХИТЕКТУРА ПРОЕКТА

### Файловая структура — ОБЯЗАТЕЛЬНАЯ

```
res://
│
├── 📁 ui_kit/
│   │
│   ├── 📁 tokens/
│   │   ├── ui_tokens.gd              ← Autoload: все переменные
│   │   ├── ui_colors.tres            ← Resource: палитра
│   │   └── ui_theme.tres             ← главная Theme
│   │
│   ├── 📁 atoms/
│   │   ├── text_body.tscn            ← Label с пресетом
│   │   ├── text_label.tscn           ← Label uppercase
│   │   ├── text_display.tscn         ← заголовок с glow
│   │   ├── text_hud.tscn             ← моноширинный HUD
│   │   ├── icon_element.tscn         ← TextureRect
│   │   ├── divider.tscn              ← HSeparator
│   │   ├── divider_glow.tscn         ← с шейдером
│   │   ├── accent_bar.tscn           ← ColorRect 3px
│   │   ├── dot_indicator.tscn        ← статус-точка
│   │   └── scanline_overlay.tscn     ← полноэкранный CRT
│   │
│   ├── 📁 molecules/
│   │   ├── menu_item.tscn
│   │   ├── menu_item.gd
│   │   ├── hotkey_hint.tscn
│   │   ├── hotkey_hint.gd
│   │   ├── stat_line.tscn
│   │   ├── stat_line.gd
│   │   ├── icon_button.tscn
│   │   ├── icon_button.gd
│   │   ├── tab_item.tscn
│   │   ├── toggle_switch.tscn
│   │   ├── cyber_slider.tscn
│   │   └── cyber_dropdown.tscn
│   │
│   ├── 📁 organisms/
│   │   ├── main_nav.tscn
│   │   ├── main_nav.gd
│   │   ├── title_bar.tscn
│   │   ├── title_bar.gd
│   │   ├── hotkey_bar.tscn
│   │   ├── hotkey_bar.gd
│   │   ├── unit_card.tscn
│   │   ├── settings_group.tscn
│   │   ├── modal_dialog.tscn
│   │   └── notification_toast.tscn
│   │
│   ├── 📁 templates/
│   │   ├── layout_main_menu.tscn
│   │   ├── layout_arsenal.tscn
│   │   ├── layout_settings.tscn
│   │   └── layout_loading.tscn
│   │
│   ├── 📁 fx/
│   │   ├── crt_scanlines.gdshader
│   │   ├── noise_grain.gdshader
│   │   ├── vignette.gdshader
│   │   ├── chromatic_aberration.gdshader
│   │   ├── glow_text.gdshader
│   │   ├── glitch.gdshader
│   │   └── post_fx_layer.tscn         ← комбинированный
│   │
│   └── 📁 assets/
│       ├── 📁 fonts/
│       │   ├── Exo2-Italic.ttf
│       │   ├── Exo2-SemiBoldItalic.ttf
│       │   ├── Exo2-BoldItalic.ttf
│       │   ├── JetBrainsMono-Regular.ttf
│       │   ├── font_body.tres          ← FontFile resource
│       │   ├── font_body_semi.tres
│       │   ├── font_heading.tres
│       │   ├── font_display.tres
│       │   └── font_mono.tres
│       ├── 📁 icons/
│       │   └── *.svg
│       └── 📁 textures/
│           └── noise_512.png
│
├── 📁 screens/
│   ├── main_menu.tscn
│   ├── main_menu.gd
│   ├── arsenal_screen.tscn
│   └── settings_screen.tscn
│
└── project.godot
```

---

## 1️⃣ TOKENS — Единственный источник правды

### ui_tokens.gd — AUTOLOAD (Singleton)

```gdscript
# res://ui_kit/tokens/ui_tokens.gd
# AUTOLOAD: Project → Project Settings → Autoload → "UiTokens"
#
# ПРАВИЛО: ВСЕ компоненты UI берут значения ТОЛЬКО отсюда.
# ЗАПРЕЩЕНО хардкодить цвета, размеры, шрифты в компонентах.

class_name UiTokensClass
extends Node


# ══════════════════════════════════════════
#  🎨 ЦВЕТА — правило 70/20/10
# ══════════════════════════════════════════

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


# ══════════════════════════════════════════
#  📏 ПРОСТРАНСТВО (кратно 4px ВСЕГДА)
# ══════════════════════════════════════════

const SPACE_2XS := 2
const SPACE_XS := 4
const SPACE_SM := 8
const SPACE_MD := 12
const SPACE_LG := 16
const SPACE_XL := 24
const SPACE_2XL := 32
const SPACE_3XL := 48
const SPACE_4XL := 64


# ══════════════════════════════════════════
#  ✏️ ТИПОГРАФИКА
# ══════════════════════════════════════════

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
const FONT_PATH_BODY := "res://ui_kit/assets/fonts/font_body.tres"
const FONT_PATH_BODY_SEMI := "res://ui_kit/assets/fonts/font_body_semi.tres"
const FONT_PATH_HEADING := "res://ui_kit/assets/fonts/font_heading.tres"
const FONT_PATH_DISPLAY := "res://ui_kit/assets/fonts/font_display.tres"
const FONT_PATH_MONO := "res://ui_kit/assets/fonts/font_mono.tres"


# ══════════════════════════════════════════
#  🔲 РАЗМЕРЫ И ФОРМЫ
# ══════════════════════════════════════════

const RADIUS_NONE := 0
const RADIUS_SM := 2
const RADIUS_MD := 4

const BORDER_WIDTH_THIN := 1
const BORDER_WIDTH_ACCENT := 2
const ACCENT_BAR_WIDTH := 3

const ICON_SIZE_SM := 16
const ICON_SIZE_MD := 20
const ICON_SIZE_LG := 24


# ══════════════════════════════════════════
#  💫 АНИМАЦИЯ
# ══════════════════════════════════════════

const ANIM_DURATION_INSTANT := 0.08  # мгновенная реакция
const ANIM_DURATION_FAST := 0.15     # hover, focus
const ANIM_DURATION_NORMAL := 0.25   # переходы
const ANIM_DURATION_SLOW := 0.4      # появление панелей
const ANIM_DURATION_CINEMATIC := 0.8 # экранные переходы

const ANIM_EASE_DEFAULT := Tween.EASE_OUT
const ANIM_TRANS_DEFAULT := Tween.TRANS_CUBIC
const ANIM_TRANS_BOUNCE := Tween.TRANS_BACK


# ══════════════════════════════════════════
#  📊 POST-FX НАСТРОЙКИ (10% правило)
# ══════════════════════════════════════════

const FX_SCANLINE_OPACITY := 0.08    # еле заметные
const FX_NOISE_OPACITY := 0.04       # минимальный
const FX_VIGNETTE_INTENSITY := 0.5   # мягкое затемнение
const FX_CHROMATIC_STRENGTH := 0.002 # только на краях


# ══════════════════════════════════════════
#  🛠️ HELPER-МЕТОДЫ
# ══════════════════════════════════════════

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
```

---

## 2️⃣ ATOMS — Атомы

### Правила создания атомов

```
ПРАВИЛО АТОМА:
1. Один .tscn файл = ОДИН визуальный элемент
2. Атом НЕ содержит бизнес-логики
3. Атом НЕ знает о своём контексте
4. Атом берёт ВСЕ стили из UiTokens
5. Скрипт атома — ТОЛЬКО настройка внешнего вида
6. @export переменные для кастомизации из инспектора
7. Корневой узел — ВСЕГДА Control (или наследник)
```

### Atom: TextBody

**Дерево узлов:**
```
TextBody (Label)
```

```gdscript
# res://ui_kit/atoms/text_body.gd
@tool
class_name AtomTextBody
extends Label

## Атом: основной текст интерфейса.
## Использует Exo 2 SemiBold Italic, 14px.
## Это 70% всей типографики в интерфейсе.

@export var text_color_override: Color = Color.TRANSPARENT:
	set(value):
		text_color_override = value
		_apply_style()

@export_enum("primary", "secondary", "disabled", "accent") 
var color_preset: String = "primary":
	set(value):
		color_preset = value
		_apply_style()

@export var enable_glow: bool = false:
	set(value):
		enable_glow = value
		_apply_style()


func _ready() -> void:
	_apply_style()


func _apply_style() -> void:
	# Шрифт
	var font_res := load(UiTokens.FONT_PATH_BODY_SEMI) as Font
	if font_res:
		add_theme_font_override("font", font_res)
	
	add_theme_font_size_override("font_size", UiTokens.FONT_SIZE_BODY)
	
	# Цвет по пресету
	var target_color: Color
	if text_color_override != Color.TRANSPARENT:
		target_color = text_color_override
	else:
		match color_preset:
			"primary":
				target_color = UiTokens.COLOR_TEXT_PRIMARY
			"secondary":
				target_color = UiTokens.COLOR_TEXT_SECONDARY
			"disabled":
				target_color = UiTokens.COLOR_TEXT_DISABLED
			"accent":
				target_color = UiTokens.COLOR_ACCENT_PRIMARY
	
	add_theme_color_override("font_color", target_color)
	
	# Свечение через шейдер (10% правило — только когда enable_glow=true)
	if enable_glow and not material:
		var shader := load("res://ui_kit/fx/glow_text.gdshader") as Shader
		if shader:
			var mat := ShaderMaterial.new()
			mat.shader = shader
			mat.set_shader_parameter("glow_color", UiTokens.COLOR_ACCENT_PRIMARY)
			mat.set_shader_parameter("glow_strength", 0.3)
			material = mat
	elif not enable_glow:
		material = null
```

### Atom: AccentBar

**Дерево узлов:**
```
AccentBar (ColorRect)
```

```gdscript
# res://ui_kit/atoms/accent_bar.gd
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
```

### Atom: Divider

**Дерево узлов:**
```
Divider (ColorRect)
```

```gdscript
# res://ui_kit/atoms/divider.gd
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
```

### Atom: DotIndicator

```gdscript
# res://ui_kit/atoms/dot_indicator.gd
@tool
class_name AtomDotIndicator
extends ColorRect

## Атом: круглый индикатор статуса.

@export_enum("online", "offline", "warning", "danger")
var status: String = "online":
	set(value):
		status = value
		_apply_color()

const STATUS_COLORS := {
	"online": UiTokens.COLOR_ACCENT_TERTIARY,
	"offline": UiTokens.COLOR_TEXT_DISABLED,
	"warning": UiTokens.COLOR_ACCENT_WARNING,
	"danger": UiTokens.COLOR_ACCENT_DANGER,
}

func _ready() -> void:
	custom_minimum_size = Vector2(8, 8)
	size = Vector2(8, 8)
	# Делаем круглым через шейдер
	var shader_code := "
		shader_type canvas_item;
		void fragment() {
			float dist = distance(UV, vec2(0.5));
			if (dist > 0.5) discard;
		}
	"
	var shader := Shader.new()
	shader.code = shader_code
	material = ShaderMaterial.new()
	material.shader = shader
	_apply_color()


func _apply_color() -> void:
	if STATUS_COLORS.has(status):
		color = STATUS_COLORS[status]
```

---

## 3️⃣ MOLECULES — Молекулы

### Правила создания молекул

```
ПРАВИЛО МОЛЕКУЛЫ:
1. Собирается из 2-5 атомов (инстансы .tscn)
2. Имеет ОДНУ функциональную задачу
3. Управляет состояниями своих атомов (hover, active, disabled)
4. Испускает сигналы НАВЕРХ, не вызывает методы родителя
5. Принимает данные через @export или set-методы
6. НЕ знает о своём контексте (в каком организме живёт)
7. Обязательные состояния для интерактивных:
   - default
   - hover (mouse_entered)
   - pressed
   - focused (keyboard navigation)
   - disabled
```

### Molecule: MenuItem

**Дерево узлов:**
```
MenuItem (PanelContainer)
├── HBox (HBoxContainer)
│   ├── AccentBar (AtomAccentBar.tscn)
│   ├── Icon (TextureRect) — опционально
│   └── Label (AtomTextBody.tscn)
```

```gdscript
# res://ui_kit/molecules/menu_item.gd
@tool
class_name MoleculeMenuItem
extends PanelContainer

## Молекула: пункт меню.
## Состоит из AccentBar + опциональной иконки + текста.
## Испускает сигнал при клике. Поддерживает keyboard navigation.

signal item_pressed(item_id: String)
signal item_hovered(item_id: String)

@export var item_id: String = ""
@export var label_text: String = "МЕНЮ":
	set(value):
		label_text = value
		if _label:
			_label.text = value

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if _icon:
			_icon.texture = value
			_icon.visible = value != null

@export var is_active: bool = false:
	set(value):
		is_active = value
		_update_state()

@export var is_disabled: bool = false:
	set(value):
		is_disabled = value
		_update_state()

@export_enum("default", "danger") var variant: String = "default"

# Ноды
@onready var _hbox: HBoxContainer = %HBox
@onready var _accent_bar: AtomAccentBar = %AccentBar
@onready var _icon: TextureRect = %Icon
@onready var _label: Label = %Label

# State
var _is_hovered: bool = false

# StyleBox кэш
var _style_default: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_active: StyleBoxFlat
var _style_disabled: StyleBoxFlat


func _ready() -> void:
	_build_styles()
	_setup_signals()
	_update_state()
	
	# Настройка Label
	_label.text = label_text
	_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY_SEMI))
	_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_BODY)
	
	# Настройка Icon
	if _icon:
		_icon.custom_minimum_size = Vector2(
			UiTokens.ICON_SIZE_MD, UiTokens.ICON_SIZE_MD)
		_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_icon.visible = icon_texture != null
	
	# Контейнер
	custom_minimum_size.y = 44
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _build_styles() -> void:
	# DEFAULT — прозрачный фон
	_style_default = UiTokens.make_stylebox_empty(UiTokens.SPACE_LG)
	
	# HOVER — подсветка + акцентная полоса
	_style_hover = UiTokens.make_stylebox_hover(
		UiTokens.COLOR_ACCENT_DANGER if variant == "danger"
		else UiTokens.COLOR_ACCENT_PRIMARY
	)
	
	# ACTIVE — более яркий
	_style_active = UiTokens.make_stylebox_flat(
		UiTokens.COLOR_BG_HOVER,
		UiTokens.COLOR_ACCENT_PRIMARY,
		UiTokens.ACCENT_BAR_WIDTH
	)
	_style_active.border_width_right = 0
	_style_active.border_width_top = 0
	_style_active.border_width_bottom = 0
	
	# DISABLED — тусклый
	_style_disabled = UiTokens.make_stylebox_empty(UiTokens.SPACE_LG)


func _setup_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _update_state() -> void:
	if not is_inside_tree():
		return
	
	if is_disabled:
		add_theme_stylebox_override("panel", _style_disabled)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_TEXT_DISABLED)
		_accent_bar.hide_bar()
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		return
	
	if is_active:
		add_theme_stylebox_override("panel", _style_active)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_ACCENT_PRIMARY)
		_accent_bar.accent_color = UiTokens.COLOR_ACCENT_PRIMARY
		_accent_bar.show_bar()
		return
	
	if _is_hovered:
		add_theme_stylebox_override("panel", _style_hover)
		_label.add_theme_color_override("font_color",
			UiTokens.COLOR_TEXT_PRIMARY)
		var hover_color: Color = (
			UiTokens.COLOR_ACCENT_DANGER if variant == "danger"
			else UiTokens.COLOR_ACCENT_PRIMARY
		)
		_accent_bar.accent_color = hover_color
		_accent_bar.show_bar()
		return
	
	# DEFAULT
	add_theme_stylebox_override("panel", _style_default)
	_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_SECONDARY)
	_accent_bar.hide_bar()


func _on_mouse_entered() -> void:
	if is_disabled:
		return
	_is_hovered = true
	_update_state()
	item_hovered.emit(item_id)


func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_state()


func _on_focus_entered() -> void:
	if is_disabled:
		return
	_is_hovered = true
	_update_state()
	item_hovered.emit(item_id)


func _on_focus_exited() -> void:
	_is_hovered = false
	_update_state()


func _on_gui_input(event: InputEvent) -> void:
	if is_disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_do_press()
	
	if event is InputEventKey:
		if event.keycode == KEY_ENTER and event.pressed:
			_do_press()


func _do_press() -> void:
	# Мини-анимация нажатия (10% яркий эффект)
	var tw := create_tween()
	tw.tween_property(_label, "modulate",
		Color(1.5, 1.5, 1.5), UiTokens.ANIM_DURATION_INSTANT)
	tw.tween_property(_label, "modulate",
		Color.WHITE, UiTokens.ANIM_DURATION_FAST)
	
	item_pressed.emit(item_id)
```

### Molecule: HotkeyHint

**Дерево узлов:**
```
HotkeyHint (HBoxContainer)
├── KeyBadge (PanelContainer)
│   └── KeyLabel (Label)
└── ActionLabel (Label)
```

```gdscript
# res://ui_kit/molecules/hotkey_hint.gd
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
```

### Molecule: StatLine

**Дерево узлов:**
```
StatLine (HBoxContainer)
├── StatLabel (Label)
├── ProgressBar (ProgressBar)
└── StatValue (Label)
```

```gdscript
# res://ui_kit/molecules/stat_line.gd
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
```

---

## 4️⃣ ORGANISMS — Организмы

### Правила создания организмов

```
ПРАВИЛО ОРГАНИЗМА:
1. Собирается из молекул и атомов
2. Самодостаточный блок интерфейса
3. Может содержать бизнес-логику своего блока
4. Управляет коллекцией дочерних молекул
5. Испускает агрегированные сигналы
6. Может динамически создавать/удалять молекулы
7. Отвечает за LAYOUT своих детей (spacing, alignment)
```

### Organism: MainNav

**Дерево узлов:**
```
MainNav (PanelContainer)
└── VBox (VBoxContainer)
    ├── SectionLabel (AtomTextLabel) — "НАВИГАЦИЯ"
    ├── ItemsContainer (VBoxContainer)
    │   ├── MenuItem_1 (instance)
    │   ├── MenuItem_2 (instance)
    │   ├── MenuItem_3 (instance)
    │   └── MenuItem_4 (instance)
    ├── Divider (AtomDivider)
    └── ExitItem (MoleculeMenuItem, variant=danger)
```

```gdscript
# res://ui_kit/organisms/main_nav.gd
class_name OrganismMainNav
extends PanelContainer

## Организм: вертикальная навигационная панель.
## Управляет коллекцией MenuItem.
## Обеспечивает keyboard navigation (↑↓, Enter).

signal navigation_selected(item_id: String)
signal navigation_hovered(item_id: String)

## Определение пунктов меню
@export var menu_items: Array[Dictionary] = []:
	set(value):
		menu_items = value
		if is_inside_tree():
			_rebuild_items()

# Сцена молекулы
const MENU_ITEM_SCENE := preload("res://ui_kit/molecules/menu_item.tscn")
const DIVIDER_SCENE := preload("res://ui_kit/atoms/divider.tscn")

@onready var _vbox: VBoxContainer = %VBox
@onready var _section_label: Label = %SectionLabel
@onready var _items_container: VBoxContainer = %ItemsContainer
@onready var _exit_item: MoleculeMenuItem = %ExitItem

var _item_nodes: Array[MoleculeMenuItem] = []
var _focused_index: int = -1
var _active_id: String = ""


func _ready() -> void:
	_apply_panel_style()
	_setup_section_label()
	_rebuild_items()
	_setup_exit_item()
	
	# Keyboard input
	set_process_unhandled_key_input(true)


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(
		UiTokens.COLOR_BG_ELEVATED.r,
		UiTokens.COLOR_BG_ELEVATED.g,
		UiTokens.COLOR_BG_ELEVATED.b,
		0.85
	)
	style.border_color = UiTokens.COLOR_SURFACE_BORDER
	style.border_width_right = UiTokens.BORDER_WIDTH_THIN
	style.content_margin_top = UiTokens.SPACE_XL
	style.content_margin_bottom = UiTokens.SPACE_XL
	add_theme_stylebox_override("panel", style)
	
	custom_minimum_size.x = 280


func _setup_section_label() -> void:
	_section_label.text = "НАВИГАЦИЯ"
	_section_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_BODY_SEMI))
	_section_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_LABEL)
	_section_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_DISABLED)
	_section_label.uppercase = true


func _rebuild_items() -> void:
	# Очистка
	for child in _items_container.get_children():
		child.queue_free()
	_item_nodes.clear()
	
	# Создание
	for item_data in menu_items:
		var item := MENU_ITEM_SCENE.instantiate() as MoleculeMenuItem
		item.item_id = item_data.get("id", "")
		item.label_text = item_data.get("label", "???")
		item.is_disabled = item_data.get("disabled", false)
		
		if item_data.has("icon"):
			item.icon_texture = load(item_data["icon"])
		
		# Подключаем сигналы молекулы
		item.item_pressed.connect(_on_item_pressed)
		item.item_hovered.connect(_on_item_hovered)
		
		_items_container.add_child(item)
		_item_nodes.append(item)
	
	# Если есть сохранённый active — применяем
	if _active_id != "":
		set_active(_active_id)


func _setup_exit_item() -> void:
	_exit_item.item_id = "exit"
	_exit_item.label_text = "ВЫХОД"
	_exit_item.variant = "danger"
	_exit_item.item_pressed.connect(_on_item_pressed)
	_exit_item.item_hovered.connect(_on_item_hovered)


## Установить активный пункт
func set_active(item_id: String) -> void:
	_active_id = item_id
	for item in _item_nodes:
		item.is_active = (item.item_id == item_id)


## Keyboard navigation
func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				_move_focus(-1)
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_move_focus(1)
				get_viewport().set_input_as_handled()
			KEY_ENTER:
				if _focused_index >= 0 and _focused_index < _item_nodes.size():
					_item_nodes[_focused_index]._do_press()
				get_viewport().set_input_as_handled()


func _move_focus(direction: int) -> void:
	var total := _item_nodes.size()
	if total == 0:
		return
	
	_focused_index = wrapi(_focused_index + direction, 0, total)
	
	# Пропускаем disabled
	var attempts := 0
	while _item_nodes[_focused_index].is_disabled and attempts < total:
		_focused_index = wrapi(_focused_index + direction, 0, total)
		attempts += 1
	
	_item_nodes[_focused_index].grab_focus()


func _on_item_pressed(item_id: String) -> void:
	set_active(item_id)
	navigation_selected.emit(item_id)


func _on_item_hovered(item_id: String) -> void:
	navigation_hovered.emit(item_id)
```

### Organism: TitleBar

```gdscript
# res://ui_kit/organisms/title_bar.gd
class_name OrganismTitleBar
extends PanelContainer

## Организм: верхняя панель с названием игры.
## B L E N D   A R S
##     ═══════════
##                          v0.7.2

@export var game_title: String = "BLEND ARS"
@export var version_text: String = "v0.7.2"
@export var show_decorative_line: bool = true

@onready var _title_label: Label = %TitleLabel
@onready var _version_label: Label = %VersionLabel
@onready var _deco_line: ColorRect = %DecoLine


func _ready() -> void:
	# Панель
	var style := UiTokens.make_stylebox_flat(
		Color.TRANSPARENT, Color.TRANSPARENT, 0, 0, 0
	)
	add_theme_stylebox_override("panel", style)
	
	# Заголовок (10% — декоративный шрифт)
	_title_label.text = _format_title(game_title)
	_title_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_DISPLAY))
	_title_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_DISPLAY)
	_title_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_PRIMARY)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Glow шейдер на заголовке
	var glow_shader := load("res://ui_kit/fx/glow_text.gdshader") as Shader
	if glow_shader:
		var mat := ShaderMaterial.new()
		mat.shader = glow_shader
		mat.set_shader_parameter("glow_color",
			UiTokens.COLOR_ACCENT_PRIMARY)
		mat.set_shader_parameter("glow_strength", 0.4)
		_title_label.material = mat
	
	# Версия (10% — micro text)
	_version_label.text = version_text
	_version_label.add_theme_font_override("font",
		load(UiTokens.FONT_PATH_MONO))
	_version_label.add_theme_font_size_override("font_size",
		UiTokens.FONT_SIZE_MICRO)
	_version_label.add_theme_color_override("font_color",
		UiTokens.COLOR_TEXT_DISABLED)
	
	# Декоративная линия под заголовком
	_deco_line.color = UiTokens.COLOR_ACCENT_PRIMARY
	_deco_line.custom_minimum_size = Vector2(200, 1)
	_deco_line.modulate.a = 0.5
	_deco_line.visible = show_decorative_line


## Добавляет пробелы между буквами для DISPLAY стиля
func _format_title(title: String) -> String:
	var chars := title.split("")
	return " ".join(chars)
```

### Organism: HotkeyBar

```gdscript
# res://ui_kit/organisms/hotkey_bar.gd
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
	"res://ui_kit/molecules/hotkey_hint.tscn")

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
```

---

## 5️⃣ ШЕЙДЕРЫ POST-FX

### CRT Scanlines (10% — еле заметные)

```glsl
// res://ui_kit/fx/crt_scanlines.gdshader
shader_type canvas_item;

uniform float line_count : hint_range(100, 800) = 300.0;
uniform float opacity : hint_range(0.0, 0.3) = 0.08;
uniform float speed : hint_range(0.0, 5.0) = 0.5;
uniform float flicker_intensity : hint_range(0.0, 0.05) = 0.01;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Горизонтальные линии
    float scanline = sin(
        (UV.y + TIME * speed * 0.01) * line_count * 3.14159
    );
    scanline = scanline * 0.5 + 0.5;
    scanline = pow(scanline, 1.5);
    
    // Лёгкое мерцание (20% — subtle анимация)
    float flicker = 1.0 - flicker_intensity
        * sin(TIME * 8.0)
        * sin(TIME * 12.3);
    
    vec3 final_color = tex.rgb * (1.0 - opacity * scanline) * flicker;
    COLOR = vec4(final_color, tex.a);
}
```

### Noise / Film Grain

```glsl
// res://ui_kit/fx/noise_grain.gdshader
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 0.2) = 0.04;
uniform float speed : hint_range(0.0, 30.0) = 15.0;

// Pseudo-random
float random(vec2 co) {
    return fract(
        sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453
    );
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Шум, меняющийся каждый кадр
    float noise = random(UV * vec2(
        floor(TIME * speed),
        floor(TIME * speed * 1.3)
    ));
    noise = (noise - 0.5) * 2.0 * intensity;
    
    vec3 result = tex.rgb + vec3(noise);
    COLOR = vec4(clamp(result, 0.0, 1.0), tex.a);
}
```

### Vignette

```glsl
// res://ui_kit/fx/vignette.gdshader
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float radius : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    float dist = distance(UV, vec2(0.5));
    float vignette = smoothstep(radius, radius - softness, dist);
    
    vec3 result = tex.rgb * mix(1.0 - intensity, 1.0, vignette);
    COLOR = vec4(result, tex.a);
}
```

### Glow Text

```glsl
// res://ui_kit/fx/glow_text.gdshader
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.94, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.3;
uniform float glow_radius : hint_range(1.0, 10.0) = 3.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Сэмплирование соседних пикселей для размытия
    float glow = 0.0;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * glow_radius;
    
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            glow += texture(
                TEXTURE, UV + vec2(x, y) * pixel_size
            ).a;
        }
    }
    glow /= 25.0;
    
    // Пульсация (20% — subtle анимация)
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
    
    vec3 glow_layer = glow_color.rgb * glow
        * glow_strength * pulse;
    vec3 result = tex.rgb + glow_layer;
    
    COLOR = vec4(result, tex.a);
}
```

### Chromatic Aberration

```glsl
// res://ui_kit/fx/chromatic_aberration.gdshader
shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.02) = 0.002;
uniform float edge_only : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);
    
    // Эффект усиливается к краям (edge_only)
    float factor = mix(1.0, dist * 2.0, edge_only);
    vec2 offset = (UV - center) * strength * factor;
    
    float r = texture(TEXTURE, UV + offset).r;
    float g = texture(TEXTURE, UV).g;
    float b = texture(TEXTURE, UV - offset).b;
    float a = texture(TEXTURE, UV).a;
    
    COLOR = vec4(r, g, b, a);
}
```

### Post-FX Layer — комбинированный слой

**Дерево узлов:**
```
PostFXLayer (CanvasLayer) — layer = 100
├── ScanlineRect (ColorRect) — full screen, shader: crt_scanlines
├── NoiseRect (ColorRect) — full screen, shader: noise_grain
├── VignetteRect (ColorRect) — full screen, shader: vignette
└── AberrationRect (ColorRect) — full screen, shader: chromatic_aberration
```

```gdscript
# res://ui_kit/fx/post_fx_layer.gd
class_name PostFXLayer
extends CanvasLayer

## Комбинированный пост-эффект слой.
## Добавь как дочерний узел к любому экрану.
## ВСЕ эффекты = 10% правило, не доминируют.

@export var enable_scanlines: bool = true
@export var enable_noise: bool = true
@export var enable_vignette: bool = true
@export var enable_chromatic: bool = true

@onready var _scanline_rect: ColorRect = $ScanlineRect
@onready var _noise_rect: ColorRect = $NoiseRect
@onready var _vignette_rect: ColorRect = $VignetteRect
@onready var _aberration_rect: ColorRect = $AberrationRect


func _ready() -> void:
	layer = 100  # Поверх всего UI
	
	_setup_rect(_scanline_rect,
		"res://ui_kit/fx/crt_scanlines.gdshader", enable_scanlines)
	_setup_rect(_noise_rect,
		"res://ui_kit/fx/noise_grain.gdshader", enable_noise)
	_setup_rect(_vignette_rect,
		"res://ui_kit/fx/vignette.gdshader", enable_vignette)
	_setup_rect(_aberration_rect,
		"res://ui_kit/fx/chromatic_aberration.gdshader",
		enable_chromatic)
	
	# Применяем значения из токенов
	_apply_token_values()


func _setup_rect(
	rect: ColorRect,
	shader_path: String,
	enabled: bool
) -> void:
	rect.visible = enabled
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.anchors_preset = Control.PRESET_FULL_RECT
	
	var shader := load(shader_path) as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		rect.material = mat


func _apply_token_values() -> void:
	if _scanline_rect.material:
		_scanline_rect.material.set_shader_parameter(
			"opacity", UiTokens.FX_SCANLINE_OPACITY)
	
	if _noise_rect.material:
		_noise_rect.material.set_shader_parameter(
			"intensity", UiTokens.FX_NOISE_OPACITY)
	
	if _vignette_rect.material:
		_vignette_rect.material.set_shader_parameter(
			"intensity", UiTokens.FX_VIGNETTE_INTENSITY)
	
	if _aberration_rect.material:
		_aberration_rect.material.set_shader_parameter(
			"strength", UiTokens.FX_CHROMATIC_STRENGTH)


## Включить/выключить эффект на лету
func set_effect(effect_name: String, enabled: bool) -> void:
	match effect_name:
		"scanlines":
			_scanline_rect.visible = enabled
		"noise":
			_noise_rect.visible = enabled
		"vignette":
			_vignette_rect.visible = enabled
		"chromatic":
			_aberration_rect.visible = enabled
```

---

## 6️⃣ TEMPLATES — Шаблоны экранов

### Template: MainMenu Layout

**Дерево узлов:**
```
LayoutMainMenu (Control) — full rect
├── Background (ColorRect) — тёмная заливка
├── GridContainer (custom layout)
│   ├── TitleSlot (MarginContainer) — top, full width
│   ├── NavSlot (MarginContainer) — left, 280px
│   ├── ViewportSlot (MarginContainer) — center, flex
│   └── BottomSlot (MarginContainer) — bottom, full width
└── PostFXLayer (instance)
```

```gdscript
# res://ui_kit/templates/layout_main_menu.gd
class_name TemplateMainMenu
extends Control

## Шаблон: макет главного меню.
## Определяет ТОЛЬКО расположение зон.
## НЕ содержит конкретных организмов — это делает Screen.
##
## ┌────────────────────────────────────┐
## │            TITLE_SLOT              │  8vh
## ├──────────┬─────────────────────────┤
## │          │                         │
## │ NAV_SLOT │     VIEWPORT_SLOT       │  flex
## │  280px   │                         │
## │          │                         │
## ├──────────┴─────────────────────────┤
## │           BOTTOM_SLOT              │  6vh
## └────────────────────────────────────┘

@onready var title_slot: MarginContainer = %TitleSlot
@onready var nav_slot: MarginContainer = %NavSlot
@onready var viewport_slot: MarginContainer = %ViewportSlot
@onready var bottom_slot: MarginContainer = %BottomSlot
@onready var _background: ColorRect = %Background


func _ready() -> void:
	# Full screen
	anchors_preset = Control.PRESET_FULL_RECT
	
	# Фон — 70% доминирующий цвет
	_background.color = UiTokens.COLOR_BG_PRIMARY
	_background.anchors_preset = Control.PRESET_FULL_RECT
	
	# Расположение зон через код
	_layout_zones()


func _layout_zones() -> void:
	# TITLE SLOT — верх, 8% высоты
	title_slot.anchor_left = 0.0
	title_slot.anchor_right = 1.0
	title_slot.anchor_top = 0.0
	title_slot.anchor_bottom = 0.08
	title_slot.offset_left = 0
	title_slot.offset_right = 0
	title_slot.offset_top = 0
	title_slot.offset_bottom = 0
	
	# NAV SLOT — лево, 280px, между title и bottom
	nav_slot.anchor_left = 0.0
	nav_slot.anchor_right = 0.0
	nav_slot.anchor_top = 0.08
	nav_slot.anchor_bottom = 0.94
	nav_slot.offset_right = 280
	
	# VIEWPORT SLOT — центр, от 280px до правого края
	viewport_slot.anchor_left = 0.0
	viewport_slot.anchor_right = 1.0
	viewport_slot.anchor_top = 0.08
	viewport_slot.anchor_bottom = 0.94
	viewport_slot.offset_left = 280
	
	# BOTTOM SLOT — низ, 6%
	bottom_slot.anchor_left = 0.0
	bottom_slot.anchor_right = 1.0
	bottom_slot.anchor_top = 0.94
	bottom_slot.anchor_bottom = 1.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_zones()
```

---

## 7️⃣ SCREENS — Экраны

### Screen: Main Menu

```gdscript
# res://screens/main_menu.gd
extends Control

## Экран: Главное меню BLEND ARS.
## Подставляет конкретные организмы в слоты шаблона.
## Здесь живёт вся бизнес-логика экрана.

const LAYOUT_SCENE := preload(
	"res://ui_kit/templates/layout_main_menu.tscn")
const TITLE_BAR_SCENE := preload(
	"res://ui_kit/organisms/title_bar.tscn")
const MAIN_NAV_SCENE := preload(
	"res://ui_kit/organisms/main_nav.tscn")
const HOTKEY_BAR_SCENE := preload(
	"res://ui_kit/organisms/hotkey_bar.tscn")

var _layout: TemplateMainMenu
var _title_bar: OrganismTitleBar
var _main_nav: OrganismMainNav
var _hotkey_bar: OrganismHotkeyBar


func _ready() -> void:
	_build_screen()
	_connect_signals()
	
	# Анимация появления (10% — cinematic)
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0,
		UiTokens.ANIM_DURATION_CINEMATIC)


func _build_screen() -> void:
	# 1. Создаём шаблон
	_layout = LAYOUT_SCENE.instantiate() as TemplateMainMenu
	add_child(_layout)
	
	# 2. Подставляем организмы в слоты
	
	# --- TitleBar → title_slot ---
	_title_bar = TITLE_BAR_SCENE.instantiate() as OrganismTitleBar
	_title_bar.game_title = "BLEND ARS"
	_title_bar.version_text = "v0.7.2"
	_layout.title_slot.add_child(_title_bar)
	
	# --- MainNav → nav_slot ---
	_main_nav = MAIN_NAV_SCENE.instantiate() as OrganismMainNav
	_main_nav.menu_items = [
		{"id": "campaign", "label": "КАМПАНИЯ"},
		{"id": "arsenal", "label": "АРСЕНАЛ"},
		{"id": "multiplayer", "label": "МУЛЬТИПЛЕЕР"},
		{"id": "settings", "label": "НАСТРОЙКИ",
		 "disabled": false},
	]
	_layout.nav_slot.add_child(_main_nav)
	
	# --- 3D Viewport → viewport_slot ---
	_setup_3d_viewport()
	
	# --- HotkeyBar → bottom_slot ---
	_hotkey_bar = HOTKEY_BAR_SCENE.instantiate() as OrganismHotkeyBar
	_hotkey_bar.hints = [
		{"key": "ESC", "action": "Выход"},
		{"key": "ENTER", "action": "Выбрать"},
		{"key": "↑↓", "action": "Навигация"},
		{"key": "TAB", "action": "Профиль"},
	]
	_layout.bottom_slot.add_child(_hotkey_bar)


func _setup_3d_viewport() -> void:
	# SubViewportContainer для 3D-сцены с юнитом
	var viewport_container := SubViewportContainer.new()
	viewport_container.anchors_preset = Control.PRESET_FULL_RECT
	viewport_container.stretch = true
	
	var sub_viewport := SubViewport.new()
	sub_viewport.transparent_bg = true
	sub_viewport.size = Vector2i(1920, 1080)
	sub_viewport.render_target_update_mode = \
		SubViewport.UPDATE_ALWAYS
	
	viewport_container.add_child(sub_viewport)
	
	# Загружаем 3D-сцену с платформой и юнитом
	var unit_scene := load(
		"res://scenes/unit_preview.tscn") as PackedScene
	if unit_scene:
		var unit_instance := unit_scene.instantiate()
		sub_viewport.add_child(unit_instance)
	
	_layout.viewport_slot.add_child(viewport_container)


func _connect_signals() -> void:
	_main_nav.navigation_selected.connect(_on_nav_selected)
	_main_nav.navigation_hovered.connect(_on_nav_hovered)


func _on_nav_selected(item_id: String) -> void:
	match item_id:
		"campaign":
			_transition_to("res://screens/campaign.tscn")
		"arsenal":
			_transition_to("res://screens/arsenal_screen.tscn")
		"multiplayer":
			_transition_to("res://screens/multiplayer.tscn")
		"settings":
			_transition_to("res://screens/settings_screen.tscn")
		"exit":
			_confirm_exit()


func _on_nav_hovered(item_id: String) -> void:
	# Можно менять 3D-превью или подсказки
	pass


func _transition_to(scene_path: String) -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0,
		UiTokens.ANIM_DURATION_SLOW)
	tw.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)


func _confirm_exit() -> void:
	# Здесь можно показать модальное окно подтверждения
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC
		_confirm_exit()
```

---

## 8️⃣ ПРАВИЛА ДЛЯ ИИ-АГЕНТА

### Нейминг

```
СТРОГО СОБЛЮДАЙ:

Файлы:          snake_case.gd / snake_case.tscn
Классы:         PascalCase с префиксом уровня
                AtomTextBody, MoleculeMenuItem,
                OrganismMainNav, TemplateMainMenu
Переменные:     snake_case
Константы:      UPPER_SNAKE_CASE
Сигналы:        snake_case (item_pressed, NOT itemPressed)
Приватные:      _prefix (_is_hovered, _apply_style)
@onready:       _prefix (@onready var _label)
@export:        БЕЗ prefix (@export var label_text)
Узлы в .tscn:   PascalCase (TitleLabel, AccentBar)
Unique names:   %PascalCase (%TitleLabel, %HBox)
```

### Чек-лист перед созданием компонента

```
☐ 1. Определить УРОВЕНЬ (atom/molecule/organism/template/screen)
☐ 2. Проверить — может уже СУЩЕСТВУЕТ подходящий компонент?
☐ 3. Все цвета из UiTokens.COLOR_*
☐ 4. Все размеры из UiTokens.SPACE_*
☐ 5. Все шрифты из UiTokens.FONT_PATH_*
☐ 6. Все анимации из UiTokens.ANIM_*
☐ 7. @tool если нужен превью в редакторе
☐ 8. @export для настроек из инспектора
☐ 9. Все состояния реализованы (hover/active/disabled)
☐ 10. Сигналы для коммуникации ВВЕРХ
☐ 11. Нет прямых ссылок на родителя
☐ 12. class_name с правильным префиксом
☐ 13. Документация ## для класса и @export
```

### Запреты

```
ЗАПРЕЩЕНО:

✗ Хардкодить Color("#00F0FF") в компонентах
  → ИСПОЛЬЗУЙ UiTokens.COLOR_ACCENT_PRIMARY

✗ Хардкодить числа: padding = 16
  → ИСПОЛЬЗУЙ UiTokens.SPACE_LG

✗ Вызывать get_parent() в молекулах/атомах
  → ИСПОЛЬЗУЙ сигналы

✗ Создавать "God Object" — компонент, делающий всё
  → РАЗБЕЙ на уровни

✗ Дублировать стили между компонентами
  → ВЫНЕСИ в UiTokens.make_stylebox_*

✗ Писать анимации без duration из токенов
  → ИСПОЛЬЗУЙ UiTokens.ANIM_DURATION_*

✗ Добавлять post-fx внутрь компонентов
  → post-fx ТОЛЬКО через PostFXLayer

✗ Смешивать бизнес-логику и представление
  → Логика в Screen, представление в Organism

✗ Использовать magic numbers
  → КАЖДОЕ число должно быть именованной константой

✗ Делать opacity эффектов больше чем:
  scanlines > 0.12
  noise > 0.07
  vignette > 0.6
  → Нарушает правило 10% для эффектов
```

### Принцип принятия решений

```
КОГДА СОЗДАЁШЬ НОВЫЙ ЭЛЕМЕНТ:

1. ЭТО НЕДЕЛИМЫЙ визуальный элемент?
   → ДА: Atom (text, icon, line, dot)
   → НЕТ: идём дальше

2. ЭТО комбинация 2-4 атомов с ОДНОЙ функцией?
   → ДА: Molecule (button, input, hint)
   → НЕТ: идём дальше

3. ЭТО самодостаточный БЛОК из молекул?
   → ДА: Organism (nav panel, card, header)
   → НЕТ: идём дальше

4. ЭТО РАЗМЕТКА экрана без контента?
   → ДА: Template (layout grid)
   → НЕТ: идём дальше

5. ЭТО ГОТОВЫЙ экран с данными и логикой?
   → ДА: Screen

КОГДА ПРИМЕНЯЕШЬ 70/20/10:

ЦВЕТ:
  "Этот элемент занимает много места?"
  → ДА: 70% тёмная база
  "Это вспомогательный/структурный элемент?"
  → ДА: 20% средний тон
  "Это точка фокуса внимания?"
  → ДА: 10% неон

АНИМАЦИЯ:
  "Это фоновый элемент?"
  → Статичный (70%)
  "Это реакция на действие?"
  → Мягкая анимация (20%)
  "Это ключевой момент (клик, переход)?"
  → Яркий эффект (10%)
```

---

## 9️⃣ СБОРКА НОВОГО ЭКРАНА — Пошаговый алгоритм

```
АЛГОРИТМ ДЛЯ ИИ-АГЕНТА:

ШАГ 1: АНАЛИЗ ЭКРАНА
  - Какие ЗОНЫ на экране? (top, left, center, bottom...)
  - Какие ОРГАНИЗМЫ нужны?
  - Какие из них УЖЕ ЕСТЬ в ui_kit/organisms/?
  - Какие НОВЫЕ нужно создать?

ШАГ 2: ПРОВЕРКА СУЩЕСТВУЮЩИХ
  - Пройди по ui_kit/organisms/ — что переиспользуешь?
  - Пройди по ui_kit/molecules/ — что переиспользуешь?
  - Пройди по ui_kit/atoms/ — что переиспользуешь?

ШАГ 3: СОЗДАНИЕ НЕДОСТАЮЩИХ (снизу вверх)
  3a. Нужны новые атомы? → Создай в atoms/
  3b. Нужны новые молекулы? → Собери из атомов в molecules/
  3c. Нужны новые организмы? → Собери из молекул в organisms/

ШАГ 4: ШАБЛОН
  - Есть подходящий template? → Используй
  - Нет? → Создай новый в templates/
  - Шаблон = ТОЛЬКО разметка зон, никакого контента

ШАГ 5: ЭКРАН
  - Создай screen в screens/
  - Инстанцируй шаблон
  - Подставь организмы в слоты
  - Подключи сигналы
  - Добавь бизнес-логику
  - Добавь PostFXLayer как дочерний

ШАГ 6: ПРОВЕРКА 70/20/10
  ☐ 70% экрана — тёмное пространство?
  ☐ 70% текста — основной шрифт?
  ☐ 70% элементов — статичные?
  ☐ 10% — акцентные цвета (не больше)?
  ☐ 10% — яркие эффекты (не больше)?
  ☐ Post-FX не перетягивают внимание?
```

---

## 🔟 БЫСТРАЯ СПРАВКА ПО КОМПОЗИЦИИ

```
╔═══════════════════════════════════════════════════════╗
║           ПРОПОРЦИИ ЭКРАНА (16:9)                     ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║  Title zone:     ~8% высоты    (≈86px при 1080p)     ║
║  Content zone:   ~86% высоты   (≈929px при 1080p)    ║
║  Bottom zone:    ~6% высоты    (≈65px при 1080p)     ║
║                                                       ║
║  Nav width:      280px fixed   (14.6% от 1920px)     ║
║  Viewport:       оставшееся   (85.4%)                ║
║                                                       ║
║  Негативное пространство:  ≥70% площади экрана       ║
║  Активные элементы:        ≤30% площади экрана       ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```

> **Этот документ — полная спецификация.** ИИ-агент должен следовать каждому правилу буквально. При любом сомнении — перечитай секцию «Запреты» и «Принцип принятия решений».
