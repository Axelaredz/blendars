# Constraints

## Anti-Overengineering
- Ровно столько, сколько нужно — не «на будущее»
- Начни малым → расширяй при повторных ошибках
- Не создавай абстракции для одноразовых операций
- simple > clever; extend before create; composition over inheritance
- Не добавляй features/рефакторинг сверх запроса

## GDScript Style

### Naming
- Классы: `PascalCase` — `PlayerController`, `UIHealthBar`
- Функции/переменные: `snake_case` — `move_player()`, `max_health`
- Константы: `UPPER_SNAKE` — `MAX_SPEED`, `GRAVITY`
- Сигналы: `past_tense` — `health_changed`, `player_died`
- Приватные: `_prefix` — `_internal_state`, `_calculate()`
- Ноды: `PascalCase` в дереве — `PlayerModel`, `AnimationPlayer`

### Типизация
- Type hints обязательны для аргументов и возвращаемых значений
- `@export` переменные — всегда с типом
- `var` без типа — только для локальных очевидных случаев

```gdscript
# ✅
func take_damage(amount: float) -> void:
    _health = maxf(_health - amount, 0.0)
    health_changed.emit(_health)

# ❌
func take_damage(amount):
    _health = max(_health - amount, 0)
```

### Структура скрипта
```
class_name → extends → @tool →
signals → enums → constants →
@export vars → public vars → private vars →
_ready() → _process() → _physics_process() →
public methods → private methods
```

## Defensive Coding Scope
Валидируй ТОЛЬКО на границах:
- ✅ Пользовательский ввод, сетевые пакеты, файловый I/O
- ✅ Данные от Nakama API, ответы RPC
- ❌ Между внутренними нодами, внутри гарантий Godot API
WHY: избыточные null-проверки в GDScript → шум, Godot сам кидает ошибки с контекстом

## Сцены (.tscn)
- Одна сцена = одна ответственность
- Переиспользуемые элементы → отдельная сцена + `@export` для конфигурации
- Не хардкодь пути к нодам за пределами прямых детей
WHY: `get_node("../../Player")` ломается при перестановке дерева

## Ресурсы
- `res://` для постоянных ресурсов
- `user://` для сохранений и кэша
- Не используй абсолютные пути ОС