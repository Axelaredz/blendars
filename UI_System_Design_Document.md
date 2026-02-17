# UI System Design Document

## Структура проекта

```
res://
├── ui/
│   ├── theme/
│   │   ├── dracula_theme.tres
│   │   ├── styles/
│   │   │   ├── panel_main.tres
│   │   │   ├── panel_secondary.tres
│   │   │   ├── button_primary.tres
│   │   │   ├── button_secondary.tres
│   │   │   ├── button_hover.tres
│   │   │   ├── line_edit.tres
│   │   │   └── tab_container.tres
│   │   └── fonts/
│   │       └── (здесь моноширинный шрифт, например JetBrains Mono)
│   ├── components/
│   │   ├── cyber_button.tscn
│   │   ├── cyber_panel.tscn
│   │   ├── glitch_overlay.tscn
│   │   └── scanline_shader.gdshader
│   ├── screens/
│   │   ├── main_menu.tscn
│   │   ├── auth_screen.tscn
│   │   ├── lobby_screen.tscn
│   │   ├── matchmaking_screen.tscn
│   │   ├── settings_screen.tscn
│   │   └── hud.tscn
│   └── scripts/
│       ├── ui_manager.gd
│       ├── cyber_button.gd
│       ├── glitch_effect.gd
│       └── screen_transition.gd
```

---

## 1. Глобальная тема (Dracula Theme)

**Путь:** `res://ui/theme/dracula_theme.tres`

Это ресурс Theme, который создаётся в Godot через inspector, но я дам тебе структуру стилей в виде GDScript-создания, чтобы ты понимал параметры. В реальности ты создашь Theme ресурс и настроишь его в редакторе, либо через код при первом запуске.

### Цветовая палитра (константы)

**Путь:** `res://ui/theme/colors.gd`

```gdscript
class_name DColors
extends RefCounted

const BACKGROUND = Color("#282a36")
const CURRENT_LINE = Color("#44475a")
const FOREGROUND = Color("#f8f8f2")
const COMMENT = Color("#6272a4")
const PURPLE = Color("#bd93f9")
const PINK = Color("#ff79c6")
const CYAN = Color("#8be9fd")
const GREEN = Color("#50fa7b")
const RED = Color("#ff5555")
const ORANGE = Color("#ffb86c")
const YELLOW = Color("#f1fa8c")

# Оттенки для hover/pressed (alpha variations)
const PURPLE_HOVER = Color("#bd93f9", 0.8)
const PINK_GLOW = Color("#ff79c6", 0.6)
const CYAN_DIM = Color("#8be9fd", 0.5)
```

**Почему класс, а не глобальный autoload:** потому что цвета — это данные, не логика. Класс можно импортировать в любой скрипт через `const DColors = preload("res://ui/theme/colors.gd")` и сразу использовать `DColors.PURPLE`.

---

### StyleBoxFlat: основная панель

**Путь:** `res://ui/theme/styles/panel_main.tres`

Создаётся через Create New Resource → StyleBoxFlat, настройки:

- **bg_color:** `#282a36`
- **border_width_left/right/top/bottom:** `2`
- **border_color:** `#bd93f9`
- **corner_radius_top_left:** `0`
- **corner_radius_top_right:** `12`
- **corner_radius_bottom_left:** `12`
- **corner_radius_bottom_right:** `0`
- **expand_margin_left/right/top/bottom:** `0`
- **shadow_size:** `0` (тени делаем отдельным слоем, не через StyleBox — движок плохо рендерит большие shadow_size)

**Почему скошенные углы разные:** это классический cyberpunk-паттерн — асимметрия создаёт ощущение технологичности и движения. Разные радиусы на углах — фишка StyleBoxFlat, позволяет делать трапециевидные формы без текстур.

---

### StyleBoxFlat: вторичная панель (для карточек, списков)

**Путь:** `res://ui/theme/styles/panel_secondary.tres`

- **bg_color:** `#44475a`
- **border_width_left/right/top/bottom:** `1`
- **border_color:** `#6272a4`
- **corner_radius_top_left:** `6`
- **corner_radius_top_right:** `0`
- **corner_radius_bottom_left:** `0`
- **corner_radius_bottom_right:** `6`
- **content_margin_left/right:** `12`
- **content_margin_top/bottom:** `8`

**Почему меньше border_width:** вложенные элементы не должны конкурировать с основной рамкой. 1px достаточно для разделения.

---

### StyleBoxFlat: кнопка primary (нормальное состояние)

**Путь:** `res://ui/theme/styles/button_primary.tres`

- **bg_color:** `#bd93f9`
- **border_width_left/right/top/bottom:** `0`
- **corner_radius_top_left:** `4`
- **corner_radius_top_right:** `16`
- **corner_radius_bottom_left:** `16`
- **corner_radius_bottom_right:** `4`
- **content_margin_left/right:** `24`
- **content_margin_top/bottom:** `12`

**Почему нет border:** акцентная кнопка сама по себе яркая, рамка будет лишней. Вместо этого border добавим на hover через отдельный StyleBox.

---

### StyleBoxFlat: кнопка primary hover

**Путь:** `res://ui/theme/styles/button_primary_hover.tres`

Копируем `button_primary.tres` и меняем:

- **bg_color:** `#ff79c6` (переход purple → pink)
- **border_width_left/right/top/bottom:** `2`
- **border_color:** `#f8f8f2` (белый border для "свечения")

В Theme ресурсе этот стиль назначается на `Button > Styles > hover`.

**Почему меняем цвет, а не просто border:** cyberpunk UI должен быть отзывчивым и агрессивным. Смена цвета + border создаёт эффект "зарядки" кнопки.

---

### StyleBoxFlat: кнопка primary pressed

**Путь:** `res://ui/theme/styles/button_primary_pressed.tres`

- **bg_color:** `#6272a4` (притушенный)
- **border_width_left/right/top/bottom:** `2`
- **border_color:** `#8be9fd` (cyan для "разряда")
- **content_margin_top:** `14` (сдвиг вниз на 2px для эффекта нажатия)
- **content_margin_bottom:** `10`

**Почему сдвиг через margin:** Godot не умеет сдвигать контент кнопки через StyleBox offset (это баг/фича движка), поэтому используем хак с разными margin top/bottom.

---

### StyleBoxFlat: LineEdit (поля ввода)

**Путь:** `res://ui/theme/styles/line_edit.tres`

- **bg_color:** `#44475a`
- **border_width_left:** `4`
- **border_width_right/top/bottom:** `1`
- **border_color:** `#8be9fd`
- **corner_radius_all:** `0` (строгая прямоугольная форма для киберпанка)
- **content_margin_left:** `12`
- **content_margin_right:** `8`
- **content_margin_top/bottom:** `8`

**Почему левая граница толще:** визуальный акцент на начале поля, имитация "точки ввода". Это распространённая фишка sci-fi интерфейсов.

---

### StyleBoxFlat: LineEdit focus

**Путь:** `res://ui/theme/styles/line_edit_focus.tres`

Копируем `line_edit.tres`:

- **border_color:** `#bd93f9`
- **border_width_left:** `4`
- **border_width_right/top/bottom:** `2` (усиливаем рамку)

Назначается на `LineEdit > Styles > focus`.

---

### Шрифты

Тебе нужен **моноширинный шрифт**. Рекомендую:

- **JetBrains Mono** (Open Font License, можно включить в проект)
- **Fira Code**
- **IBM Plex Mono**

**Путь:** `res://ui/theme/fonts/JetBrainsMono-Regular.ttf`

Скачиваешь, кладёшь в папку `fonts/`. Импортируешь в Godot (должен создаться `.import` файл).

Создаёшь FontFile ресурс:

**Путь:** `res://ui/theme/fonts/main_font.tres`

- Устанавливаешь font_data на `JetBrainsMono-Regular.ttf`
- **cache/0/size:** `16` (базовый размер)
- **cache/0/oversampling:** `2.0` (для чёткости на разных DPI)

В Theme ресурсе (`dracula_theme.tres`) назначаешь:

- **Default Font:** `main_font.tres`
- **Default Font Size:** `16`

Для заголовков создаёшь отдельные FontVariation:

**Путь:** `res://ui/theme/fonts/heading_font.tres` (тип FontVariation)

- **base_font:** `main_font.tres`
- **variation_transform:** `Transform2D` с `scale(1.5, 1.5)` — даёт размер 24px
- Либо просто устанавливаешь spacing_top/bottom для высоты строки

