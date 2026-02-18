# MCP / Cline Workflow

## Godot Editor Path
/home/axxel/.var/app/io.github.MakovWait.Godots/data/godot/app_userdata/Godots/versions/Godot_v4_6_1-stable_linux_x86_64/Godot_v4.6.1-stable_linux.x86_64

## Инструменты по типу файла
| Файл        | Создание              | Чтение/Редактирование     |
|-------------|-----------------------|---------------------------|
| .gd         | create_script (MCP)   | view_script → edit_file   |
| .tscn       | create_scene (MCP)    | get_scene_tree (MCP)      |
| .gdshader   | write_to_file         | view_script               |
| .yml/.conf  | терминал cat >        | терминал cat              |
| .tres       | execute_editor_script | EditorScript              |

## Обязательный порядок
1. get_filesystem_tree / list_files → проверить путь
2. view_script / get_scene_tree → понять контекст
3. [генерация кода]
4. get_godot_errors → валидация

## Plan Mode
- Сначала читать структуру проекта
- Не генерировать код до понимания контекста
- Уточнять только критичное для архитектуры

## Git Conventions
Commit: type(scope): description
feat(network): add VK OAuth authentication
fix(ui): login button hover state not updating
refactor(core): extract matchmaking logic
Branch: feature/, fix/, hotfix/, release/