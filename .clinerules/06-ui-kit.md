# Модульный UI Kit — BLEND ARS | Godot 4.6
## Единственный источник правды для ИИ-агента

---

## 🎯 КОНТРАКТ

```
РОЛЬ:      AI-агент, строящий модульный UI Kit
СТИЛЬ:     Киберпанк / sci-fi
ПРОЕКТ:    BLEND ARS
ДВИЖОК:    Godot 4.6 stable, GDScript only
ПРИОРИТЕТ: Модульность > Красота, Простота > Сложность
```

---

## 🏗️ ФАЙЛОВАЯ СТРУКТУРА

```
res://client/ui/ui_kit/
├── tokens/          ← Autoload + ресурсы стилей
│   ├── ui_tokens.gd          (Autoload-синглтон)
│   ├── ui_colors.tres
│   └── ui_theme.tres
│
├── atoms/           ← Неделимые визуальные элементы
│   ├── text_body.tscn/.gd
│   ├── text_label.tscn/.gd
│   ├── text_display.tscn/.gd
│   ├── text_hud.tscn/.gd
│   ├── icon_element.tscn/.gd
│   ├── divider.tscn/.gd
│   ├── divider_glow.tscn/.gd
│   ├── accent_bar.tscn/.gd
│   ├── dot_indicator.tscn/.gd
│   └── scanline_overlay.tscn/.gd
│
├── molecules/       ← 2–5 атомов, одна функция
│   ├── menu_item.tscn/.gd
│   ├── hotkey_hint.tscn/.gd
│   ├── stat_line.tscn/.gd
│   ├── icon_button.tscn/.gd
│   ├── tab_item.tscn/.gd
│   ├── toggle_switch.tscn/.gd
│   ├── cyber_slider.tscn/.gd
│   └── cyber_dropdown.tscn/.gd
│
├── organisms/       ← Самодостаточные блоки из молекул
│   ├── main_nav.tscn/.gd
│   ├── title_bar.tscn/.gd
│   ├── hotkey_bar.tscn/.gd
│   ├── unit_card.tscn/.gd
│   ├── settings_group.tscn/.gd
│   ├── modal_dialog.tscn/.gd
│   └── notification_toast.tscn/.gd
│
├── templates/       ← Разметка экрана БЕЗ контента
│   ├── layout_main_menu.tscn/.gd
│   ├── layout_arsenal.tscn/.gd
│   ├── layout_settings.tscn/.gd
│   └── layout_loading.tscn/.gd
│
├── fx/              ← Шейдеры и пост-эффекты
│   ├── crt_scanlines.gdshader
│   ├── noise_grain.gdshader
│   ├── vignette.gdshader
│   ├── chromatic_aberration.gdshader
│   ├── glow_text.gdshader
│   ├── glitch.gdshader
│   └── post_fx_layer.tscn/.gd
│
└── assets/
    ├── fonts/       ← .ttf + .tres (FontFile ресурсы)
    ├── icons/       ← .svg
    └── textures/    ← noise_512.png и т.д.

res://client/ui/screens/       ← Готовые экраны с логикой
├── main_menu.tscn/.gd
├── arsenal_screen.tscn/.gd
└── settings_screen.tscn/.gd
```

---

## 📐 УРОВНИ КОМПОНЕНТОВ

### Классификатор (используй сверху вниз)

```
Неделимый визуал?                     → ATOM
Комбинация 2–5 атомов, одна функция?  → MOLECULE
Блок из молекул, самодостаточный?     → ORGANISM
Разметка зон без контента?            → TEMPLATE
Экран с данными и логикой?            → SCREEN
```

### Сводная таблица правил по уровням