В Theme назначаешь на `Label > Fonts > font` для типа "Heading" (если используешь theme types).

**Почему моноширинный:** в sci-fi/cyberpunk интерфейсах моноширинный шрифт создаёт ассоциацию с терминалами, кодом, матрицами. Это жанровая необходимость.

---

## 2. Переиспользуемые компоненты

### CyberButton (кнопка с glitch-эффектом)

**Путь сцены:** `res://ui/components/cyber_button.tscn`  
**Путь скрипта:** `res://ui/components/cyber_button.gd`

#### Структура сцены:

```
CyberButton (Button)
├── GlitchOverlay (ColorRect) - шейдер с эффектом
└── AnimationPlayer
```

#### Свойства Button:

- **Theme Overrides > Styles > normal:** `button_primary.tres`
- **Theme Overrides > Styles > hover:** `button_primary_hover.tres`
- **Theme Overrides > Styles > pressed:** `button_primary_pressed.tres`
- **Theme Overrides > Colors > font_color:** `#f8f8f2`
- **Theme Overrides > Colors > font_hover_color:** `#f8f8f2`
- **Theme Overrides > Colors > font_pressed_color:** `#f8f8f2`
- **Custom Minimum Size:** `(0, 48)` — минимальная высота 48px для удобства тапов

#### GlitchOverlay (ColorRect):

- **Anchors:** full rect (0,0,1,1)
- **Mouse Filter:** Ignore (чтобы не перехватывал клики)
- **Material:** ShaderMaterial с `glitch_shader.gdshader`
- **Modulate:** `#ff79c6` с alpha `0.0` (по умолчанию невидим)

#### Скрипт `cyber_button.gd`:

```gdscript
@tool
class_name CyberButton
extends Button

@export var glitch_on_hover: bool = true
@export var glitch_intensity: float = 0.05

@onready var glitch_overlay: ColorRect = $GlitchOverlay
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	
	# Настраиваем шейдер
	if glitch_overlay and glitch_overlay.material:
		glitch_overlay.material.set_shader_parameter("intensity", 0.0)

func _on_mouse_entered() -> void:
	if not glitch_on_hover:
		return
	
	# Включаем glitch
	var tween = create_tween().set_parallel(true)
	tween.tween_property(glitch_overlay, "modulate:a", 0.3, 0.15)
	tween.tween_property(glitch_overlay.material, "shader_parameter/intensity", glitch_intensity, 0.15)
	
	# Анимация свечения border (модулируем сам Button, чтобы border светился)
	tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.15)

func _on_mouse_exited() -> void:
	if not glitch_on_hover:
		return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.2)
	tween.tween_property(glitch_overlay.material, "shader_parameter/intensity", 0.0, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _on_pressed() -> void:
	# Короткая вспышка при клике
	var flash = glitch_overlay.duplicate()
	add_child(flash)
	flash.modulate = Color(DColors.CYAN, 0.8)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)
```

**Почему @tool:** чтобы видеть превью кнопки в редакторе с правильными стилями. Без @tool Theme overrides могут не отображаться в дереве сцен.

**Почему через Tween, а не AnimationPlayer:** для hover-эффектов Tween удобнее — не нужно создавать анимацию в редакторе, код компактнее. 
AnimationPlayer оставляем для сложных последовательностей (появление экрана, глитч-цепочки).

---

### Glitch Shader (сканлайны + хроматическая аберрация)

**Путь:** `res://ui/components/scanline_shader.gdshader`

```glsl
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_count : hint_range(50.0, 800.0) = 300.0;
uniform float scanline_alpha : hint_range(0.0, 0.2) = 0.05;
uniform float aberration_amount : hint_range(0.0, 10.0) = 2.0;
uniform float flicker_speed : hint_range(0.0, 20.0) = 8.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Глитч-сдвиг по горизонтали
    float glitch_line = step(0.98 - intensity * 0.3, random(vec2(floor(uv.y * 40.0), floor(TIME * flicker_speed))));
    uv.x += glitch_line * intensity * 0.08 * (random(vec2(TIME)) - 0.5);

    // Хроматическая аберрация
    float ab = aberration_amount * intensity / 1000.0;
    float r = texture(TEXTURE, uv + vec2(ab, 0.0)).r;
    float g = texture(TEXTURE, uv).g;
    float b = texture(TEXTURE, uv - vec2(ab, 0.0)).b;
    float a = texture(TEXTURE, uv).a;

    // Сканлайны
    float scanline = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
    float scan_mask = 1.0 - scanline_alpha * scanline * intensity;

    // Мерцание
    float flicker = 1.0 - intensity * 0.03 * random(vec2(floor(TIME * flicker_speed), 0.0));

    COLOR = vec4(r, g, b, a) * scan_mask * flicker;
}
```

---

### CyberPanel (панель с рамкой и сканлайнами)

**Путь:** `res://ui/components/cyber_panel.tscn`  
**Скрипт:** `res://ui/components/cyber_panel.gd`

#### Дерево:

```
CyberPanel (PanelContainer)
├── ScanlineOverlay (ColorRect) — шейдер scanline_shader
└── MarginContainer
    └── Content (VBoxContainer)
```

#### Настройки PanelContainer:

- **Theme Override > Styles > panel:** `panel_main.tres`

#### ScanlineOverlay:

- **Layout:** Full Rect
- **Mouse Filter:** Ignore
- **Material:** ShaderMaterial → `scanline_shader.gdshader`
  - `intensity`: `0.4`
  - `scanline_count`: `300`
  - `scanline_alpha`: `0.04`
  - `aberration_amount`: `0.0`
  - `flicker_speed`: `3.0`

#### MarginContainer:

- **Theme Override > Constants:** all margins `16`

#### Скрипт `cyber_panel.gd`:

```gdscript
@tool
class_name CyberPanel
extends PanelContainer

@export var accent_color: Color = Color("#bd93f9"):
    set(value):
        accent_color = value
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
```

---

### GlitchOverlay (полноэкранный, для переходов)

**Путь:** `res://ui/components/glitch_overlay.tscn`

```
GlitchOverlay (ColorRect)
```

- **Layout:** Full Rect
- **Mouse Filter:** Ignore
- **Color:** `#282a36`
- **Material:** ShaderMaterial → `scanline_shader.gdshader`
  - `intensity`: `0.0`

**Путь:** `res://ui/components/glitch_overlay.gd`

```gdscript
class_name GlitchOverlay
extends ColorRect

func glitch_transition(duration: float = 0.4) -> void:
    var mat = material as ShaderMaterial
    if not mat:
        return
    visible = true
    var tween = create_tween()
    tween.tween_property(mat, "shader_parameter/intensity", 1.0, duration * 0.3)
    tween.tween_property(mat, "shader_parameter/intensity", 0.0, duration * 0.7)
    tween.tween_callback(func(): visible = false)

func flash(color: Color = Color("#ff79c6", 0.3), duration: float = 0.2) -> void:
    self.color = color
    visible = true
    var tween = create_tween()
    tween.tween_property(self, "color:a", 0.0, duration)
    tween.tween_callback(func(): visible = false)
```

---

## 3. Экран: Главное меню

**Путь:** `res://ui/screens/main_menu.tscn`

### Дерево нод:

```
MainMenu (Control) 
├── BGLayer (ColorRect) — фон #282a36
│   └── ScanlineOverlay (ColorRect) — шейдер
├── VignetteOverlay (ColorRect) — шейдер виньетки
├── ContentRoot (MarginContainer) 
│   └── VBox (VBoxContainer)
│       ├── Spacer1 (Control) 
│       ├── TitleBlock (VBoxContainer) 
│       │   ├── TitleLabel (Label) — "NEXUS FORGE"
│       │   └── SubtitleLabel (Label) — "cooperative sandbox v0.1"
│       ├── Spacer2 (Control) 
│       ├── ButtonsBlock (VBoxContainer) 
│       │   ├── PlayButton (CyberButton) — ""
│       │   ├── SettingsButton (CyberButton) — ""
│       │   └── QuitButton (CyberButton) — ""
│       └── Spacer3 (Control) 
├── VersionLabel (Label) — "build 0.0.1" внизу справа
└── GlitchOverlay (GlitchOverlay)
```

### Настройки нод:

**BGLayer:**
- Full Rect, Color: `#282a36`

**ScanlineOverlay (дочерний BGLayer):**
- Full Rect, Mouse Filter: Ignore
- ShaderMaterial → `scanline_shader.gdshader`: `intensity: 0.3`, `scanline_count: 400`, `scanline_alpha: 0.03`, `flicker_speed: 2.0`

