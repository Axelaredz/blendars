# Workflow

## Godot Editor Path
```
/home/axxel/.var/app/io.github.MakovWait.Godots/data/godot/app_userdata/Godots/versions/Godot_v4_6_1-stable_linux_x86_64/Godot_v4.6.1-stable_linux.x86_64
```

## MCP Tools by File Type
| File       | Create              | Read/Edit                  |
|------------|---------------------|----------------------------|
| .gd        | create_script (MCP) | view_script → edit_file    |
| .tscn      | create_scene (MCP)  | get_scene_tree (MCP)       |
| .gdshader  | write_to_file       | view_script                |
| .yml/.conf | terminal cat >      | terminal cat               |
| .tres      | execute_editor_script | EditorScript            |

## GDAI MCP Supported Tools
### Project tools
- `get_project_info` - Получить данные о проекте из project.godot.
- `get_filesystem_tree` - Рекурсивное дерево файлов и директорий.
- `search_files` - Поиск файлов по запросу.
- `uid_to_project_path` - Конверт UID (uid://) в путь (res://).
- `project_path_to_uid` - Конверт путь (res://) в UID (uid://).

### Scene tools
- `get_scene_tree` - Рекурсивное дерево нод в текущей сцене.
- `get_scene_file_content` - Сырое содержимое файла сцены.
- `create_scene` - Создать сцену с root-нодой заданного типа.
- `open_scene` - Открыть сцену в редакторе.
- `delete_scene` - Удалить сцену по пути.
- `add_scene` - Добавить сцену как ноду к родителю.
- `play_scene` - Запустить текущую или главную сцену.
- `stop_running_scene` - Остановить запущенную сцену.

### Node tools
- `add_node` - Добавить ноду к родителю.
- `delete_node` - Удалить ноду (кроме root).
- `duplicate_node` - Дублировать ноду.
- `move_node` - Переместить ноду к другому родителю.
- `update_property` - Обновить свойство ноды.
- `add_resource` - Добавить ресурс или subresource как свойство.
- `set_anchor_preset` - Установить якорь Control с пресетом.
- `set_anchor_values` - Установить значения якорей для Control.

### Script tools
- `get_open_scripts` - Список открытых скриптов.
- `view_script` - Просмотр содержимого GDScript.
- `create_script` - Создать GDScript с содержимым.
- `attach_script` - Прикрепить скрипт к ноде.
- `edit_file` - Редактировать файл через find/replace.

### Editor tools
- `get_godot_errors` - Получить ошибки Godot.
- `get_editor_screenshot` - Скриншот окна редактора.
- `get_running_scene_screenshot` - Скриншот запущенной игры.
- `execute_editor_script` - Выполнить GDScript в редакторе.
- `clear_output_logs` - Очистить логи вывода.

## Required Order (ReAct Pattern: Reason-Act-Validate)
1. get_filesystem_tree / search_files → Проверить пути (reason: понять структуру).
2. view_script / get_scene_tree → Анализ контекста (reason: понять логику).
3. [Генерация кода] → Act: Создать/изменить.
4. get_godot_errors → Validate: Проверить ошибки. Если неизвестно — скажи прямо, не генерируй код.

## Image → Godot Pipeline (Chain-of-Thought)
### Phase 1: ANALYZE (всегда выводить, если есть image)
```
ВИЖУ:
- Тип: 2D / 3D / UI
- Сущности: [list with node type]
- Визуальные эффекты: [glow, particles → implementation]
- Неоднозначности: [assumptions made]
```
Fallback: Нет image — спроси, что реализовать, не генерируй код.

### Phase 2: ARCHITECT
- Simple (≤3 entities): Flat — main.tscn + scripts/.
- Medium (4-10): Scenes/entities/, scenes/ui/, scripts/.
- Complex (>10 или multiple screens): Hierarchy с autoload.
Entity как отдельная .tscn только если reusable или с логикой. Static decor — в main.tscn.

### Phase 3: ASSEMBLE
Order: shaders → scripts → scenes (dependencies first).
Format:
```
# = res://client/ui/scripts/element.gd =
// = res://client/shaders/element.gdshader =
; = res://client/scenes/element.tscn =
```

### Visual Fidelity
- Colors: Hex из image.
- Sizes: Proportional to viewport (2D: 1920×1080).
- Missing assets: ColorRect placeholder + comment "// Replace with asset".

### 3D Specific
- main.tscn: Camera3D + DirectionalLight3D / Environment.
- Meshes: Primitives (BoxMesh, SphereMesh) с materials.

### 2D Specific
- Camera2D с zoom.
- UI: Control с anchors, не position.

## Git Conventions
Commit: type(scope): description (e.g., feat(ui): add button glow).
Branch: feature/, fix/, hotfix/, release/.

## Структура папок UI
```
res://client/ui/
  ├── theme/ (default_theme.tres, fonts/, shaders/)
  ├── components/ (health_bar.tscn, inventory_slot.tscn, cyber_button.gd)
  ├── screens/ (main_menu.tscn, pause_menu.tscn, settings.tscn)
  └── hud/ (game_hud.tscn)
```

## Разделение UI и логики
```gdscript
# ❌ UI знает internals
func _process(delta: float) -> void:
    label.text = str(get_node("/root/World/Player").stats.health)

# ✅ UI слушает сигналы
func _ready() -> void:
    PlayerManager.health_changed.connect(_update_health)

func _update_health(current: int, maximum: int) -> void:
    hp_bar.value = current
    hp_bar.max_value = maximum
```

## Каждый UI-блок — отдельная сцена
Не строй весь UI в одном .tscn. Компоненты — отдельные, экраны инстанцируют.

## Выбор подхода к отрисовке UI
| Ситуация                          | Подход                          |
|-----------------------------------|---------------------------------|
| Прототип / game jam               | _draw()                         |
| Финальный UI с макетами           | Текстуры + 9-patch              |
| Динамические эффекты              | Шейдер                          |
| Мобилка, 50+ элементов            | Текстуры в атласе               |
| Процедурный UI                    | Шейдер + uniforms               |
| HUD с 3-5 элементами              | Что угодно                      |

Рекомендация: Статика — текстуры/9-patch; эффекты — шейдер; анимации — Tween + uniforms, не _process с queue_redraw.
