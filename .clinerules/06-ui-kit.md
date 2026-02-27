06-ui-kit.md
# Модульный UI Kit — BLEND ARS | Godot 4.6
Единственный источник правил для ИИ-агента.

---

## 1. КОНТРАКТ

```
Роль:      AI-агент, строящий модульный UI Kit
Стиль:     Киберпанк / sci-fi
Проект:    BLEND ARS
Движок:    Godot 4.6 stable, GDScript only
Приоритет: Модульность > Красота, Простота > Сложность
```

---

## 2. ЗАВИСИМОСТИ

### Аддоны в проекте

| Аддон   | Путь                    | Что даёт проекту                                  |
|---------|-------------------------|----------------------------------------------------|
| netfox  | res://addons/netfox/    | NetworkTime, NetworkRollback, TickInterpolation    |
| nakama  | res://addons/com.heroiclabs.nakama/ | Auth, matchmaking, leaderboards, storage, realtime |
| phantom_camera  | res://addons/phantom_camera/      | Камера: follow, зоны, переходы, тряска               |
| limbo_ai        | res://addons/limboai/             | Behavior Trees (BTPlayer), State Machines (LimboHSM) |

### Файловая структура сетевого слоя
```
res://
├── addons/
│ ├── netfox/
│ ├── com.heroiclabs.nakama/
│ ├── phantom_camera/
│ └── limboai/
│
├── client/
│ ├── ui/
│ │ ├── ui_kit/
│ │ └── screens/
│ │
│ ├── network/
│ │ ├── network_manager.gd
│ │ ├── nakama_client.gd
│ │ ├── match_handler.gd
│ │ └── player_sync.gd
│ │
│ └── camera/
│ └── camera_rig.tscn/.gd <- настройка PhantomCamera
│
├── shared/
│ └── game/
│ ├── unit_data.gd
│ ├── match_state.gd
│ ├── ai/
│ │ ├── trees/ <- .tres BehaviorTree ресурсы
│ │ │ ├── bt_infantry.tres
│ │ │ ├── bt_scout.tres
│ │ │ └── bt_turret.tres
│ │ ├── tasks/ <- кастомные BTTask
│ │ │ ├── bt_find_target.gd
│ │ │ ├── bt_move_to.gd
│ │ │ ├── bt_attack.gd
│ │ │ └── bt_flee.gd
│ │ └── states/ <- LimboHSM состояния
│ │ ├── unit_idle.gd
│ │ ├── unit_combat.gd
│ │ └── unit_retreat.gd
│ └── units/
│ └── unit_controller.gd <- BTPlayer + LimboHSM здесь
```


### Границы ответственности
```
| Задача                      | Кто решает       | НЕ дублировать в      |
|-----------------------------|------------------|-----------------------|
| Auth, аккаунты, сессии      | Nakama           | client/network/       |
| Matchmaking                 | Nakama           | client/network/       |
| Leaderboards, storage       | Nakama           | client/network/       |
| Realtime-транспорт          | Nakama socket    | netfox                |
| Синхронизация состояния     | netfox           | Nakama                |
| Rollback / prediction       | netfox           | Nakama                |
| Интерполяция тиков          | netfox           | UI Kit                |
| Камера: follow, переходы    | PhantomCamera    | свои скрипты камеры   |
| Камера: тряска, зоны        | PhantomCamera    | UI Kit                |
| AI: деревья поведения       | LimboAI (BT)    | свои if/else цепочки  |
| AI: стейт-машина юнитов     | LimboAI (HSM)   | свои enum-автоматы    |
| Состояние UI                | UiState          | network/, ai/         |
| Навигация клавиатурой       | UiNav            | network/, ai/         |
| Стили и токены              | UiTokens / Theme | network/, ai/         |
| Анимации UI                 | UiAnim           | network/, ai/         |
| Отображение данных          | Screen           | network/, ai/         |
```

### Разделение аддонов по доменам
Домен Аддон Слой
────────────────────────────────────────
Бэкенд Nakama server
Сеть netfox transport
Камера PhantomCamera client/3D
AI LimboAI shared/game
UI UI Kit (свой) client/ui

Каждый аддон живёт в своём домене.
Пересечений нет. Связь — через игровой код.