**VignetteOverlay:** отдельный шейдер:

**Путь:** `res://ui/components/vignette_shader.gdshader`

```glsl
shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.4;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.7);

void fragment() {
    vec2 center = UV - vec2(0.5);
    float dist = length(center);
    float vignette = smoothstep(radius, radius + softness, dist);
    COLOR = vec4(color.rgb, color.a * vignette);
}
```

- Full Rect, Mouse Filter: Ignore, Color: white
- ShaderMaterial: `radius: 0.35`, `softness: 0.55`, `color: #000000B3`

**ContentRoot → MarginContainer:**
- Left/Right: `80`, Top/Bottom: `40`

**TitleLabel:**
- Text: `"NEXUS FORGE"`
- Horizontal Alignment: Center
- Theme Override > Font Size: `48`
- Theme Override > Colors > font_color: `#bd93f9`

**SubtitleLabel:**
- Text: `"cooperative sandbox v0.1"`
- Horizontal Alignment: Center
- Theme Override > Font Size: `14`
- Theme Override > Colors > font_color: `#6272a4`

**ButtonsBlock:**
- Theme Override > Constants > separation: `12`

**Каждый CyberButton:**
- Custom Minimum Size: `(280, 52)`
- Size Flags Horizontal: Shrink Center

**VersionLabel:**
- Anchors: bottom-right
- Offset Left: `-200`, Offset Top: `-30`
- Text: `"build 0.0.1"`
- Font Size: `11`
- Font Color: `#6272a4`

### Скрипт `main_menu.gd`:

**Путь:** `res://ui/screens/main_menu.gd`

```gdscript
extends Control

@onready var play_btn: Button = %PlayButton
@onready var settings_btn: Button = %SettingsButton
@onready var quit_btn: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var glitch: GlitchOverlay = $GlitchOverlay

func _ready() -> void:
    play_btn.pressed.connect(_on_play)
    settings_btn.pressed.connect(_on_settings)
    quit_btn.pressed.connect(_on_quit)
    _animate_entrance()

func _animate_entrance() -> void:
    # Title — печатающий эффект
    var full_text = title_label.text
    title_label.text = ""
    title_label.modulate.a = 1.0

    var tween = create_tween()
    for i in full_text.length():
        tween.tween_callback(func(): title_label.text += full_text)
        tween.tween_interval(0.06)

    # Кнопки — поочерёдное появление
    var buttons = 
    for btn in buttons:
        btn.modulate.a = 0.0
        btn.position.x -= 40.0

    tween.tween_interval(0.2)
    for i in buttons.size():
        var btn = buttons
        var target_x = btn.position.x + 40.0
        tween.tween_property(btn, "modulate:a", 1.0, 0.25)
        tween.parallel().tween_property(btn, "position:x", target_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        tween.tween_interval(0.08)

func _on_play() -> void:
    glitch.glitch_transition(0.5)
    await get_tree().create_timer(0.2).timeout
    # Переход на экран авторизации или лобби
    get_tree().change_scene_to_file("res://ui/screens/auth_screen.tscn")

func _on_settings() -> void:
    glitch.glitch_transition(0.4)
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://ui/screens/settings_screen.tscn")

func _on_quit() -> void:
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.3)
    tween.tween_callback(get_tree().quit)
```

**Почему %PlayButton (unique names):** чтобы не зависеть от глубины вложенности. В Godot 4 кликаешь на ноду → правая кнопка → Access as Unique Name. Дальше `@onready var` с `%` находит по имени в любом месте дерева.

---

## 4. Экран: Авторизация

**Путь:** `res://ui/screens/auth_screen.tscn`

### Дерево:

```
AuthScreen (Control) 
├── BGLayer (ColorRect) #282a36
│   └── ScanlineOverlay (ColorRect)
├── VignetteOverlay (ColorRect)
├── CenterContainer 
│   └── AuthPanel (CyberPanel) 
│       └── Content (автоматически из CyberPanel)
│           ├── HeaderLabel (Label) — "АВТОРИЗАЦИЯ"
│           ├── HSeparator
│           ├── Spacer (Control) 
│           ├── StatusLabel (Label) — "Выберите способ входа"
│           ├── Spacer2 (Control) 
│           ├── VKButton (CyberButton) — ""
│           ├── TelegramButton (CyberButton) — ""
│           ├── GuestButton (CyberButton) — ""
│           ├── Spacer3 (Control) 
│           ├── ConnectionStatus (HBoxContainer)
│           │   ├── StatusDot (ColorRect) 
│           │   └── StatusText (Label) — "Nakama: подключение..."
│           └── BackButton (CyberButton) — ""
├── LoadingOverlay (ColorRect) 
│   └── CenterContainer
│       └── LoadingLabel (Label) — "ПОДКЛЮЧЕНИЕ..."
└── GlitchOverlay (GlitchOverlay)
```

### Настройки специфичных нод:

**AuthPanel > CyberPanel:**
- `accent_color`: `#8be9fd` (cyan — нейтральный для формы авторизации)
- Custom Minimum Size: `(420, 0)`

**HeaderLabel:**
- Font Size: `24`, Color: `#8be9fd`, Horizontal Alignment: Center

**HSeparator:**
- Theme Override > Styles > separator: StyleBoxFlat
  - bg_color: `#6272a4`, content_margin_top: `1`, content_margin_bottom: `1`

**StatusLabel:**
- Font Size: `14`, Color: `#6272a4`, Horizontal Alignment: Center

**VKButton:**
- `accent_color` override на кнопке — можно тонировать через Theme Override font_color: `#8be9fd`

**TelegramButton:**
- font_color: `#8be9fd`

**GuestButton:**
- Используем `button_secondary.tres` вместо primary (приглушённый стиль)

**StatusDot (ColorRect):**
- Custom Minimum Size: `(8, 8)`
- Size Flags Vertical: Center
- Color: `#ffb86c` (orange — "в процессе")
- **Без StyleBox** — просто квадратик, его форму зададим через скрипт

**StatusText:**
- Font Size: `12`, Color: `#6272a4`

**LoadingOverlay:**
- Full Rect, Color: `#282a36CC` (полупрозрачный фон)
- Mouse Filter: Stop (блокирует клики)

**LoadingLabel:**
- Font Size: `18`, Color: `#bd93f9`

### StyleBox: button_secondary.tres

**Путь:** `res://ui/theme/styles/button_secondary.tres`

- **bg_color:** `#44475a`
- **border_width_all:** `1`
- **border_color:** `#6272a4`
- **corner_radius:** те же что primary (4/16/16/4)
- **content_margin_left/right:** `24`, **top/bottom:** `10`

### Скрипт `auth_screen.gd`:

**Путь:** `res://ui/screens/auth_screen.gd`

