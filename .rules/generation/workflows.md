# Workflows

## Execution Loop (для всех ролей)
1. **Read** — прочитай связанные файлы и зависимости
2. **Plan** — коротко опиши шаги и риски
3. **Change** — внеси изменения компактно и атомарно
4. **Verify** — проверь: сцена открывается? скрипт парсится? нет ошибок в Output?
5. **Deliver** — итог: что изменено, что проверить вручную

## Build & Test

| Ситуация | Действие |
|---|---|
| Новая сцена/компонент завершён | Проверить через GDAI MCP: open scene, read errors |
| Изменён только комментарий | Не проверять |
| Изменён шейдер | Открыть сцену с материалом → визуальная проверка |
| Изменён netcode | Запустить 2 instance: `godot --headless` + клиент |
| Изменён Docker/infra | `docker compose -f docker-compose.local.yml up` |

## Deploy Pipeline (когда будет готов)

1. Lint: gdlint (если подключён)
2. Test: запуск dedicated server headless + test client
3. Build: godot --headless --export-release
4. Deploy: docker compose -f docker-compose.prod.yml up -d

<!-- Активировать когда проект дойдёт до стадии deploy -->

## Escalation
- Задача требует > 2 итераций → вернись к плану, уточни scope
- Непонятно какая роль → спроси
- Конфликт между ролями → приоритет: safety > Network > Gameplay > UI > Art > Infra