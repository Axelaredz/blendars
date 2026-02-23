# Правила модульного UI для Godot 4.6
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

## 1️⃣ TOKENS — Единственный источник правды
### ui_tokens.gd — AUTOLOAD (Singleton)
# res://client/ui/ui_kit/tokens/ui_tokens.gd

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
# res://client/ui/ui_kit/atoms/text_body.gd
**Дерево узлов:**
```
TextBody (Label)
```

### Atom: AccentBar
# res://client/ui/ui_kit/atoms/accent_bar.gd
**Дерево узлов:**
```
AccentBar (ColorRect)
```

### Atom: Divider
# res://client/ui/ui_kit/atoms/divider.gd
**Дерево узлов:**
```
Divider (ColorRect)
```

### Atom: DotIndicator
# res://client/ui/ui_kit/atoms/dot_indicator.gd


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
# res://client/ui/ui_kit/molecules/menu_item.gd
**Дерево узлов:**
```
MenuItem (PanelContainer)
├── HBox (HBoxContainer)
│   ├── AccentBar (AtomAccentBar.tscn)
│   ├── Icon (TextureRect) — опционально
│   └── Label (AtomTextBody.tscn)
```

### Molecule: HotkeyHint
# res://client/ui/ui_kit/molecules/hotkey_hint.gd
**Дерево узлов:**
```
HotkeyHint (HBoxContainer)
├── KeyBadge (PanelContainer)
│   └── KeyLabel (Label)
└── ActionLabel (Label)
```

### Molecule: StatLine
# res://client/ui/ui_kit/molecules/stat_line.gd
**Дерево узлов:**
```
StatLine (HBoxContainer)
├── StatLabel (Label)
├── ProgressBar (ProgressBar)
└── StatValue (Label)
```

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
# res://client/ui/ui_kit/organisms/main_nav.gd
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

### Organism: TitleBar
# res://client/ui/ui_kit/organisms/title_bar.gd

### Organism: HotkeyBar
# res://client/ui/ui_kit/organisms/hotkey_bar.gd

## 5️⃣ ШЕЙДЕРЫ POST-FX

### CRT Scanlines (10% — еле заметные)
# res://client/ui/ui_kit/fx/crt_scanlines.gdshader

### Noise / Film Grain
# res://client/ui/ui_kit/fx/noise_grain.gdshader

### Vignette
# res://client/ui/ui_kit/fx/vignette.gdshader

### Glow Text
#  res://client/ui/ui_kit/fx/glow_text.gdshader

### Chromatic Aberration
# res://client/ui/ui_kit/fx/chromatic_aberration.gdshader

### Post-FX Layer — комбинированный слой
# res://client/ui/ui_kit/fx/post_fx_layer.gd
**Дерево узлов:**
```
PostFXLayer (CanvasLayer) — layer = 100
├── ScanlineRect (ColorRect) — full screen, shader: crt_scanlines
├── NoiseRect (ColorRect) — full screen, shader: noise_grain
├── VignetteRect (ColorRect) — full screen, shader: vignette
└── AberrationRect (ColorRect) — full screen, shader: chromatic_aberration
```

---

## 6️⃣ TEMPLATES — Шаблоны экранов

### Template: MainMenu Layout
# res://client/ui/ui_kit/templates/layout_main_menu.gd
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


---

## 7️⃣ SCREENS — Экраны

### Screen: Main Menu
# res://screens/main_menu.gd

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
║  Title zone:     ~8% высоты    (≈86px при 1080p)      ║
║  Content zone:   ~86% высоты   (≈929px при 1080p)     ║
║  Bottom zone:    ~6% высоты    (≈65px при 1080p)      ║
║                                                       ║
║  Nav width:      280px fixed   (14.6% от 1920px)      ║
║  Viewport:       оставшееся   (85.4%)                 ║
║                                                       ║
║  Негативное пространство:  ≥70% площади экрана        ║
║  Активные элементы:        ≤30% площади экрана        ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```

> **Этот документ — полная спецификация.** ИИ-агент должен следовать каждому правилу буквально. При любом сомнении — перечитай секцию «Запреты» и «Принцип принятия решений».