```gdscript
extends Control

@onready var vk_btn: Button = %VKButton
@onready var tg_btn: Button = %TelegramButton
@onready var guest_btn: Button = %GuestButton
@onready var back_btn: Button = %BackButton
@onready var status_dot: ColorRect = %StatusDot
@onready var status_text: Label = %StatusText
@onready var status_label: Label = %StatusLabel
@onready var loading_overlay: ColorRect = %LoadingOverlay
@onready var loading_label: Label = %LoadingLabel
@onready var glitch: GlitchOverlay = $GlitchOverlay

enum AuthState { IDLE, CONNECTING, SUCCESS, ERROR }
var current_state: AuthState = AuthState.IDLE

# Цвета статуса
const STATUS_COLORS = {
    AuthState.IDLE: Color("#6272a4"),
    AuthState.CONNECTING: Color("#ffb86c"),
    AuthState.SUCCESS: Color("#50fa7b"),
    AuthState.ERROR: Color("#ff5555"),
}

func _ready() -> void:
    vk_btn.pressed.connect(_on_vk_auth)
    tg_btn.pressed.connect(_on_tg_auth)
    guest_btn.pressed.connect(_on_guest_auth)
    back_btn.pressed.connect(_on_back)
    loading_overlay.visible = false
    _set_state(AuthState.IDLE)
    _animate_entrance()

func _animate_entrance() -> void:
    var panel = %AuthPanel
    panel.modulate.a = 0.0
    panel.scale = Vector2(0.95, 0.95)
    panel.pivot_offset = panel.size / 2.0

    var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(panel, "modulate:a", 1.0, 0.35)
    tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.4)

func _set_state(state: AuthState) -> void:
    current_state = state
    var color = STATUS_COLORS
    
    var tween = create_tween()
    tween.tween_property(status_dot, "color", color, 0.2)

    match state:
        AuthState.IDLE:
            status_text.text = "Nakama: ожидание"
        AuthState.CONNECTING:
            status_text.text = "Nakama: подключение..."
            _pulse_dot()
        AuthState.SUCCESS:
            status_text.text = "Nakama: подключено"
        AuthState.ERROR:
            status_text.text = "Nakama: ошибка соединения"

func _pulse_dot() -> void:
    if current_state != AuthState.CONNECTING:
        return
    var tween = create_tween().set_loops()
    tween.tween_property(status_dot, "modulate:a", 0.3, 0.5)
    tween.tween_property(status_dot, "modulate:a", 1.0, 0.5)

func _show_loading(text: String) -> void:
    loading_label.text = text
    loading_overlay.visible = true
    loading_overlay.modulate.a = 0.0
    create_tween().tween_property(loading_overlay, "modulate:a", 1.0, 0.2)

func _hide_loading() -> void:
    var tween = create_tween()
    tween.tween_property(loading_overlay, "modulate:a", 0.0, 0.2)
    tween.tween_callback(func(): loading_overlay.visible = false)

func _on_vk_auth() -> void:
    _show_loading("АВТОРИЗАЦИЯ VK...")
    _set_state(AuthState.CONNECTING)
    # Здесь вызов Nakama auth
    await _simulate_auth()

func _on_tg_auth() -> void:
    _show_loading("АВТОРИЗАЦИЯ TELEGRAM...")
    _set_state(AuthState.CONNECTING)
    await _simulate_auth()

func _on_guest_auth() -> void:
    _show_loading("ВХОД КАК ГОСТЬ...")
    _set_state(AuthState.CONNECTING)
    await _simulate_auth()

func _simulate_auth() -> void:
    # Заглушка для тестирования — заменяется на реальную авторизацию Nakama
    await get_tree().create_timer(1.5).timeout
    _set_state(AuthState.SUCCESS)
    _hide_loading()
    await get_tree().create_timer(0.3).timeout
    status_label.text = "Вход выполнен!"
    status_label.add_theme_color_override("font_color", Color("#50fa7b"))
    await get_tree().create_timer(0.5).timeout
    glitch.glitch_transition(0.5)
    await get_tree().create_timer(0.2).timeout
    get_tree().change_scene_to_file("res://ui/screens/lobby_screen.tscn")

func _on_back() -> void:
    glitch.glitch_transition(0.4)
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://ui/screens/main_menu.tscn")
```

**Почему `_simulate_auth()`:** это рабочий код, не заглушка-комментарий. Он реально ждёт, меняет статус, переходит на экран. Когда Nakama готова — заменяешь тело функции на реальный вызов.

---

## 5. Экран: Лобби

**Путь:** `res://ui/screens/lobby_screen.tscn`

### Дерево:

```
LobbyScreen (Control) 
├── BGLayer (ColorRect) #282a36
│   └── ScanlineOverlay (ColorRect)
├── MainLayout (MarginContainer) 
│   └── HSplit (HBoxContainer) 
│       ├── LeftPanel (CyberPanel) 
│       │   └── Content (VBox)
│       │       ├── RoomHeader (HBoxContainer)
│       │       │   ├── RoomLabel (Label) — "КОМНАТА"
│       │       │   └── RoomCode (Label) — "#A7F3"
│       │       ├── HSeparator
│       │       ├── PlayersHeader (Label) — "ИГРОКИ (1/4)"
│       │       ├── PlayerList (VBoxContainer) 
│       │       │   └── (PlayerEntry — динамически)
│       │       ├── Spacer 
│       │       ├── InviteBox (HBoxContainer)
│       │       │   ├── InviteCodeEdit (LineEdit) 
│       │       │   └── CopyButton (CyberButton) — "КОПИРОВАТЬ"
│       │       ├── Spacer2 
│       │       ├── ButtonRow (HBoxContainer) 
│       │       │   ├── StartButton (CyberButton) — ""
│       │       │   └── LeaveButton (CyberButton) — ""
│       └── RightPanel (CyberPanel) 
│           └── Content (VBox)
│               ├── ChatHeader (Label) — "ЧАТ"
│               ├── HSeparator
│               ├── ChatScroll (ScrollContainer) 
│               │   └── ChatMessages (VBoxContainer)
│               ├── ChatInputRow (HBoxContainer)
│               │   ├── ChatInput (LineEdit) 
│               │   └── SendButton (CyberButton) — ">"
└── GlitchOverlay (GlitchOverlay)
```

### Компонент: PlayerEntry

**Путь:** `res://ui/components/player_entry.tscn`

```
PlayerEntry (PanelContainer)
├── HBox (HBoxContainer) 
│   ├── StatusDot (ColorRect) 
│   ├── PlayerName (Label) 
│   ├── RoleLabel (Label) — "HOST" или ""
│   └── PingLabel (Label) — "32ms"
```

**PlayerEntry PanelContainer:**
- StyleBox override: `panel_secondary.tres`
- Custom Minimum Size: `(0, 40)`

**StatusDot:** `#50fa7b` (Green) — онлайн

**PlayerName:** Font Size `14`, Color `#f8f8f2`

**RoleLabel:** Font Size `11`, Color `#bd93f9`

**PingLabel:** Font Size `11`, Color `#6272a4`

### Настройки лобби:

**RoomCode:**
- Font Size: `20`, Color: `#8be9fd`
- Отображает короткий код комнаты

**InviteCodeEdit:**
- StyleBox: `line_edit.tres` / `line_edit_focus.tres`
- Editable: `false` (только для копирования)
- Text: полный код приглашения

**StartButton:**
- Стиль primary, accent `#50fa7b` (зелёный — "го!")

**LeaveButton:**
- Стиль secondary, font_color: `#ff5555`

**ChatInput:**
- Placeholder Text: "Сообщение..."
- StyleBox: `line_edit.tres`

**SendButton:**
- Custom Minimum Size: `(48, 0)`
- Стиль primary

### Скрипт `lobby_screen.gd`:

**Путь:** `res://ui/screens/lobby_screen.gd`

```gdscript
extends Control

@onready var room_code: Label = %RoomCode
@onready var players_header: Label = %PlayersHeader
@onready var player_list: VBoxContainer = %PlayerList
@onready var invite_code_edit: LineEdit = %InviteCodeEdit
@onready var copy_btn: Button = %CopyButton
@onready var start_btn: Button = %StartButton
@onready var leave_btn: Button = %LeaveButton
@onready var chat_messages: VBoxContainer = %ChatMessages
@onready var chat_input: LineEdit = %ChatInput
@onready var send_btn: Button = %SendButton
@onready var chat_scroll: ScrollContainer = %ChatScroll
@onready var glitch: GlitchOverlay = $GlitchOverlay

const PlayerEntryScene = preload("res://ui/components/player_entry.tscn")
const MAX_PLAYERS = 4

var players: Array = 
var room_id: String = ""

func _ready() -> void:
    copy_btn.pressed.connect(_on_copy_code)
    start_btn.pressed.connect(_on_start)
    leave_btn.pressed.connect(_on_leave)
    send_btn.pressed.connect(_on_send_message)
    chat_input.text_submitted.connect(_on_chat_submitted)

    # Тестовые данные
    _set_room("A7F3")
    _add_player({"name": "Player_01", "is_host": true, "ping": 12})
    _add_player({"name": "xX_Cyber_Xx", "is_host": false, "ping": 45})
    _add_system_message("Комната создана")

func _set_room(code: String) -> void:
    room_id = code
    room_code.text = "#" + code
    invite_code_edit.text = code

func _add_player(data: Dictionary) -> void:
    players.append(data)
    _rebuild_player_list()

func _remove_player(player_name: String) -> void:
    players = players.filter(func(p): return p.name != player_name)
    _rebuild_player_list()

func _rebuild_player_list() -> void:
    # Очищаем
    for child in player_list.get_children():
        child.queue_free()

    # Пересоздаём
    for p in players:
        var entry = PlayerEntryScene.instantiate()
        player_list.add_child(entry)
        entry.get_node("HBox/PlayerName").text = p.name
        entry.get_node("HBox/RoleLabel").text = "HOST" if p.get("is_host", false) else ""
        entry.get_node("HBox/PingLabel").text = str(p.get("ping", 0)) + "ms"

        var dot = entry.get_node("HBox/StatusDot")
        dot.color = Color("#50fa7b")

        # Анимация появления
        entry.modulate.a = 0.0
        var tween = create_tween()
        tween.tween_property(entry, "modulate:a", 1.0, 0.2)

    players_header.text = "ИГРОКИ (%d/%d)" % 
    start_btn.disabled = players.size() < 1

func _add_chat_message(author: String, text: String, color: Color = Color("#f8f8f2")) -> void:
    var label = Label.new()
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.text = " %s" % 

    var author_end = author.length() + 2
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", 13)

    chat_messages.add_child(label)

    # Прокрутка вниз
    await get_tree().process_frame
    chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value

func _add_system_message(text: String) -> void:
    _add_chat_message("SYS", text, Color("#6272a4"))

func _on_copy_code() -> void:
    DisplayServer.clipboard_set(invite_code_edit.text)
    _add_system_message("Код скопирован")

    # Визуальный фидбек
    var original = copy_btn.text
    copy_btn.text = "✓"
    await get_tree().create_timer(1.0).timeout
    copy_btn.text = original

func _on_send_message() -> void:
    var text = chat_input.text.strip_edges()
    if text.is_empty():
        return
    _add_chat_message("Вы", text, Color("#8be9fd"))
    chat_input.text = ""
    chat_input.grab_focus()

func _on_chat_submitted(text: String) -> void:
    _on_send_message()

func _on_start() -> void:
    _add_system_message("Запуск игры...")
    start_btn.disabled = true
    glitch.glitch_transition(0.6)
    await get_tree().create_timer(0.3).timeout
    # Переход в игровую сцену
    # get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_leave() -> void:
    glitch.glitch_transition(0.4)
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://ui/screens/main_menu.tscn")
```

