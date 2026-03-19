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
CockroachDB / PostgreSQL (via Docker)
```

- **Netfox** = client-side prediction + server reconciliation
- **Nakama** = matchmaking, auth, leaderboards, storage — НЕ game loop
- **Dedicated Server** = authoritative game state, физика, валидация

## Constraints

- Shared-код: `godot-project/src/shared/` — единственное место для кода, используемого и клиентом, и сервером
- Клиент НЕ импортирует из `server/`, сервер НЕ импортирует из `client/`
- Docker = единственный способ запуска Nakama и инфры локально
- RAM 2 GB → учитывай при выборе решений (нет тяжёлых процессов параллельно)