### Правила взаимодействия
UI Kit не импортирует ничего из addons/ и client/network/.
client/network/ не импортирует ничего из ui_kit/.
Связь между сетью и UI — только через Screen.
Screen получает данные от network_manager и отображает через organisms.
Сетевые ошибки/статусы передаются в UiState как флаги
(loading, error, connected, authenticated).
nakama_client.gd — единственный файл, который вызывает Nakama SDK.
match_handler.gd — единственный файл, который связывает Nakama и netfox.
PhantomCamera не влияет на UI — камера и UI на разных слоях.
LimboAI не импортирует UI Kit — AI решает что делать, UI показывает результат.
AI-данные попадают в UI через: unit_controller -> signal -> Screen -> Organism.

### Поток данных с AI и камерой
AI (LimboAI):
BTPlayer тикает дерево поведения
-> BTTask решает: атаковать цель
-> unit_controller испускает signal unit_attacking(target)
-> Screen слушает, обновляет UI (индикатор цели, статус)
-> UiState / Organism обновляет визуал

LimboHSM переключает состояние
-> unit_idle -> unit_combat
-> signal state_changed("combat")
-> Screen обновляет HUD (иконка состояния)

Камера (PhantomCamera):
PhantomCamera3D следит за юнитом
-> переключение камеры через приоритеты
-> camera_rig.gd управляет переключением
-> Screen может запросить смену камеры
-> camera_rig.set_target(unit)

AI и камера НЕ знают об UI Kit.
Screen — единственный мост.

### Поток данных
Авторизация:
Screen (логин)
-> nakama_client.authenticate()
-> Nakama server
-> session token
-> UiState.set_flag("authenticated", true)
-> Screen обновляет UI

Матч:
Screen (поиск игры)
-> match_handler.find_match()
-> Nakama matchmaking
-> матч найден, игроки подключены
-> netfox начинает синхронизацию
-> UiState.set_flag("in_match", true)
-> Screen переключает на игровой экран

UI Kit НЕ знает о сети и бэкенде. Screen — единственный мост.

---

## 2. ФАЙЛОВАЯ СТРУКТУРА

```
res://client/ui/
├── ui_kit/
│   ├── tokens/
│   │   ├── ui_tokens.gd            Autoload — константы (цвета, размеры, шрифты)
│   │   ├── ui_theme_builder.gd     class_name — фабрика Theme + variations
│   │   ├── ui_state.gd             Autoload — глобальное состояние UI
│   │   ├── ui_navigation.gd        Autoload — зоны навигации и фокуса
│   │   ├── ui_anim.gd              Autoload — анимационные пресеты
│   │   ├── ui_colors.tres
│   │   └── ui_theme.tres
│   │
│   ├── atoms/
│   │   ├── text_body.tscn/.gd
│   │   ├── text_label.tscn/.gd
│   │   ├── text_display.tscn/.gd
│   │   ├── text_hud.tscn/.gd
│   │   ├── icon_element.tscn/.gd
│   │   ├── divider.tscn/.gd
│   │   ├── divider_glow.tscn/.gd
│   │   ├── accent_bar.tscn/.gd
│   │   ├── dot_indicator.tscn/.gd
│   │   └── scanline_overlay.tscn/.gd
│   │
│   ├── molecules/
│   │   ├── menu_item.tscn/.gd
│   │   ├── hotkey_hint.tscn/.gd
│   │   ├── stat_line.tscn/.gd
│   │   ├── icon_button.tscn/.gd
│   │   ├── tab_item.tscn/.gd
│   │   ├── toggle_switch.tscn/.gd
│   │   ├── cyber_slider.tscn/.gd
│   │   └── cyber_dropdown.tscn/.gd
│   │
│   ├── organisms/
│   │   ├── main_nav.tscn/.gd
│   │   ├── title_bar.tscn/.gd
│   │   ├── hotkey_bar.tscn/.gd
│   │   ├── unit_card.tscn/.gd
│   │   ├── settings_group.tscn/.gd
│   │   ├── modal_dialog.tscn/.gd
│   │   └── notification_toast.tscn/.gd
│   │
│   ├── templates/
│   │   ├── layout_main_menu.tscn/.gd
│   │   ├── layout_arsenal.tscn/.gd
│   │   ├── layout_settings.tscn/.gd
│   │   └── layout_loading.tscn/.gd
│   │
│   ├── fx/
│   │   ├── crt_scanlines.gdshader
│   │   ├── noise_grain.gdshader
│   │   ├── vignette.gdshader
│   │   ├── chromatic_aberration.gdshader
│   │   ├── glow_text.gdshader
│   │   ├── glitch.gdshader
│   │   └── post_fx_layer.tscn/.gd
│   │
│   └── assets/
│       ├── fonts/          .ttf + .tres
│       ├── icons/          .svg
│       └── textures/       noise_512.png и т.д.
│
└── screens/
    ├── main_menu.tscn/.gd
    ├── arsenal_screen.tscn/.gd
    └── settings_screen.tscn/.gd
```