---

## 6. Экран: Поиск/создание матча

**Путь:** `res://ui/screens/matchmaking_screen.tscn`

### Дерево:

```
MatchmakingScreen (Control) 
├── BGLayer (ColorRect) #282a36
│   └── ScanlineOverlay (ColorRect)
├── MainLayout (MarginContainer) 
│   └── VBox (VBoxContainer) 
│       ├── HeaderRow (HBoxContainer)
│       │   ├── TitleLabel (Label) — "ПОИСК МАТЧА"
│       │   ├── Spacer 
│       │   └── BackButton (CyberButton) — ""
│       ├── FilterPanel (CyberPanel) 
│       │   └── Content
│       │       └── FilterRow (HBoxContainer) 
│       │           ├── ModeFilter (OptionButton) — режим
│       │           ├── RegionFilter (OptionButton) — регион
│       │           ├── Spacer 
│       │           ├── RefreshButton (CyberButton) — "ОБНОВИТЬ"
│       │           └── CreateButton (CyberButton) — ""
│       ├── LobbyListPanel (CyberPanel) 
│       │   └── Content
│       │       └── LobbyScroll (ScrollContainer) 
│       │           └── LobbyList (VBoxContainer) 
│       │               └── (LobbyEntry — динамически)
│       └── StatusBar (HBoxContainer)
│           ├── StatusLabel (Label) — "Найдено: 3 лобби"
│           └── Spacer 
└── GlitchOverlay (GlitchOverlay)
```

### Компонент: LobbyEntry

**Путь:** `res://ui/components/lobby_entry.tscn`

```
LobbyEntry (PanelContainer)
└── HBox (HBoxContainer) 
    ├── RoomName (Label)  — "Room_A7F3"
    ├── ModeLabel (Label) — "Coop"
    ├── PlayersLabel (Label) — "2/4"
    ├── PingLabel (Label) — "32ms"
    └── JoinButton (CyberButton) — "ВОЙТИ"
```

**PanelContainer:**
- StyleBox: `panel_secondary.tres`
- Custom Minimum Size: `(0, 48)`

**RoomName:** Font Size `14`, Color `#f8f8f2`, Size Flags H: Expand

**ModeLabel:** Font Size `12`, Color `#8be9fd`, Custom Min Size: `(80, 0)`

**PlayersLabel:** Font Size `12`, Color `#50fa7b`, Custom Min Size: `(50, 0)`

**PingLabel:** Font Size `11`, Color `#6272a4`, Custom Min Size: `(60, 0)`

**JoinButton:** Custom Min Size `(100, 36)`, стиль primary

### OptionButton стиль:

В `dracula_theme.tres` добавляем для OptionButton:

- **Styles > normal:** StyleBoxFlat — bg `#44475a`, border `1` `#6272a4`, corner 4/0/0/4
- **Styles > hover:** то же, border_color `#bd93f9`
- **Colors > font_color:** `#f8f8f2`
- **Colors > font_hover_color:** `#ff79c6`

### Скрипт `matchmaking_screen.gd`:

**Путь:** `res://ui/screens/matchmaking_screen.gd`

```gdscript
extends Control

@onready var mode_filter: OptionButton = %ModeFilter
@onready var region_filter: OptionButton = %RegionFilter
@onready var refresh_btn: Button = %RefreshButton
@onready var create_btn: Button = %CreateButton
@onready var back_btn: Button = %BackButton
@onready var lobby_list: VBoxContainer = %LobbyList
@onready var status_label: Label = %StatusLabel
@onready var glitch: GlitchOverlay = $GlitchOverlay

const LobbyEntryScene = preload("res://ui/components/lobby_entry.tscn")

func _ready() -> void:
    _setup_filters()
    refresh_btn.pressed.connect(_refresh_lobbies)
    create_btn.pressed.connect(_create_lobby)
    back_btn.pressed.connect(_on_back)
    _refresh_lobbies()

func _setup_filters() -> void:
    mode_filter.add_item("Все режимы", 0)
    mode_filter.add_item("Coop", 1)
    mode_filter.add_item("PvP", 2)
    mode_filter.add_item("Sandbox", 3)

    region_filter.add_item("Все регионы", 0)
    region_filter.add_item("EU", 1)
    region_filter.add_item("RU", 2)
    region_filter.add_item("US", 3)

func _refresh_lobbies() -> void:
    # Очищаем список
    for child in lobby_list.get_children():
        child.queue_free()

    # Тестовые данные — заменить на Nakama match list
    var test_lobbies = 

    for i in test_lobbies.size():
        var data = test_lobbies
        var entry = LobbyEntryScene.instantiate()
        lobby_list.add_child(entry)

        entry.get_node("HBox/RoomName").text = data.name
        entry.get_node("HBox/ModeLabel").text = data.mode
        entry.get_node("HBox/PlayersLabel").text = data.players
        entry.get_node("HBox/PingLabel").text = data.ping

        var join_btn = entry.get_node("HBox/JoinButton")
        join_btn.pressed.connect(_on_join_lobby.bind(data.name))

        # Каскадное появление
        entry.modulate.a = 0.0
        var tween = create_tween()
        tween.tween_interval(i * 0.08)
        tween.tween_property(entry, "modulate:a", 1.0, 0.2)

    status_label.text = "Найдено: %d лобби" % test_lobbies.size()

func _on_join_lobby(room_name: String) -> void:
    status_label.text = "Подключение к %s..." % room_name
    glitch.glitch_transition(0.5)
    await get_tree().create_timer(0.3).timeout
    get_tree().change_scene_to_file("res://ui/screens/lobby_screen.tscn")

func _create_lobby() -> void:
    status_label.text = "Создание комнаты..."
    glitch.glitch_transition(0.5)
    await get_tree().create_timer(0.3).timeout
    get_tree().change_scene_to_file("res://ui/screens/lobby_screen.tscn")

func _on_back() -> void:
    glitch.glitch_transition(0.4)
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://ui/screens/main_menu.tscn")
```

---

## 7. Экран: Настройки

**Путь:** `res://ui/screens/settings_screen.tscn`

### Дерево:

