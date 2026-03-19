# Patterns

## Scene Composition: переиспользуемые UI-компоненты

### Вариант A (предпочтительный) — отдельная сцена + @export
```gdscript
# res/ui/components/cyber_button.gd
class_name CyberButton
extends Button

@export var style: StringName = &"primary"  # primary | secondary | danger
@export var glow_color: Color = Color.CYAN

func _ready() -> void:
    _apply_style()
```
When: компонент переиспользуется в 2+ местах

### Вариант B — Theme Override
```gdscript
# Через .tres тему — без кода
# res/ui/themes/cyber_theme.tres
# Button → StyleBoxFlat с неоновым border
```
When: только визуальные отличия, логика не нужна

### ❌ Антипаттерн
```gdscript
# Хардкод стилей в _ready()
func _ready():
    add_theme_color_override("font_color", Color(0, 1, 1))
    add_theme_stylebox_override("normal", _make_stylebox())
```
Why bad: не переиспользуемо, нет единого места для стиля, ломается при смене темы

---

## Signal Patterns: коммуникация между нодами

### Вариант A (предпочтительный) — direct signal connection
```gdscript
# Родитель подключает сигнал дочерней ноды
func _ready() -> void:
    $CyberButton.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
    pass
```
When: прямой родитель-потомок, 1:1 связь

### Вариант B — autoload event bus
```gdscript
# shared/event_bus.gd (autoload)
signal ui_action(action_name: StringName, payload: Dictionary)

# Из любого места:
EventBus.ui_action.emit(&"inventory_open", {})
```
When: связь между несвязанными нодами, 1:N broadcast

### ❌ Антипаттерн
```gdscript
get_node("../../HUD/HealthBar").update_health(hp)
```
Why bad: хрупкий путь, ломается при перестановке дерева

---

## Network Sync: Netfox-паттерны

### Вариант A — State sync (позиция, HP)
```gdscript
# Netfox: RollbackSynchronizer
# Синхронизируй через свойства, не RPC
@export var synced_position: Vector3
@export var synced_health: float
```
When: часто меняющиеся данные, нужна интерполяция

### Вариант B — Event RPC (чат, действие)
```gdscript
@rpc("any_peer", "reliable")
func send_chat_message(text: String) -> void:
    # Валидация на сервере обязательна
    if not _validate_message(text):
        return
```
When: редкие события, нужна гарантия доставки

### ❌ Антипаттерн
```gdscript
# Клиент устанавливает game state напрямую
position = received_position  # Нет server authority!
```
Why bad: нет серверной валидации → читы