project.godot — Autoload:

```ini
[autoload]
UiTokens="*res://client/ui/ui_kit/tokens/ui_tokens.gd"
UiState="*res://client/ui/ui_kit/tokens/ui_state.gd"
UiNav="*res://client/ui/ui_kit/tokens/ui_navigation.gd"
UiAnim="*res://client/ui/ui_kit/tokens/ui_anim.gd"
```

---

## 3. СИНГЛТОНЫ

Обзор:

| Синглтон           | Тип        | Отвечает за                          | Кто использует                           |
|--------------------|------------|--------------------------------------|------------------------------------------|
| UiTokens           | Autoload   | Константы: цвета, размеры, шрифты    | Все уровни                               |
| UiThemeBuilder     | class_name | Фабрика Theme, регистрация variations | Screen вызывает get_theme() в _ready()   |
| UiState            | Autoload   | Состояние UI: экран, модалка, флаги  | Screen пишет, Organism/Molecule читает   |
| UiNav              | Autoload   | Зоны навигации, фокус, клавиатура    | Organism регистрирует, Screen переключает |
| UiAnim             | Autoload   | Анимационные пресеты                 | Organism/Screen вызывает                 |


### 3.1 UiThemeBuilder — каскадные стили

Подключение — одна строка в корне экрана:

```gdscript
func _ready() -> void:
    theme = UiThemeBuilder.get_theme()
```

Все дочерние узлы наследуют стили каскадно. Компоненты стилизуются только через variations:

```gdscript
# Запрещено:
_label.add_theme_font_override("font", load(...))
_label.add_theme_color_override("font_color", Color(...))

# Правильно:
_label.theme_type_variation = "LabelSecondary"
```

Реестр variations:

```
Label:
  "Label"            — default body
  "LabelSecondary"   — приглушённый
  "LabelAccent"      — неоновый акцент
  "LabelDisplay"     — крупный заголовок
  "LabelHUD"         — моноширинный
  "LabelMicro"       — мелкий вспомогательный

PanelContainer:
  "PanelContainer"   — default
  "PanelNav"         — навигационная панель
  "PanelCard"        — карточка
  "PanelModal"       — модальное окно

Новые variations — только в UiThemeBuilder.
```


### 3.2 UiState — глобальное состояние UI

Хранит только состояние. Не логику, не анимации, не ввод.

```
Хранит:                             Не хранит:
  current_screen: StringName          Позиции / размеры узлов
  previous_screen: StringName         Анимации
  active_menu_item: StringName        Данные 3D-сцены
  is_modal_open: bool                 Обработку ввода
  global_flags (loading, error)       Бизнес-логику игры
  is_connected: bool
  is_authenticated: bool
  is_in_match: bool
  network_error: String
```

Поток данных — однонаправленный:

```
User click
  -> MenuItem.signal
    -> Screen._on_nav_selected()
      -> UiState.navigate_to("arsenal")
        -> signal screen_changed
          -> MainNav обновляет визуал
          -> HotkeyBar обновляет хинты
          -> SceneManager загружает экран

Action -> State -> View
Компоненты не знают друг о друге.
```

Подписка (Organism читает):

```gdscript
func _ready() -> void:
    UiState.active_nav_changed.connect(_on_active_changed)
    UiState.screen_changed.connect(_on_screen_changed)

func _on_active_changed(item_id: StringName) -> void:
    for item in _item_nodes:
        item.is_active = (item.item_id == item_id)
```

Установка (Screen пишет):

```gdscript
func _on_nav_selected(item_id: String) -> void:
    UiState.active_nav_item = StringName(item_id)
    UiState.navigate_to(StringName(item_id))
```