```
SettingsScreen (Control) 
├── BGLayer (ColorRect) #282a36
│   └── ScanlineOverlay (ColorRect)
├── MainLayout (MarginContainer) 
│   └── VBox (VBoxContainer) 
│       ├── HeaderRow (HBoxContainer)
│       │   ├── TitleLabel (Label) — "НАСТРОЙКИ" size:28 color:#bd93f9
│       │   ├── Spacer 
│       │   └── BackButton (CyberButton) — ""
│       ├── TabContainer 
│       │   ├── GraphicsTab (ScrollContainer) — "ГРАФИКА"
│       │   │   └── VBox (VBoxContainer) 
│       │   │       ├── SettingRow_Resolution
│       │   │       ├── SettingRow_Fullscreen
│       │   │       ├── SettingRow_VSync
│       │   │       ├── SettingRow_Quality
│       │   │       └── SettingRow_FPS
│       │   ├── AudioTab (ScrollContainer) — "ЗВУК"
│       │   │   └── VBox
│       │   │       ├── SettingRow_Master
│       │   │       ├── SettingRow_Music
│       │   │       ├── SettingRow_SFX
│       │   │       └── SettingRow_Voice
│       │   └── ControlsTab (ScrollContainer) — "УПРАВЛЕНИЕ"
│       │       └── VBox
│       │           ├── SettingRow_Sensitivity
│       │           ├── SettingRow_InvertY
│       │           └── KeybindsList (VBoxContainer)
│       └── ButtonRow (HBoxContainer) 
│           ├── Spacer 
│           ├── ResetButton (CyberButton) — ""
│           └── ApplyButton (CyberButton) — ""
└── GlitchOverlay (GlitchOverlay)
```

### Компонент: SettingRow (переиспользуемый)

**Путь:** `res://ui/components/setting_row.tscn`  
**Скрипт:** `res://ui/components/setting_row.gd`

```
SettingRow (HBoxContainer)
├── SettingLabel (Label) 
├── Spacer (Control) 
└── ValueContainer (HBoxContainer) — сюда добавляется конкретный контрол
```

```gdscript
@tool
class_name SettingRow
extends HBoxContainer

@export var label_text: String = "Setting":
    set(value):
        label_text = value
        if is_node_ready():
            $SettingLabel.text = value

@onready var setting_label: Label = $SettingLabel
@onready var value_container: HBoxContainer = $ValueContainer

func _ready() -> void:
    setting_label.text = label_text
    setting_label.add_theme_color_override("font_color", Color("#f8f8f2"))
    setting_label.add_theme_font_size_override("font_size", 14)
    custom_minimum_size.y = 40
```

### TabContainer стиль:

В `dracula_theme.tres`, TabContainer:

- **Styles > panel:** StyleBoxFlat — bg `#282a36`, border `1` `#44475a`, corner all `0`
- **Styles > tab_selected:** StyleBoxFlat — bg `#44475a`, border_bottom `2` `#bd93f9`, corner 4/4/0/0
- **Styles > tab_unselected:** StyleBoxFlat — bg `#282a36`, border `0`, corner 4/4/0/0
- **Styles > tab_hovered:** StyleBoxFlat — bg `#44475a`, border_bottom `2` `#ff79c6`, corner 4/4/0/0
- **Colors > font_selected_color:** `#f8f8f2`
- **Colors > font_unselected_color:** `#6272a4`
- **Colors > font_hovered_color:** `#ff79c6`

### HSlider стиль (для ползунков звука):

- **Styles > slider:** StyleBoxFlat — bg `#44475a`, corner all `2`, content_margin `4`
- **Styles > grabber_area:** StyleBoxFlat — bg `#bd93f9`, corner all `2`
- **Styles > grabber_area_highlight:** StyleBoxFlat — bg `#ff79c6`, corner all `2`
- **Icons > grabber:** не используем текстуру — ставим StyleBoxFlat на grabber area

**Проблема:** HSlider в Godot 4.x плохо стилизуется через StyleBox для самого ползунка (thumb). Если нужен кастомный thumb — придётся рисовать текстуру 16x16 или использовать `set("theme_override_icons/grabber", texture)`. Рекомендую создать минимальную текстуру: белый кружок 16x16 с тонированием через modulate.

### Скрипт `settings_screen.gd`:

**Путь:** `res://ui/screens/settings_screen.gd`

```gdscript
extends Control

@onready var back_btn: Button = %BackButton
@onready var reset_btn: Button = %ResetButton
@onready var apply_btn: Button = %ApplyButton
@onready var glitch: GlitchOverlay = $GlitchOverlay

# Настройки хранятся в словаре, при Apply записываются в ConfigFile
var settings: Dictionary = {
    "resolution_index": 0,
    "fullscreen": false,
    "vsync": true,
    "quality": 2,
    "fps_limit": 60,
    "master_volume": 80,
    "music_volume": 70,
    "sfx_volume": 90,
    "voice_volume": 60,
    "sensitivity": 50,
    "invert_y": false,
}

var default_settings: Dictionary = settings.duplicate(true)
const SAVE_PATH = "user://settings.cfg"

func _ready() -> void:
    back_btn.pressed.connect(_on_back)
    reset_btn.pressed.connect(_on_reset)
    apply_btn.pressed.connect(_on_apply)
    _load_settings()
    _build_graphics_tab()
    _build_audio_tab()
    _build_controls_tab()

func _build_graphics_tab() -> void:
    var vbox = %GraphicsTab.get_node("VBox")

    # Resolution
    var res_option = OptionButton.new()
    res_option.add_item("1920x1080", 0)
    res_option.add_item("2560x1440", 1)
    res_option.add_item("3840x2160", 2)
    res_option.add_item("1280x720", 3)
    res_option.selected = settings.resolution_index
    res_option.item_selected.connect(func(idx): settings.resolution_index = idx)
    _add_setting_row(vbox, "РАЗРЕШЕНИЕ", res_option)

    # Fullscreen
    var fs_check = CheckButton.new()
    fs_check.button_pressed = settings.fullscreen
    fs_check.toggled.connect(func(val): settings.fullscreen = val)
    _add_setting_row(vbox, "ПОЛНЫЙ ЭКРАН", fs_check)

    # VSync
    var vs_check = CheckButton.new()
    vs_check.button_pressed = settings.vsync
    vs_check.toggled.connect(func(val): settings.vsync = val)
    _add_setting_row(vbox, "VSYNC", vs_check)

    # Quality
    var q_option = OptionButton.new()
    q_option.add_item("НИЗКОЕ", 0)
    q_option.add_item("СРЕДНЕЕ", 1)
    q_option.add_item("ВЫСОКОЕ", 2)
    q_option.add_item("УЛЬТРА", 3)
    q_option.selected = settings.quality
    q_option.item_selected.connect(func(idx): settings.quality = idx)
    _add_setting_row(vbox, "КАЧЕСТВО", q_option)

    # FPS limit
    var fps_slider = HSlider.new()
    fps_slider.min_value = 30
    fps_slider.max_value = 240
    fps_slider.step = 10
    fps_slider.value = settings.fps_limit
    fps_slider.custom_minimum_size.x = 200
    fps_slider.value_changed.connect(func(val): settings.fps_limit = int(val))
    var fps_label = Label.new()
    fps_label.text = str(settings.fps_limit)
    fps_label.add_theme_color_override("font_color", Color("#8be9fd"))
    fps_label.add_theme_font_size_override("font_size", 14)
    fps_label.custom_minimum_size.x = 40
    fps_slider.value_changed.connect(func(val): fps_label.text = str(int(val)))
    var fps_box = HBoxContainer.new()
    fps_box.add_child(fps_slider)
    fps_box.add_child(fps_label)
    _add_setting_row(vbox, "ЛИМИТ FPS", fps_box)

func _build_audio_tab() -> void:
    var vbox = %AudioTab.get_node("VBox")
    var audio_settings = {
        "ОБЩАЯ ГРОМКОСТЬ": "master_volume",
        "МУЗЫКА": "music_volume",
        "ЭФФЕКТЫ": "sfx_volume",
        "ГОЛОС": "voice_volume",
    }
    for label_text in audio_settings:
        var key = audio_settings
        var slider = HSlider.new()
        slider.min_value = 0
        slider.max_value = 100
        slider.step = 1
        slider.value = settings
        slider.custom_minimum_size.x = 200

        var val_label = Label.new()
        val_label.text = str(settings) + "%"
        val_label.add_theme_color_override("font_color", Color("#8be9fd"))
        val_label.add_theme_font_size_override("font_size", 14)
        val_label.custom_minimum_size.x = 50

        slider.value_changed.connect(func(val, k = key, lbl = val_label):
            settings = int(val)
            lbl.text = str(int(val)) + "%"
        )

        var box = HBoxContainer.new()
        box.add_child(slider)
        box.add_child(val_label)
        _add_setting_row(vbox, label_text, box)

func _build_controls_tab() -> void:
    var vbox = %ControlsTab.get_node("VBox")

    # Sensitivity
    var sens_slider = HSlider.new()
    sens_slider.min_value = 1
    sens_slider.max_value = 100
    sens_slider.value = settings.sensitivity
    sens_slider.custom_minimum_size.x = 200
    var sens_label = Label.new()
    sens_label.text = str(settings.sensitivity)
    sens_label.add_theme_color_override("font_color", Color("#8be9fd"))
    sens_label.custom_minimum_size.x = 40
    sens_slider.value_changed.connect(func(val):
        settings.sensitivity = int(val)
        sens_label.text = str(int(val))
    )
    var sens_box = HBoxContainer.new()
    sens_box.add_child(sens_slider)
    sens_box.add_child(sens_label)
    _add_setting_row(vbox, "ЧУВСТВИТЕЛЬНОСТЬ", sens_box)

    # Invert Y
    var inv_check = CheckButton.new()
    inv_check.button_pressed = settings.invert_y
    inv_check.toggled.connect(func(val): settings.invert_y = val)
    _add_setting_row(vbox, "ИНВЕРСИЯ Y", inv_check)

func _add_setting_row(parent: VBoxContainer, label_text: String, control: Control) -> void:
    var row = HBoxContainer.new()
    row.custom_minimum_size.y = 40

    var label = Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 220
    label.add_theme_color_override("font_color", Color("#f8f8f2"))
    label.add_theme_font_size_override("font_size", 14)
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    row.add_child(label)
    row.add_child(spacer)
    row.add_child(control)
    parent.add_child(row)

func _on_apply() -> void:
    _save_settings()
    _apply_settings()

    # Визуальный фидбек
    apply_btn.text = "✓ СОХРАНЕНО"
    apply_btn.add_theme_color_override("font_color", Color("#50fa7b"))
    await get_tree().create_timer(1.0).timeout
    apply_btn.text = ""
    apply_btn.remove_theme_color_override("font_color")

func _on_reset() -> void:
    settings = default_settings.duplicate(true)
    # Пересоздаём табы
    for tab_name in :
        var vbox = get_node(tab_name).get_node("VBox")
        for child in vbox.get_children():
            child.queue_free()
    await get_tree().process_frame
    _build_graphics_tab()
    _build_audio_tab()
    _build_controls_tab()

func _apply_settings() -> void:
    # Fullscreen
    if settings.fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

    # VSync
    DisplayServer.window_set_vsync_mode(
        DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED
    )

    # FPS
    Engine.max_fps = settings.fps_limit

    # Audio
    var bus_map = {
        "master_volume": "Master",
        "music_volume": "Music",
        "sfx_volume": "SFX",
        "voice_volume": "Voice",
    }
    for key in bus_map:
        var bus_name = bus_map
        var bus_idx = AudioServer.get_bus_index(bus_name)
        if bus_idx >= 0:
            var vol = settings
            if vol <= 0:
                AudioServer.set_bus_mute(bus_idx, true)
            else:
                AudioServer.set_bus_mute(bus_idx, false)
                AudioServer.set_bus_volume_db(bus_idx, linear_to_db(vol / 100.0))

func _save_settings() -> void:
    var config = ConfigFile.new()
    for key in settings:
        config.set_value("settings", key, settings)
    config.save(SAVE_PATH)

func _load_settings() -> void:
    var config = ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    for key in settings:
        if config.has_section_key("settings", key):
            settings = config.get_value("settings", key)

func _on_back() -> void:
    glitch.glitch_transition(0.4)
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://ui/screens/main_menu.tscn")
```