| Свойство              | Atom     | Molecule  | Organism   | Template | Screen   |
|-----------------------|----------|-----------|------------|----------|----------|
| Содержит бизнес-логику| ✗        | ✗         | Свою       | ✗        | ✓        |
| Знает контекст        | ✗        | ✗         | ✗          | ✗        | ✓        |
| Скрипт                | Стиль    | Состояния | Управление | Слоты    | Логика   |
| Сигналы наверх        | —        | ✓         | ✓ (агрегир)| —        | Конечные |
| get_parent()          | ✗        | ✗         | ✗          | ✗        | Допустимо|
| Динамические дети     | ✗        | ✗         | ✓          | ✗        | ✓        |
| @export кастомизация  | ✓        | ✓         | ✓          | ✓        | —        |
| Корневой узел         | Control+ | Control+  | Control+   | Control  | Control  |
| class_name префикс    | Atom*    | Molecule* | Organism*  | Template*| Screen*  |

**Интерактивные молекулы** обязаны реализовать ВСЕ 5 состояний:
`default` → `hover` → `pressed` → `focused` → `disabled`

---

## 🧬 ЭТАЛОННЫЕ ДЕРЕВЬЯ УЗЛОВ

### Atoms

```gdscript
# TextBody — Label
# AccentBar — ColorRect
# Divider — ColorRect
# DotIndicator — TextureRect | ColorRect
# IconElement — TextureRect
```

### Molecules

```
MenuItem (PanelContainer)
├── HBox (HBoxContainer)
│   ├── AccentBar ← atom instance
│   ├── Icon (TextureRect) — optional
│   └── Label ← atom TextBody instance

HotkeyHint (HBoxContainer)
├── KeyBadge (PanelContainer)
│   └── KeyLabel (Label)
└── ActionLabel (Label)

StatLine (HBoxContainer)
├── StatLabel (Label)
├── ProgressBar
└── StatValue (Label)
```

### Organisms

```
MainNav (PanelContainer)
└── VBox (VBoxContainer)
    ├── SectionLabel ← atom TextLabel
    ├── ItemsContainer (VBoxContainer)
    │   └── MenuItem × N ← molecule instances
    ├── Divider ← atom
    └── ExitItem ← molecule MenuItem (variant=danger)
```

### Templates

```
LayoutMainMenu (Control) — full_rect
├── Background (ColorRect)
├── GridContainer
│   ├── TitleSlot (MarginContainer)     — top, 100%W
│   ├── NavSlot (MarginContainer)       — left, 280px
│   ├── ViewportSlot (MarginContainer)  — center, flex
│   └── BottomSlot (MarginContainer)    — bottom, 100%W
└── PostFXLayer ← instance
```

### PostFXLayer

```
PostFXLayer (CanvasLayer) — layer=100
├── ScanlineRect (ColorRect)   ← crt_scanlines.gdshader
├── NoiseRect (ColorRect)      ← noise_grain.gdshader
├── VignetteRect (ColorRect)   ← vignette.gdshader
└── AberrationRect (ColorRect) ← chromatic_aberration.gdshader
```

---

## 🔒 НЕЙМИНГ — Без исключений

| Сущность          | Формат            | Пример                           |
|-------------------|-------------------|----------------------------------|
| Файлы             | `snake_case`      | `menu_item.gd`, `menu_item.tscn` |
| class_name        | `PrefixPascal`    | `AtomTextBody`, `MoleculeMenuItem`|
| Переменные        | `snake_case`      | `is_active`                      |
| Константы         | `UPPER_SNAKE`     | `COLOR_ACCENT_PRIMARY`           |
| Сигналы           | `snake_case`      | `item_pressed`                   |
| Приватные         | `_prefix`         | `_is_hovered`, `_apply_style()`  |
| @onready          | `_prefix`         | `@onready var _label`            |
| @export           | **без** prefix    | `@export var label_text`         |
| Узлы в .tscn      | `PascalCase`      | `TitleLabel`, `AccentBar`        |
| Unique names      | `%PascalCase`     | `%TitleLabel`                    |

---

## 🚫 ЗАПРЕТЫ (таблица быстрой проверки)

