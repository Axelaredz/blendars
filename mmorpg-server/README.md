# Blendars - 3D MMO-кооператив

**MMORPG в стиле cyberpunk-anime** (Studio Trigger × MAPPA × Guilty Gear Strive)

## Архитектура

Гибридная архитектура: **Nakama** (social/auth/matchmaking) + **Godot Headless Server** (authoritative gameplay).

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
mmorpg-server/
├── infrastructure/           # Docker & DevOps
│   ├── docker-compose.prod.yml    # Продакшн
│   ├── docker-compose.local.yml    # Локальная разработка
│   ├── nginx.conf            # Reverse proxy
│   ├── .env.example          # Пример конфига
│   ├── .env                  # Конфиг (не коммитить!)
│   └── scripts/
│       └── setup_vps.sh      # Настройка VPS
│
├── nakama-server/            # Nakama Lua модули
│   └── src/
│       ├── main.lua          # Главный модуль + RPC
│       ├── auth/
│       │   ├── vk.lua        # VK OAuth
│       │   └── telegram.lua  # Telegram Login
│       └── rpc/              # Дополнительные RPC
│
├── godot-project/            # Godot проект
│   └── src/
│       ├── shared/
│       │   └── protocol.gd   # Opcodes, константы
│       ├── server/
│       │   └── server_main.gd  # Authoritative server
│       └── client/
│           └── client_main.gd   # Клиент
│
└── res/                    # Godot ресурсы (сцены, UI)
```

## Компоненты

### 1. Nakama Server

**Порты:**
- `7350` — Nakama HTTP
- `7349` — Nakama gRPC
- `7351` — Nakama Console (Admin панель)

**Модули:**
- `nakama/modules/vk.lua` — VK OAuth 2.0
- `nakama/modules/telegram.lua` — Telegram Login Widget
- `nakama/modules/main.lua` — RPC: health_check, validate_session

### 2. Godot Game Server

**Файл:** `godot-project/src/server/server_main.gd`

**Функции:**
- ENet сервер на порту `7777`
- Authoritative синхронизация позиций
- Tick rate: `20 TPS`
- Валидация сессий через Nakama RPC
- Player join/leave broadcast

**Opcodes (protocol.gd):**
| Диапазон | Категория | Opcodes |
|----------|-----------|---------|
| 0-99 | System | PING, PONG, HELLO, GOODBYE, DISCONNECT |
| 100-199 | Auth | AUTH_REQUEST, AUTH_RESPONSE, AUTH_FAILED, HEARTBEAT |
| 200-299 | Game State | PLAYER_JOIN, PLAYER_MOVE, WORLD_UPDATE, COMBAT_* |
| 300-399 | Chat | CHAT_MESSAGE, CHAT_BROADCAST |
| 400-499 | Matchmaking | MATCH_FIND, MATCH_FOUND, MATCH_START, MATCH_END |

### 3. Godot Client

**Файл:** `godot-project/src/client/client_main.gd`

**Функции:**
- ENet клиент к Game Server
- Подключение к Nakama для авторизации
- Синхронизация позиций других игроков
- Отправка своего положения на сервер

### 4. VPS Setup

**Файл:** `infrastructure/scripts/setup_vps.sh`

**Что делает:**
- Установка Docker + Docker Compose Plugin
- Настройка UFW firewall
- Hardening SSH
- Network tuning для game server
- Fail2ban защита

**Открываемые порты:**
- `22` — SSH
- `80/443` — HTTP/HTTPS
- `7350` — Nakama HTTP
- `7351` — Nakama Metrics
- `7777` — Game Server TCP
- `7778` — Game Server UDP

## Как запустить

### Локальная разработка (SSHFS)

**Рекомендуемый workflow для разработки:**

1. **Подключение через SSHFS:**
   ```bash
   # Смонтируйте удалённую директорию проекта локально
   mkdir -p ~/mnt/blendars
   sshfs user@vps:/opt/blendars ~/mnt/blendars
   ```

2. **Запуск клиента (локально):**
   ```bash
   # В Godot Editor (графический режим):
   godot --path godot-project/ --editor
   # Или откройте проект в редакторе и нажмите F5
   ```

3. **Деплой сервера (на VPS):**
   ```bash
   # Быстрый деплой всех изменений
   ./manage.sh deploy
   
   # Или только Nakama
   ./manage.sh deploy-nakama
   
   # Или только Godot сервер
   ./manage.sh deploy-server
   ```

4. **Проверка логов:**
   ```bash
   # Логи Nakama
   ./manage.sh logs
   
   # Логи Godot сервера
   ./manage.sh godot-logs
   ```

### Локальная разработка (Docker)

```bash
cd infrastructure