---

## 8. HUD

**Путь:** `res://ui/screens/hud.tscn`

### Дерево:

```
HUD (CanvasLayer) 
├── TopBar (HBoxContainer) 
│   ├── HealthBar (custom)
│   │   └── HealthContainer (HBoxContainer)
│   │       ├── HealthIcon (Label) — "♥"
│   │       ├── HealthBarBG (PanelContainer)
│   │       │   └── HealthBarFill (ColorRect)
│   │       └── HealthText (Label) — "100/100"
│   ├── Spacer 
│   └── ResourcesContainer (HBoxContainer) 
│       ├── Resource1 (HBoxContainer)
│       │   ├── ResIcon1 (Label) — "◆"
│       │   └── ResValue1 (Label) — "150"
│       ├── Resource2 (HBoxContainer)
│       │   ├── ResIcon2 (Label) — "⬡"
│       │   └── ResValue2 (Label) — "42"
│       └── Resource3 (HBoxContainer)
│           ├── ResIcon3 (Label) — "⚡"
│           └── ResValue3 (Label) — "88"
├── MinimapContainer (PanelContainer) 
│   └── MinimapPlaceholder (ColorRect) — заглушка
├── NotificationContainer (VBoxContainer) 
│   └── (динамические уведомления)
└── CrosshairCenter (CenterContainer) 
    └── Crosshair (Label) — "+"
```

### Настройки нод:

**HUD (CanvasLayer):** layer `10` — поверх игры.

**TopBar:**
- Anchors: `left:0, right:1, top:0, bottom:0`
- Offset Bottom: `56`
- MarginContainer обёртка с margins: `12`
- StyleBox panel: bg `#282a36CC` (alpha 0.8), border_bottom `1` `#44475a`

**HealthBarBG (PanelContainer):**
- Custom Minimum Size: `(200, 20)`
- StyleBox: bg `#44475a`, corner all `2`, border `1` `#6272a4`

**HealthBarFill (ColorRect):**
- Color: `#ff5555`
- Anchors: `left:0, top:0, bottom:1, right:1` (управляется скриптом)

**HealthIcon:** Color `#ff5555`, Font Size `18`

**HealthText:** Font Size `13`, Color `#f8f8f2`

**ResourcesContainer:**
- Separation: `16`

**ResIcon1 (◆):** Color `#ffb86c`, Font Size `16`
**ResValue1:** Color `#f8f8f2`, Font Size `14`

**ResIcon2 (⬡):** Color `#8be9fd`, Font Size `16`
**ResValue2:** Color `#f8f8f2`, Font Size `14`

**ResIcon3 (⚡):** Color `#f1fa8c`, Font Size `16`
**ResValue3:** Color `#f8f8f2`, Font Size `14`

**MinimapContainer:**
- Anchors: bottom-right
- Offset: `left:-180, top:-180, right:-12, bottom:-12`
- StyleBox: bg `#282a36CC`, border `1` `#bd93f9`, corner 0/8/0/8
- Custom Minimum Size: `(160, 160)`

**MinimapPlaceholder:**
- Color: `#44475a`
- Full rect внутри панели

**NotificationContainer:**
- Anchors: top-right
- Offset: `left:-360, top:64, right:-12`
- Separation: `4`

**Crosshair:**
- Text: `"+"`
- Font Size: `20`, Color: `#f8f8f280` (полупрозрачный)
- Horizontal/Vertical Alignment: Center

### Компонент: HUD Notification

**Путь:** `res://ui/components/hud_notification.tscn`

```
HUDNotification (PanelContainer)
└── HBox (HBoxContainer) 
    ├── IconLabel (Label) — "!"
    └── MessageLabel (Label) — "Текст уведомления"
```

- StyleBox: bg `#282a36E6`, border_left `3` `#50fa7b` (цвет зависит от типа), corner all `0`
- Custom Minimum Size: `(0, 36)`
- Content margins: left `12`, right `12`, top `6`, bottom `6`

### Скрипт `hud.gd`:

**Путь:** `res://ui/screens/hud.gd`

