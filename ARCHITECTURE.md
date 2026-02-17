# Blendars - 3D MMO-кооператив Архитектура

## Overview

Гибридная архитектура: Nakama (social/auth/matchmaking) + Godot Headless Server (authoritative gameplay).

```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐
│   Client    │────▶│   Nakama    │────▶│ Godot Headless   │
│  (Godot)    │     │ (Auth/Chat) │     │   Server (ENet)  │
└─────────────┘     └─────────────┘     └──────────────────┘
                           │                      │
                    ┌──────┴──────┐        ┌──────┴──────┐
                    │ PostgreSQL  │        │   Players   │
                    │   Redis    │        │  (64 max)   │
                    └─────────────┘        └─────────────┘
```

## Структура проекта

```
blendars/
├── infrastructure/           # Docker & DevOps
│   ├── docker-compose.prod.yml    # Продакшн
│   ├── docker-compose.local.yml    # Локальная разработка
│   ├── nginx.conf            # Reverse proxy
│   ├── .env.example          # Пример конфига
|   ├── .env                  # Конфиг
│   └── scripts/
│       └── setup_vps.sh      # Настройка VPS
│
├── nakama-server/            # Nakama Lua модули
│   ├── src/
│   │   ├── main.lua          # Главный модуль + RPC
│   │   └── auth/
│   │       ├── vk.lua        # VK OAuth
│   │       └── telegram.lua   # Telegram Login
│   └── Dockerfile            # Кастомный образ
│
├── godot-project/           # Godot проект
│   └── src/
│       ├── shared/
│       │   └── protocol.gd   # Opcodes, константы
│       ├── server/
│       │   └── server_main.gd  # Authoritative server
│       └── client/
│           └── client_main.gd   # Клиент
│
└── .github/workflows/
    └── deploy.yml            # CI/CD
```

## Компоненты

### 1. Nakama Server (infrastructure/)
**Файлы:**
- `docker-compose.prod.yml` — PostgreSQL + Redis + Nakama + Nginx
- `nakama-server/src/auth/vk.lua` — VK OAuth 2.0
- `nakama-server/src/auth/telegram.lua` — Telegram Login Widget
- `nakama-server/src/main.lua` — RPC: health_check, validate_session

**Порты:**
- 7350 — Nakama HTTP
- 7349 — Nakama gRPC
- 80/443 — Nginx

### 2. Godot Server (godot-project/src/server/)
**Файл:** `server_main.gd`

**Функции:**
- ENet сервер на порту 7777
- Authoritative синхронизация позиций
- Tick rate: 20 TPS
- Валидация сессий через Nakama RPC
- Player join/leave broadcast

**Opcodes:**
- 0-4: System (PING, PONG, DISCONNECT)
- 100-103: Auth (AUTH_REQUEST, AUTH_RESPONSE)
- 200-211: Game State (PLAYER_MOVE, WORLD_UPDATE)
- 300-301: Chat
- 400-403: Matchmaking

### 3. Godot Client (godot-project/src/client/)
**Файл:** `client_main.gd`

**Функции:**
- ENet клиент
- Подключение к game server
- Синхронизация позиций других игроков
- Отправка своего положения на сервер

### 4. VPS Setup (infrastructure/scripts/)
**Файл:** `setup_vps.sh`

**Что делает:**
- Установка Docker
- Настройка UFW firewall
- Hardening SSH
- Создание пользователя
- Network tuning для game server

### 5. CI/CD (.github/workflows/)
**Файл:** `deploy.yml`

**Jobs:**
1. deploy-nakama — билд и пуш кастомного образа
2. deploy-game-server — билд Godot сервера, деплой
3. health-check — проверка после деплоя

## Как запустить

### Локальная разработка:
```bash
cd infrastructure
docker-compose -f docker-compose.local.yml up -d

# Проверка
curl http://localhost:7350/
```

### Деплой на VPS:
```bash
# 1. Настройка VPS
scp infrastructure/scripts/setup_vps.sh user@vps:/tmp/
ssh user@vps 'sudo bash /tmp/setup_vps.sh'

# 2. Загрузка конфигов
scp -r infrastructure user@vps:/opt/blendars/

# 3. Настройка переменных
ssh user@vps
cd /opt/blendars/infrastructure
cp .env.example .env
nano .env  # Заполнить реальными значениями

# 4. Запуск
docker-compose -f docker-compose.prod.yml up -d
```

## Переменные окружения (.env)

```bash
# Database
POSTGRES_PASSWORD=your_strong_password
NAKAMA_SESSION_KEY=32_char_hex_key
NAKAMA_SERVER_KEY=your_server_key

# VK OAuth
VK_CLIENT_ID=your_vk_app_id
VK_CLIENT_SECRET=your_vk_secret

# Telegram
TELEGRAM_BOT_TOKEN=your_bot_token

# Game Server
GAME_SERVER_PORT=7777
MAX_PLAYERS_PER_INSTANCE=64
```

## GitHub Secrets для CI/CD

```
NAKAMA_HOST=vps-ip-or-domain
NAKAMA_PORT=7350
NAKAMA_SERVER_KEY=your_key
POSTGRES_PASSWORD=your_db_password
VPS_HOST=your-vps-ip
VPS_USER=root
VPS_SSH_KEY=your_private_key
DOCKER_USERNAME=your-docker-hub
DOCKER_PASSWORD=your-docker-pass
```

## Масштабируемость

- **64 игрока на инстанс** — лимит ENet
- **Несколько инстансов** — балансировка через Nginx или Godot matchmaker
- **Nakama кластер** — не требуется для <1000 CCU

## Важные замечания

1. **GDScript vs Lua** — это РАЗНЫЕ языки. Не путай синтаксис.
2. **Nakama API v3.x** — используй актуальные методы
3. **VK OAuth** — требует валидного redirect_uri
4. **Telegram** — проверяй hash на сервере
5. **Security** — не коммить secrets в git

## Локальная разработка

### Запуск Nakama

```bash
# 1. Копируем Lua модули в volume
mkdir -p infrastructure/nakama_modules
cp nakama-server/src/*.lua infrastructure/nakama_modules/
cp nakama-server/src/auth/*.lua infrastructure/nakama_modules/

# 2. Запускаем
cd infrastructure
docker-compose -f docker-compose.local.yml up -d
```

### Проверка

```bash
# Health check
curl http://localhost:7350/

# Тест RPC
curl -X POST http://localhost:7350/v2/rpc/health_check

# Тест VK auth
curl -X POST http://localhost:7350/v2/rpc/vk_auth \
  -H "Content-Type: application/json" \
  -d '{"state": "test"}'
```

### Остановка

```bash
cd infrastructure
docker-compose -f docker-compose.local.yml down
```