### 3.3 UiNav — централизованная навигация

Единая точка обработки клавиатурного ввода. Организмы регистрируют свои элементы, а не ловят ввод сами.

```
Делает:                              Не делает:
  Хранит зоны навигации                Визуальные эффекты фокуса
  Переключает активную зону             Анимации
  Обрабатывает стрелки / Tab / Esc     Бизнес-логику
  wrapi() для зацикливания             Загрузку экранов
  Блокирует зоны под модалкой          Хранение данных
```

Регистрация (Organism при _ready):

```gdscript
func _ready() -> void:
    UiNav.register_zone(
        &"main_nav",
        _item_nodes as Array[Control],
        true  # сделать активной
    )

func _exit_tree() -> void:
    UiNav.unregister_zone(&"main_nav")
```

Из организма удаляется: `_unhandled_key_input()`, `_move_focus()`, `_focused_index` — всё теперь в UiNav.

Переключение (Screen):

```gdscript
UiNav.set_active_zone(&"arsenal_grid")
UiNav.push_modal_zone(&"dialog")   # блокирует остальные
```


### 3.4 UiAnim — анимационные пресеты

Централизованные анимации вместо копипасты Tween-логики в каждом компоненте.

```gdscript
# Запрещено (в каждом компоненте):
var tw := create_tween()
tw.set_ease(Tween.EASE_OUT)
tw.set_trans(Tween.TRANS_CUBIC)
tw.tween_property(self, "modulate:a", 1.0, 0.8)

# Правильно:
UiAnim.screen_enter(self)
UiAnim.stagger_slide_in(_item_nodes as Array[Control], UiAnim.SlideDirection.LEFT)
UiAnim.glitch(error_panel, 8.0, 0.4)
```

Длительности и easing хранятся в UiTokens.ANIM_*. UiAnim использует их внутри.


### 3.5 UiTokens — breakpoints (минимальная responsive-логика)

Полная responsive-система не нужна: Godot stretch mode решает 80% задач. Добавляется только трёхуровневая система:

```gdscript
enum ScreenTier { COMPACT, STANDARD, EXPANDED }
# COMPACT:  <= 1280px (720p, Steam Deck), ui_scale = 0.85
# STANDARD: 1281-1920px (1080p),          ui_scale = 1.0
# EXPANDED: > 1920px (1440p, 4K),         ui_scale = 1.15

func space(base: int) -> int:
    return roundi(base * ui_scale)

func font_size(base: int) -> int:
    return roundi(base * ui_scale)

func get_nav_width() -> int:
    match current_tier:
        ScreenTier.COMPACT:  return 220
        ScreenTier.STANDARD: return 280
        ScreenTier.EXPANDED: return 320
    return 280
```

Breakpoints используются только в templates и organisms. В атомах и молекулах — фиксированные константы, масштабируются stretch mode.

---

## 4. УРОВНИ КОМПОНЕНТОВ

Классификатор (сверху вниз):

```
Неделимый визуал?                      -> ATOM
Комбинация 2-5 атомов, одна функция?   -> MOLECULE
Блок из молекул, самодостаточный?      -> ORGANISM
Разметка зон без контента?             -> TEMPLATE
Экран с данными и логикой?             -> SCREEN
```

Сводная таблица:

| Свойство                | Atom   | Molecule | Organism       | Template | Screen        |
|-------------------------|--------|----------|----------------|----------|---------------|
| Бизнес-логика приложения| нет    | нет      | нет            | нет      | да            |
| Логика своего блока     | нет    | нет      | да             | нет      | да            |
| Знает контекст          | нет    | нет      | нет            | нет      | да            |
| Скрипт содержит         | стиль  | состояния| управление     | слоты    | логику        |
| Сигналы наверх          | нет    | да       | да (агрегир.)  | нет      | конечные      |
| get_parent()            | нет    | нет      | нет            | нет      | допустимо     |
| Динамические дети       | нет    | нет      | да             | нет      | да            |
| @export                 | да     | да       | да             | да       | нет           |
| Корневой узел           | Control| Control  | Control        | Control  | Control       |
| class_name              | Atom*  | Molecule*| Organism*      | Template*| Screen*       |
| UiState                 | нет    | читает   | читает         | нет      | пишет         |
| UiNav                   | нет    | нет      | регистрирует   | нет      | переключает   |
| UiAnim                  | нет    | нет      | вызывает       | нет      | вызывает      |