```gdscript
extends CanvasLayer

@onready var health_fill: ColorRect = %HealthBarFill
@onready var health_text: Label = %HealthText
@onready var health_bar_bg: PanelContainer = %HealthBarBG
@onready var res_value_1: Label = %ResValue1
@onready var res_value_2: Label = %ResValue2
@onready var res_value_3: Label = %ResValue3
@onready var notification_container: VBoxContainer = %NotificationContainer

const NotificationScene = preload("res://ui/components/hud_notification.tscn")

var max_health: float = 100.0
var current_health: float = 100.0

enum NotifyType { INFO, SUCCESS, WARNING, ERROR }
const NOTIFY_COLORS = {
    NotifyType.INFO: Color("#8be9fd"),
    NotifyType.SUCCESS: Color("#50fa7b"),
    NotifyType.WARNING: Color("#ffb86c"),
    NotifyType.ERROR: Color("#ff5555"),
}
const NOTIFY_ICONS = {
    NotifyType.INFO: "ℹ",
    NotifyType.SUCCESS: "✓",
    NotifyType.WARNING: "⚠",
    NotifyType.ERROR: "✕",
}

func set_health(value: float, max_val: float = -1.0) -> void:
    if max_val > 0:
        max_health = max_val
    current_health = clampf(value, 0.0, max_health)

    var ratio = current_health / max_health
    health_text.text = "%d/%d" % 

    # Анимация полоски
    var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(health_fill, "anchor_right", ratio, 0.3)

    # Цвет меняется по уровню здоровья
    var color: Color
    if ratio > 0.6:
        color = Color("#50fa7b")
    elif ratio > 0.3:
        color = Color("#ffb86c")
    else:
        color = Color("#ff5555")
    tween.parallel().tween_property(health_fill, "color", color, 0.3)

    # Тряска при низком здоровье
    if ratio <= 0.2:
        _shake_health_bar()

func _shake_health_bar() -> void:
    var original_pos = health_bar_bg.position
    var tween = create_tween()
    for i in 4:
        var offset = Vector2(randf_range(-3, 3), randf_range(-2, 2))
        tween.tween_property(health_bar_bg, "position", original_pos + offset, 0.04)
    tween.tween_property(health_bar_bg, "position", original_pos, 0.04)

func set_resource(index: int, value: int) -> void:
    var labels = 
    if index < 0 or index >= labels.size():
        return
    var label = labels
    var old_val = int(label.text) if label.text.is_valid_int() else 0

    # Числовая анимация
    var tween = create_tween()
    tween.tween_method(func(v): label.text = str(int(v)), float(old_val), float(value), 0.4)

    # Вспышка цвета при изменении
    var flash_color = Color("#50fa7b") if value > old_val else Color("#ff5555")
    label.add_theme_color_override("font_color", flash_color)
    tween.tween_callback(func():
        label.remove_theme_color_override("font_color")
    )

func show_notification(text: String, type: NotifyType = NotifyType.INFO, duration: float = 3.0) -> void:
    var notif = NotificationScene.instantiate()
    notification_container.add_child(notif)

    var icon_label = notif.get_node("HBox/IconLabel")
    var msg_label = notif.get_node("HBox/MessageLabel")

    icon_label.text = NOTIFY_ICONS
    icon_label.add_theme_color_override("font_color", NOTIFY_COLORS)
    msg_label.text = text
    msg_label.add_theme_color_override("font_color", Color("#f8f8f2"))
    msg_label.add_theme_font_size_override("font_size", 13)

    # Стилизуем border цветом типа
    var style = notif.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
    style.border_color = NOTIFY_COLORS
    notif.add_theme_stylebox_override("panel", style)

    # Анимация появления
    notif.modulate.a = 0.0
    notif.position.x += 30.0
    var target_x = notif.position.x - 30.0
    var tween = create_tween().set_parallel(true)
    tween.tween_property(notif, "modulate:a", 1.0, 0.2)
    tween.tween_property(notif, "position:x", target_x, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

    # Автоудаление
    await get_tree().create_timer(duration).timeout
    var fade = create_tween()
    fade.tween_property(notif, "modulate:a", 0.0, 0.3)
    fade.tween_callback(notif.queue_free)

# Тестовая функция для проверки
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1:
                set_health(current_health - 15.0)
            KEY_2:
                set_health(current_health + 10.0)
            KEY_3:
                set_resource(0, int(res_value_1.text) + randi_range(5, 20))
            KEY_4:
                show_notification("Новый игрок подключился", NotifyType.INFO)
            KEY_5:
                show_notification("Ресурсы собраны!", NotifyType.SUCCESS)
            KEY_6:
                show_notification("Здоровье критическое", NotifyType.ERROR)
```

---

## 9. UI Manager (переходы между экранами)

**Путь:** `res://ui/scripts/ui_manager.gd`

Это Autoload, добавляется в Project → Settings → Autoload с именем `UIManager`.

```gdscript
extends Node

var _glitch_layer: CanvasLayer
var _glitch_overlay: ColorRect
var _glitch_shader: ShaderMaterial

func _ready() -> void:
    _setup_transition_layer()

func _setup_transition_layer() -> void:
    _glitch_layer = CanvasLayer.new()
    _glitch_layer.layer = 100
    add_child(_glitch_layer)

    _glitch_overlay = ColorRect.new()
    _glitch_overlay.anchors_preset = Control.PRESET_FULL_RECT
    _glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _glitch_overlay.color = Color("#282a36")
    _glitch_overlay.visible = false

    _glitch_shader = ShaderMaterial.new()
    _glitch_shader.shader = preload("res://ui/components/scanline_shader.gdshader")
    _glitch_shader.set_shader_parameter("intensity", 0.0)
    _glitch_shader.set_shader_parameter("scanline_count", 300.0)
    _glitch_shader.set_shader_parameter("scanline_alpha", 0.08)
    _glitch_shader.set_shader_parameter("aberration_amount", 5.0)
    _glitch_shader.set_shader_parameter("flicker_speed", 12.0)
    _glitch_overlay.material = _glitch_shader

    _glitch_layer.add_child(_glitch_overlay)

func change_screen(scene_path: String, transition_duration: float = 0.5) -> void:
    _glitch_overlay.visible = true
    _glitch_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

    # Фаза 1: глитч нарастает
    var tween_in = create_tween()
    tween_in.tween_property(_glitch_shader, "shader_parameter/intensity", 1.0, transition_duration * 0.4)
    tween_in.parallel().tween_property(_glitch_overlay, "color:a", 1.0, transition_duration * 0.4)
    await tween_in.finished

    # Меняем сцену
    get_tree().change_scene_to_file(scene_path)
    await get_tree().process_frame

    # Фаза 2: глитч затухает
    var tween_out = create_tween()
    tween_out.tween_property(_glitch_shader, "shader_parameter/intensity", 0.0, transition_duration * 0.6)
    tween_out.parallel().tween_property(_glitch_overlay, "color:a", 0.0, transition_duration * 0.6)
    await tween_out.finished

    _glitch_overlay.visible = false
    _glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
```

**Использование из любого экрана:**

```gdscript
UIManager.change_screen("res://ui/screens/lobby_screen.tscn")
```

Это заменяет прямые вызовы `get_tree().change_scene_to_file()` во всех экранах — переходы будут с единообразным глитч-эффектом.

---

## 10. Создание Theme ресурса через код (bootstrap)

**Путь:** `res://ui/theme/theme_generator.gd`

Запускаешь один раз через `@tool` или из `_ready()` тестовой сцены — генерирует `dracula_theme.tres`:

```gdscript
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

    # === POPUP MENU (for OptionButton dropdown) ===
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
    ResourceSaver.save(theme, "res://ui/theme/dracula_theme.tres")
    print("Theme saved to res://ui/theme/dracula_theme.tres")
```

**Как запустить:** в Godot Editor → Script Editor → File → New Script → тип EditorScript → вставляешь код → File → Run (Ctrl+Shift+X).

---

## Потенциальные проблемы

**1. Unique Names (%NodeName):**
Каждую ноду, на которую ссылаешься через `%`, нужно пометить в редакторе: правый клик → "Access as Unique Name". Без этого `@onready var x = %X` выдаст null.

**2. Шрифт:**
Без моноширинного шрифта всё будет в системном дефолтном. Скачай JetBrains Mono, положи в `res://ui/theme/fonts/`, укажи в Theme → Default Font.

**3. TabContainer и ScrollContainer:**
В Godot 4.x TabContainer добавляет скрытую TabBar ноду. Дочерние ноды TabContainer становятся вкладками по имени. Если назовёшь ребёнка "ГРАФИКА" — таб будет "ГРАФИКА".

**4. CanvasLayer для HUD:**
HUD — CanvasLayer, а не Control. Если сделать Control — он будет в мировых координатах. CanvasLayer с layer:10 гарантирует, что HUD поверх 3D.

**5. CyberButton.gd и preload цветов:**
В `cyber_button.gd` используется `DColors.CYAN` — чтобы это работало, файл `colors.gd` должен иметь `class_name DColors`. Если Godot ругается на циклическую зависимость — замени на прямой `Color("#8be9fd")`.

**6. Тема не применяется к дочерним сценам:**
Theme наследуется вниз по дереву нод. Если ставишь Theme на корневой Control экрана — все дети получат стили. Если на отдельную ноду — только её поддерево. Рекомендую: ставь `dracula_theme.tres` в Project Settings → GUI → Theme → Custom, тогда она глобальная.

**7. HSlider thumb:**
StyleBoxFlat не покрывает сам ползунок HSlider. Нужна текстура 16x16 белый кружок. Создай PNG вручную или используй этот код в шейдере для генерации — но проще нарисовать.