| ✗ Запрещено                            | ✓ Правильно                               |
|----------------------------------------|--------------------------------------------|
| `Color("#00F0FF")` в компонентах       | `UiTokens.COLOR_ACCENT_PRIMARY`            |
| `padding = 16`                         | `UiTokens.SPACE_LG`                        |
| `get_parent()` в atom/molecule         | Сигналы наверх                             |
| God-объект                             | Разбить по уровням                         |
| Дублирование стилей                    | `UiTokens.make_stylebox_*()`               |
| Анимация без токена длительности       | `UiTokens.ANIM_DURATION_*`                 |
| Post-fx внутри компонента              | Только через `PostFXLayer`                 |
| Логика в organism/ниже                 | Логика только в `Screen`                   |
| Magic numbers                          | Именованная константа в `UiTokens`         |
| Opacity scanlines > 0.12              | Правило 10% для эффектов                   |
| Opacity noise > 0.07                  | ↑                                          |
| Opacity vignette > 0.6               | ↑                                          |

---

## ⚖️ ПРАВИЛО 70 / 20 / 10

Применяется к **трём осям** одновременно:

```
         70% база           20% структура      10% акцент
ЦВЕТ     Тёмное пространство  Средние тона       Неон
ШРИФТ    Body (основной)      Label (uppercase)  Display (glow)
ЭФФЕКТЫ  Статичные элементы   Мягкие реакции     Яркие эффекты
FX       Без шейдера          Субтильный          Glow/glitch
```

---

## 📐 ПРОПОРЦИИ ЭКРАНА (1920×1080)

```
Title zone:     ~8%H   ≈ 86px
Content zone:   ~86%H  ≈ 929px
Bottom zone:    ~6%H   ≈ 65px
Nav width:      280px  (14.6%W)
Viewport:       flex   (85.4%W)
Негативное пространство: ≥ 70% площади
Активные элементы:       ≤ 30% площади
```

---

## 🔄 АЛГОРИТМ СОЗДАНИЯ ЭКРАНА

```
1. АУДИТ ЗОНЫ
   Какие зоны? (top/left/center/bottom)
   Какие организмы нужны?

2. ИНВЕНТАРИЗАЦИЯ
   ✓ organisms/ — что переиспользовать?
   ✓ molecules/ — что переиспользовать?
   ✓ atoms/     — что переиспользовать?

3. ДОСТРОЙКА (снизу вверх)
   Недостающие atoms → molecules → organisms

4. ШАБЛОН
   Есть подходящий template? Используй.
   Нет? Создай. Template = ТОЛЬКО разметка слотов.

5. ЭКРАН
   Screen инстанцирует template
   → вставляет organisms в слоты
   → подключает сигналы
   → содержит бизнес-логику
   → добавляет PostFXLayer

6. ВЕРИФИКАЦИЯ 70/20/10
   ☐ 70% — тёмное пространство
   ☐ 70% — основной шрифт
   ☐ 70% — статичные элементы
   ☐ ≤10% — неоновые акценты
   ☐ ≤10% — яркие эффекты
   ☐ Post-FX незаметны при беглом взгляде
```

---

## ✅ ЧЕК-ЛИСТ ПЕРЕД КОММИТОМ КОМПОНЕНТА

```
☐ Уровень определён (atom/molecule/organism/template/screen)
☐ Нет дубликата в существующем kit
☐ Цвета     → UiTokens.COLOR_*
☐ Размеры   → UiTokens.SPACE_*
☐ Шрифты    → UiTokens.FONT_PATH_*
☐ Анимации  → UiTokens.ANIM_*
☐ @tool если нужен превью
☐ @export для настроек инспектора
☐ Все состояния (hover/active/disabled/focused)
☐ Сигналы вверх, нет get_parent()
☐ class_name с правильным префиксом уровня
☐ ## doc-комментарии для класса и @export
```