Интерактивные молекулы обязаны реализовать все 5 состояний:
default, hover, pressed, focused, disabled.

---

## 5. ЭТАЛОННЫЕ ДЕРЕВЬЯ УЗЛОВ

Atoms:

```
TextBody     — Label
AccentBar    — ColorRect
Divider      — ColorRect
DotIndicator — ColorRect
IconElement  — TextureRect
```

Molecules:

```
MenuItem (PanelContainer)
  HBox (HBoxContainer)
    AccentBar       <- atom
    Icon            <- TextureRect, optional
    Label           <- atom TextBody

HotkeyHint (HBoxContainer)
  KeyBadge (PanelContainer)
    KeyLabel (Label)
  ActionLabel (Label)

StatLine (HBoxContainer)
  StatLabel (Label)
  ProgressBar
  StatValue (Label)
```

Organisms:

```
MainNav (PanelContainer)
  VBox (VBoxContainer)
    SectionLabel    <- atom TextLabel
    ItemsContainer (VBoxContainer)
      MenuItem x N  <- molecule
    Divider         <- atom
    ExitItem        <- molecule MenuItem (variant=danger)
```

Templates:

```
LayoutMainMenu (Control) — full_rect
  Background (ColorRect)
  GridContainer
    TitleSlot (MarginContainer)      — top, 100%W
    NavSlot (MarginContainer)        — left, 280px
    ViewportSlot (MarginContainer)   — center, flex
    BottomSlot (MarginContainer)     — bottom, 100%W
  PostFXLayer <- instance
```

PostFXLayer:

```
PostFXLayer (CanvasLayer) — layer=100
  ScanlineRect (ColorRect)    <- crt_scanlines.gdshader
  NoiseRect (ColorRect)       <- noise_grain.gdshader
  VignetteRect (ColorRect)    <- vignette.gdshader
  AberrationRect (ColorRect)  <- chromatic_aberration.gdshader
```

---

## 6. НЕЙМИНГ

| Сущность     | Формат          | Пример                            |
|--------------|-----------------|-----------------------------------|
| Файлы        | snake_case      | menu_item.gd, menu_item.tscn      |
| class_name   | PrefixPascal    | AtomTextBody, MoleculeMenuItem     |
| Переменные   | snake_case      | is_active                          |
| Константы    | UPPER_SNAKE     | COLOR_ACCENT_PRIMARY               |
| Сигналы      | snake_case      | item_pressed                       |
| Приватные    | _prefix         | _is_hovered, _apply_style()        |
| @onready     | _prefix         | @onready var _label                |
| @export      | без prefix      | @export var label_text             |
| Узлы в .tscn | PascalCase      | TitleLabel, AccentBar              |
| Unique names | %PascalCase     | %TitleLabel                        |

---

## 7. ЗАПРЕТЫ

| Запрещено                                  | Правильно                                             |
|--------------------------------------------|-------------------------------------------------------|
| Color("#00F0FF") в компонентах             | UiTokens.COLOR_ACCENT_PRIMARY                         |
| padding = 16                               | UiTokens.SPACE_LG                                     |
| Magic numbers                              | Именованная константа в UiTokens                      |
| get_parent() в atom/molecule               | Сигналы наверх                                        |
| add_theme_*_override() в компонентах       | theme_type_variation = "..."                           |
| Хардкод Tween-анимаций в компоненте        | UiAnim.preset()                                        |
| Анимация без токена длительности           | UiTokens.ANIM_DURATION_*                               |
| Дублирование стилей между компонентами     | UiTokens.make_stylebox_*() или Theme variation         |
| God-объект                                 | Разбить по уровням                                     |
| Логика приложения в organism и ниже        | Логика приложения только в Screen                      |
| Post-fx внутри компонента                  | Только через PostFXLayer                               |
| Логика переходов внутри компонентов        | UiState.navigate_to() + подписка на сигнал             |
| Organism/Atom пишет в UiState              | Пишет только Screen; остальные только читают           |
| _unhandled_key_input() в организмах        | UiNav.register_zone() + централизованный ввод          |
| Своя focus-логика / wrapi() в компоненте   | Только через UiNav                                     |
| Opacity scanlines > 0.12                   | Правило 10% для эффектов                               |
| Opacity noise > 0.07                       | (см. выше)                                              |
| Opacity vignette > 0.6                     | (см. выше)                                              |
| Component Factory / UiFactory.create()     | preload().instantiate() с типизацией (см. раздел 10)   |
| import netfox/nakama в ui_kit/             | UI Kit не знает о сети; связь через Screen          |
| import ui_kit в client/network/            | Сетевой слой не знает об UI; связь через Screen     |
| Вызов Nakama SDK за пределами nakama_client.gd | Единая точка входа для бэкенда                  |
| Прямое взаимодействие netfox <-> UI        | netfox -> match_handler -> Screen -> UI             |
| import PhantomCamera / LimboAI в ui_kit/   | UI Kit не знает о камере и AI                       |
| if/else цепочки для AI поведения            | BehaviorTree через LimboAI                          |
| enum-стейт-машина для юнитов               | LimboHSM через LimboAI                              |
| Свои скрипты камеры (follow, transitions)  | PhantomCamera                                        |
| AI-логика напрямую обновляет UI            | signal -> Screen -> Organism                         |
---

