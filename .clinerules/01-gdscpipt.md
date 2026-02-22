# GDScript 4.x Standards

## Syntax (strict)
- Annotations: @onready, @export.
- Typing: `var health: int = 100`, `func _process(delta: float) -> void`.
- Async: await.
- Signals: `signal health_changed(new_value: int)` — без @signal (не существует).
- No Godot 3.x API (e.g., no .connect("signal", self, "method")).
Guardrail: Только GDScript 4.6, типизация везде, no magic numbers (use constants).

## Code Quality
- Signals: Declare and connect.
- Paths: Full res:// that exist.
- Errors: `if err != OK: push_error("Desc")`.
- No print() in prod — push_warning/error.
- One class = one responsibility.

## Сигналы
```gdscript
signal health_changed(new_value: int)  # Без @signal
health_changed.emit(50)
```

## Подключение сигналов
```gdscript
button.pressed.connect(_on_button_pressed)
button.pressed.connect(_on_pressed.bind(data))
button.pressed.connect(_on_confirm, CONNECT_ONE_SHOT)
```

## Литералы
```gdscript
var path: NodePath = ^"UI/Label"  # NodePath
var action: StringName = &"ui_accept"
@onready var label: Label = %ScoreLabel  # Unique
@onready var label: Label = $UI/Label  # Sugar
```

## Аннотации
```gdscript
@onready var label: Label = %Label
@export var speed: float = 100.0
@export_range(0, 100) var hp: int
@export_group("Visual")
@tool
```

## Setter с оповещением
```gdscript
signal score_changed(value: int)
var score: int = 0:
    set(value):
        if score != value:
            score = value
            score_changed.emit(score)
```

## set_deferred
```gdscript
control.set_deferred("size", Vector2(200, 100))
await get_tree().process_frame  # Ждать layout
```

Чеклист: Typing everywhere, signals with emit, deferred for layout changes.
