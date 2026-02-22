# Core Context

## Структура правил
```
.clinerules/
  ├── 00-core.md      (базовые, CanvasLayer, virtual methods)
  ├── 01-gdscript.md  (синтаксис, API, ошибки)
  ├── 02-workflow.md  (архитектура, структура папок)
  ├── 03-ui-core.md   (layout, input, focus, safe area)
  ├── 04-ui-theme.md  (стилизация, приоритеты, duplicate())
  └── 05-ui-perf.md   (производительность UI)
```

## Stack
Godot 4.6+ (GDScript only, no C#/Python). Учитывать нововведения: Jolt Physics (default 3D), IK-фреймворк (IKModifier3D etc.), SSR, delta PCK, Direct3D 12 (Windows default), AGX tone mapping, Tracy profiler.

## User
Хозяин | Godot 4.x middle, Nakama/Docker novice | code-first, без воды.

## Architecture
```
res://core/autoload/       — синглтоны
res://core/networking/     — Managers (Network, Auth, Lobby)
res://client/ui/           — Экраны, компоненты, theme/
res://client/shaders/      — Глобальные шейдеры
res://client/scenes/       — Игровые сцены
res://infrastructure/      — Docker, nginx, nakama_modules
res://addons/              — Не редактировать напрямую
```

## Rules
- Неизвестно → Скажи прямо, не выдумывай.
- Файлы: Copy-paste ready с полными res:// путями.
- Перед изменениями: Читать структуру (get_filesystem_tree).
- После: Проверять ошибки (get_godot_errors).
- UID: Не генерировать uid:// — Godot назначит. Используй path: `[ext_resource type="Script" path="res://scripts/player.gd" id="1"]`.
- Пустой код: Не пиши `func _ready(): pass` — если не нужна, не пиши.
- Коллизии: Назначать слои по проекту. Comment в project.godot: `# Collision layers: 1=Player, 2=Environment, 3=Enemies`.

## CanvasLayer
- Рисует дочерние в отдельном пространстве, независимо от Camera2D.
- Layer: Для порядка слоёв (e.g., -1=фон, 0=мир, 10=HUD, 20=меню, 100=отладка). Оставляй зазоры.
Guardrail: Не мифы — перерисовывается каждый кадр, не оптимизация.

## Виртуальные методы
```gdscript
# ✅ С _префиксом, типизацией
func _ready() -> void: super()  # Вызов parent
func _process(delta: float) -> void: super(delta)
func _input(event: InputEvent) -> void: pass
func _gui_input(event: InputEvent) -> void: pass

# ❌ Без _ — игнорируется молча
func process(delta): pass
```

Чеклист: Всегда _префикс, super() для parent, типизация.