# 1. Настройка переменных окружения
cp .env.example .env
nano .env  # Заполнить реальными значениями

# 2. Запуск Nakama + Redis + PostgreSQL
docker-compose -f docker-compose.local.yml up -d

# 3. Проверка
curl http://localhost:7350/
curl -X POST http://localhost:7350/v2/rpc/health_check
```

### Запуск Godot Game Server

```bash
# В Godot Editor:
# 1. Открыть godot-project/
# 2. Запустить сцену server_main.tscn
# 3. Или: godot --headless --main-pack server.pck

# Через CLI:
godot --headless --path godot-project/ src/server/server_main.gd
```

### Деплой на VPS

```bash
# 1. Настройка VPS
scp infrastructure/scripts/setup_vps.sh user@vps:/tmp/
ssh user@vps 'sudo bash /tmp/setup_vps.sh'

# 2. Загрузка конфигов
scp -r infrastructure user@vps:/opt/blendars/
scp -r nakama-server user@vps:/opt/blendars/
scp -r godot-project user@vps:/opt/blendars/

# 3. Настройка переменных
ssh user@vps
cd /opt/blendars/infrastructure
cp .env.example .env
nano .env  # Заполнить реальными значениями

# 4. Запуск
docker-compose -f docker-compose.prod.yml up -d

# 5. Проверка логов
docker-compose logs -f nakama
docker-compose logs -f game_server_manager
```

## Переменные окружения (.env)

```bash
# ============================================
# NAKAMA SERVER CONFIGURATION
# ============================================

# Database
POSTGRES_PASSWORD=changeme_postgres_password_32_chars_minimum

# Session encryption key - 32 байта (hex строка)
# Генерация: openssl rand -base64 32
NAKAMA_SESSION_KEY=0123456789abcdef0123456789abcdef

# Server key - публичный ключ для клиентов
NAKAMA_SERVER_KEY=your_server_key_here

# ============================================
# OAUTH PROVIDERS
# ============================================

# VK ID - получи на https://vk.com/apps?act=manage
VK_CLIENT_ID=your_vk_app_id
VK_CLIENT_SECRET=your_vk_client_secret
VK_REDIRECT_URI=https://your-domain.com/api/vk/callback

# Telegram - получи от @BotFather
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_BOT_USERNAME=your_bot_username

# ============================================
# GAME SERVER CONFIGURATION
# ============================================

GAME_SERVER_PORT=7777
GAME_SERVER_HOST=0.0.0.0
MAX_PLAYERS_PER_INSTANCE=64

# ============================================
# DOMAIN & SSL
# ============================================

DOMAIN=your-domain.com
SSL_CERT_PATH=./ssl/server.crt
SSL_KEY_PATH=./ssl/server.key
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

## Тестирование

### Health checks

```bash
# Nakama
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

## Важные замечания

1. **GDScript vs Lua** — это РАЗНЫЕ языты. Не путай синтаксис.
2. **Nakama API v3.x** — используй актуальные методы
3. **VK OAuth** — требует валидного redirect_uri
4. **Telegram** — проверяй hash на сервере
5. **Security** — не коммить secrets в git
6. **Server Authority** — всегда валидируй действия на сервере, никогда не доверяй клиенту

## Стек технологий

- **Godot 4.7+** (GDScript) — клиент и game server
- **Netfox 1.40.2** — state sync, lag compensation, rollback
- **Nakama 3.x** — social/auth/matchmaking
- **PostgreSQL 16** — основная БД
- **Redis 7** — сессии и кэш
- **Docker + Docker Compose** — контейнеризация
- **Nginx** — reverse proxy
- **Ubuntu 24.04** — VPS

## Лицензия

Proprietary — все права защищены.
