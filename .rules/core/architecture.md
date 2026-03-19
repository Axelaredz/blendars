# Architecture: Monorepo MMORPG

## Project Shape

Monorepo: клиент + dedicated server + shared-код + инфраструктура.

```
mmorpg-server/
├── godot-project/src/
│   ├── client/          # Клиентская логика, UI, рендеринг
│   ├── server/          # Dedicated server логика
│   └── shared/          # Общий код (протоколы, типы, утилиты)
├── res/                 # Ресурсы Godot: сцены, материалы, autoload
├── nakama-server/       # Nakama backend: auth, RPC, matchmaking
├── nakama/modules/      # Lua-модули Nakama: основная логика
├── infrastructure/
│   ├── nakama_modules/  # Lua-модули: telegram.lua, vk.lua
│   ├── docker-compose.local.yml
│   ├── docker-compose.prod.yml
│   └── scripts/
├── godot-server/        # Export-проект dedicated server
└── modules/             # Standalone Lua-модули (telegram_auth)
```

## Nakama — три директории, разные задачи

| Директория | Назначение | Язык |
|---|---|---|
| `nakama/modules/` | Core game logic | Lua |
| `nakama-server/src/` | Auth, RPC endpoints | Lua + TypeScript config |
| `infrastructure/nakama_modules/` | Social auth (Telegram, VK) | Lua |

WHY: не дубли — разные concerns. Не объединяй без явного запроса.

## Network Architecture

```
Client (Godot + Netfox)
  ↕ WebSocket/UDP
Dedicated Server (Godot headless + Netfox)
  ↕ gRPC / REST
Nakama (matchmaking, auth, persistence)
  ↕
PostgreSQL (via Docker)
```

- **Netfox** = client-side prediction + server reconciliation
- **Nakama** = matchmaking, auth, leaderboards, storage — НЕ game loop
- **Dedicated Server** = authoritative game state, физика, валидация

## Development Topology

```
┌─ Локальный ПК (source of truth) ───┐     ┌─ VPS Ubuntu 24.04 (2 GB) ──┐
│                                     │     │                             │
│  Godot Editor (клиент)              │     │  Docker:                    │
│  VS Code + Cline + Qwen Code        │────→│    Nakama                   │
│  Blender                            │rsync│    PostgreSQL               │
│  GDAI MCP                           │     │    Godot headless (ded.srv) │
│                                     │     │    nginx                    │
│  Тестируешь: F5 → коннект к VPS     │◄───►│                             │
│                                     │ WSS │                             │
└─────────────────────────────────────┘     └─────────────────────────────┘
```

| Компонент | Где работает | Почему |
|---|---|---|
| Godot Editor + клиент | Локально | Нужен GPU, UI, быстрая итерация |
| VS Code + агенты | Локально | Доступ к .rules/, GDAI MCP, Godot Tools |
| Blender | Локально | Тяжёлый, нужен GPU |
| Nakama + PostgreSQL | VPS (Docker) | Серверные сервисы, доступны по сети |
| Godot headless (dedicated server) | VPS (Docker) | Authoritative, рядом с Nakama |
| nginx | VPS (Docker) | Reverse proxy, SSL termination |

**Source of truth = локальный репозиторий.** VPS получает файлы через `sync.sh`.

## Constraints

- Shared-код: `godot-project/src/shared/` — единственное место для кода, используемого и клиентом, и сервером
- Клиент НЕ импортирует из `server/`, сервер НЕ импортирует из `client/`
- Docker = единственный способ запуска Nakama и инфры
- RAM 2 GB → PostgreSQL вместо CockroachDB, ограничивай `mem_limit` в Docker, swap 2 GB
- Source of truth = локальный репозиторий, VPS получает файлы через rsync
- Клиент в редакторе подключается к VPS по WebSocket (`ws://VPS_IP:7350`)
- НЕ правь файлы напрямую на VPS — они будут перезаписаны при следующем sync
WHY: правки на VPS теряются, конфликт с локальным source of truth