## 8. ПРАВИЛО 70 / 20 / 10

Применяется к трём осям одновременно:

```
         70% база              20% структура       10% акцент
Цвет     Тёмное пространство   Средние тона        Неон
Шрифт    Body (основной)       Label (uppercase)   Display (glow)
Анимация Статичные элементы    Мягкие реакции      Яркие эффекты
FX       Без шейдера           Субтильный          Glow / glitch
```

Пропорции экрана (1920x1080):

```
Title zone:     ~8%H    = 86px
Content zone:   ~86%H   = 929px
Bottom zone:    ~6%H    = 65px
Nav width:      280px   (14.6%W)
Viewport:       flex    (85.4%W)
Негативное пространство: >= 70% площади
Активные элементы:       <= 30% площади
```

---

## 9. АЛГОРИТМ СОЗДАНИЯ ЭКРАНА

```
1. Аудит зон
   Какие зоны на экране? (top / left / center / bottom)
   Какие организмы нужны?

2. Инвентаризация
   organisms/ — что переиспользовать?
   molecules/ — что переиспользовать?
   atoms/     — что переиспользовать?

3. Достройка (снизу вверх)
   Недостающие atoms -> molecules -> organisms

4. Шаблон
   Есть подходящий template — используй.
   Нет — создай. Template = только разметка слотов.

5. Экран
   Screen инстанцирует template
   -> вставляет organisms в слоты
   -> подключает сигналы
   -> содержит бизнес-логику
   -> добавляет PostFXLayer

6. Верификация
   [ ] 70% — тёмное пространство
   [ ] 70% — основной шрифт
   [ ] 70% — статичные элементы
   [ ] <= 10% — неоновые акценты
   [ ] <= 10% — яркие эффекты
   [ ] Post-FX незаметны при беглом взгляде
```

---

## 10. АНТИПАТТЕРН: COMPONENT FACTORY

Фабрика компонентов (UiFactory.create("MenuItem", {})) запрещена.

Причины:

```
1. preload() проверяется при компиляции, load() — нет.
2. Factory возвращает Node — теряется типизация и autocomplete.
3. В .tscn видно инстанс; за вызовом create() — ничего не видно.
4. В Godot instantiate() уже является фабрикой.
```

Правильно:

```gdscript
const MENU_ITEM := preload("res://client/ui/ui_kit/molecules/menu_item.tscn")
var item := MENU_ITEM.instantiate() as MoleculeMenuItem
```

---

## 11. ЧЕК-ЛИСТ КОМПОНЕНТА

```
[ ] Уровень определён (atom / molecule / organism / template / screen)
[ ] Нет дубликата в существующем kit
[ ] Цвета         -> UiTokens.COLOR_*
[ ] Размеры       -> UiTokens.SPACE_*
[ ] Стили         -> theme_type_variation (не override)
[ ] Анимации      -> UiAnim.preset() или UiTokens.ANIM_*
[ ] @tool если нужен превью в редакторе
[ ] @export для настроек инспектора
[ ] Все состояния реализованы (hover / active / disabled / focused)
[ ] Сигналы вверх, нет get_parent()
[ ] class_name с префиксом уровня
[ ] doc-комментарии для класса и @export
```