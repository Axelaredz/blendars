# MCP: GDAI MCP (gdaimcp.com)

## Назначение
Контроль Godot Editor из агента: создание сцен, скриптов, чтение ошибок,
управление деревом нод.

## Allowed Operations

| Операция | Уровень | Комментарий |
|---|---|---|
| `create_scene` | ✅ Auto | Создание новых сцен |
| `add_node` | ✅ Auto | Добавление нод в сцену |
| `create_script` | ✅ Auto | Создание GDScript |
| `read_scene_tree` | ✅ Auto | Чтение структуры |
| `read_errors` | ✅ Auto | Чтение ошибок из Output |
| `open_scene` | ✅ Auto | Открытие сцены в редакторе |
| `run_project` | ✅ Auto | Запуск проекта |
| `remove_node` | ⚠️ Ask | Удаление нод |
| `modify_project_settings` | ⚠️ Ask | Изменение настроек проекта |
| `delete_file` | ❌ Forbidden | Удаление файлов через MCP |

## Error Handling
- MCP недоступен → сообщи пользователю, предложи ручное выполнение
- Godot Editor закрыт → «Откройте Godot Editor и повторите запрос»
- Ошибка в Output после действия → прочитай, исправь, повтори

## Rate Limiting
- Не отправляй > 5 MCP-команд подряд без паузы
- После create_scene → open_scene → read_errors (проверка)
WHY: GDAI MCP работает через Editor — массовые команды могут зависнуть