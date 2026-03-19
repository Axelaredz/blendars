# Workflows

## Execution Loop (для всех ролей)
1. **Read** — прочитай связанные файлы и зависимости
2. **Plan** — коротко опиши шаги и риски
3. **Change** — внеси изменения компактно и атомарно
4. **Verify** — проверь: сцена открывается? скрипт парсится? нет ошибок в Output?
5. **Deliver** — итог: что изменено, что проверить вручную, нужен ли sync на VPS

## Dev Environment

### Что где

| Действие | Где | Команда |
|---|---|---|
| Правка клиента/UI | Локально: VS Code + Godot Editor | Правишь → F5 в Godot |
| Правка серверной части | Локально: VS Code | Правишь → `./sync.sh` |
| Правка shared-кода | Локально: VS Code | Правишь → F5 + `./sync.sh` (оба) |
| Просмотр серверных логов | VPS через SSH | `ssh user@VPS && docker compose logs -f` |
| Перезапуск контейнеров | VPS через SSH | `ssh user@VPS && cd mmorpg-server && docker compose -f infrastructure/docker-compose.local.yml restart` |
| Полный redeploy | VPS через SSH | `./sync.sh` (включает restart) |

### Ключевые команды

```bash
# Синхронизация серверных файлов на VPS
./sync.sh

# Логи серверов (в отдельном терминале)
ssh user@VPS_IP "cd mmorpg-server && docker compose -f infrastructure/docker-compose.local.yml logs -f"

# Только Nakama логи
ssh user@VPS_IP "cd mmorpg-server && docker compose -f infrastructure/docker-compose.local.yml logs -f nakama"

# Статус контейнеров
ssh user@VPS_IP "cd mmorpg-server && docker compose -f infrastructure/docker-compose.local.yml ps"

# Перезапуск конкретного сервиса
ssh user@VPS_IP "cd mmorpg-server && docker compose -f infrastructure/docker-compose.local.yml restart nakama"
```

### Когда нужен sync

| Что изменил | Нужен sync? | Нужен restart? |
|---|---|---|
| Клиентский код (`client/`) | ❌ | ❌ |
| UI-компоненты (`res/ui/`) | ❌ | ❌ |
| Shared-код (`shared/`) | ✅ | ⚠️ Если сервер использует изменённый файл |
| Nakama модули (`nakama*/`) | ✅ | ✅ Nakama |
| Infrastructure (`infrastructure/`) | ✅ | ✅ Все контейнеры |
| Docker Compose | ✅ | ✅ `docker compose up -d` (recreate) |
| Godot server код (`server/`) | ✅ | ✅ Godot headless |
| Шейдеры, материалы | ❌ | ❌ |

## Build & Test

| Ситуация | Действие |
|---|---|
| Новая сцена/компонент (клиент) | F5 в Godot Editor → визуальная проверка |
| Новая сцена + GDAI MCP | `create_scene` → `open_scene` → `read_errors` |
| Изменён только комментарий | Не проверять |
| Изменён шейдер | Открыть сцену с материалом → визуальная проверка |
| Изменён shared-код | F5 клиент + `./sync.sh` + проверить серверные логи |
| Изменён netcode (Netfox) | `./sync.sh` → запустить клиент → проверить коннект и sync |
| Изменён Nakama-модуль | `./sync.sh` → `docker compose logs -f nakama` → проверить ошибки |
| Изменён Docker/infra | `./sync.sh` → `docker compose ps` → проверить что контейнеры up |

## Deploy Pipeline (когда будет готов)

```
1. Lint: gdlint (если подключён)
2. Test: запуск dedicated server headless + test client
3. Build: godot --headless --export-release
4. Sync: rsync → VPS
5. Deploy: ssh → docker compose -f docker-compose.prod.yml up -d
```

<!-- Активировать когда проект дойдёт до стадии deploy -->

## Troubleshooting

| Проблема | Причина | Решение |
|---|---|---|
| Клиент не коннектится к VPS | Firewall, порт 7350 закрыт | `ssh VPS "sudo ufw allow 7350"` |
| sync.sh: Permission denied | SSH-ключ не настроен | `ssh-copy-id user@VPS_IP` |
| Nakama OOM (Out of Memory) | 2 GB RAM, нет swap | `sudo fallocate -l 2G /swapfile && sudo swapon /swapfile` |
| Контейнер restart loop | Ошибка в конфиге | `docker compose logs [service]` → читай ошибку |
| Godot headless crash | Нехватка памяти | Добавь `mem_limit: 512m` в docker-compose |
| Изменения не применились | Забыл sync | `./sync.sh` |
| Изменения на VPS пропали | Правил на VPS напрямую | НЕ правь на VPS — source of truth локально |

## Escalation
- Задача требует > 2 итераций → вернись к плану, уточни scope
- Непонятно какая роль → спроси
- Конфликт между ролями → приоритет: safety > Network > Gameplay > UI > Art > Infra
- Нужен sync но непонятно что рестартить → покажи таблицу «Когда нужен sync», спроси