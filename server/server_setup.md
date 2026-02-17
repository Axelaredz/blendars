# Настройка серверной части Nakama для кооперативной песочницы

## 1. Настройка OAuth провайдеров

### VK OAuth

Для работы VK OAuth на сервере Nakama необходимо:

1. В конфигурационном файле `server.yml` добавить:

```yaml
social:
  vk:
    app_id: "your_vk_app_id"
    app_secret: "your_vk_app_secret"
```

2. Перезапустить сервер Nakama

### Telegram Web App

Telegram авторизация требует серверной логики для проверки подписи данных. Создайте модуль:

#### Lua модуль для проверки Telegram авторизации (в папке `modules/`):

```lua
local nk = require('nakama')

-- Функция для проверки подписи данных Telegram
local function verify_telegram_auth(auth_data)
  local telegram_bot_token = "YOUR_BOT_TOKEN"
  
  -- Сортируем ключи данных
  local keys = {}
  for k in pairs(auth_data) do
    if k ~= "hash" then
      table.insert(keys, k)
    end
  end
  table.sort(keys)
  
  -- Формируем строку для проверки подписи
  local data_check_arr = {}
  for _, k in ipairs(keys) do
    table.insert(data_check_arr, k .. "=" .. auth_data[k])
  end
  local data_check_string = table.concat(data_check_arr, "\n")
  
  -- Вычисляем HMAC-SHA256 подпись
  local crypto = require('crypto')
  local secret_key = crypto.hmac.digest('sha256', telegram_bot_token, 'hex')
  local hash = crypto.hmac.digest('sha256', data_check_string, secret_key, 'hex')
  
  -- Сравниваем вычисленный хеш с полученным
  return hash == auth_data.hash
end

-- RPC функция для аутентификации через Telegram
local function auth_telegram(context, payload)
  local data = nk.json_decode(payload)
  local telegram_data = data.user_data
  
  -- Проверяем подпись данных
  if not verify_telegram_auth(telegram_data) then
    nk.logger_error("Invalid Telegram auth data signature")
    return nil, "Invalid signature"
  end
  
  -- Создаем или получаем пользователя по Telegram ID
  local user_id = telegram_data.id
  local username = telegram_data.first_name .. (telegram_data.last_name and " " .. telegram_data.last_name or "")
  
  -- Используем custom ID для аутентификации
  local account = nk.authenticator.custom(user_id, username, {})
  
  -- Возвращаем сессионный токен
  local session = nk.session_create(account.user_id, account.username, nil, nil, nil)
  
  return nk.json_encode({session = session})
end

nk.register_rpc(auth_telegram, "auth_telegram")
```

## 2. Настройка матчмейкинга

### Прямое создание матча

Для возможности создания прямых приглашений из лобби в матч, создайте RPC функцию:

```lua
-- RPC функция для создания прямого матча
local function create_direct_match(context, payload)
  local data = nk.json_decode(payload)
  local user_ids = data.user_ids
  local properties = data.properties or {}
  
  -- Создаем новый матч
  local match_id = nk.uuid_v4()
  local match_label = nk.json_encode(properties)
  
  -- Приглашаем пользователей в матч
  for _, user_id in ipairs(user_ids) do
    -- Отправляем приглашение пользователю
    local content = {
      match_id = match_id,
      properties = properties
    }
    
    nk.notification_send(user_id, "Match Invitation", 1, content, true)
  end
  
  -- Возвращаем информацию о созданном матче
  local match_info = {
    match_id = match_id,
    label = match_label,
    users = user_ids,
    properties = properties
  }
  
  return nk.json_encode({match_info = match_info})
end

nk.register_rpc(create_direct_match, "create_direct_match")
```

### Список активных матчей (для отладки)

```lua
-- RPC функция для получения списка активных матчей
local function list_active_matches(context, payload)
  -- В Nakama нет встроенной функции для получения списка всех матчей
  -- Эту информацию нужно хранить отдельно или использовать сессии
  
  -- Заглушка: возвращаем пустой список
  return nk.json_encode({matches = {}})
end

nk.register_rpc(list_active_matches, "list_active_matches")
```

## 3. Дополнительные настройки

### Конфигурация сервера

В файле `server.yml` убедитесь, что включены необходимые функции:

```yaml
# Настройки сессий
session:
  token_expiry_sec: 600  # 10 минут
  refresh_token_expiry_sec: 86400  # 24 часа

# Настройки матчмейкинга
matchmaker:
  max_intervals: 5  # Максимальное количество интервалов поиска
  interval_sec: 1   # Интервал проверки совпадений (в секундах)

# Настройки групп (для лобби)
groups:
  max_count: 1000000  # Максимальное количество групп
  max_user_count: 100  # Максимальное количество участников в группе
```

### Docker-compose для запуска

Пример `docker-compose.yml` для запуска Nakama с настроенными параметрами:

```yaml
version: '3'
services:
  nakama:
    image: heroiclabs/nakama:3.18.0
    entrypoint:
      - /bin/sh
      - -ecx
      - >
          /nakama/nakama migrate up --database.address postgresql://nakama:nakama@db:5432/nakama?sslmode=disable &&
          exec /nakama/nakama --config /nakama-data/server.yml
    ports:
      - "7349:7349"  # GRPC
      - "7350:7350"  # HTTP
      - "7351:7351"  # WebSocket
    volumes:
      - ./:/nakama-data
      - ./modules:/nakama/modules
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: nakama
      POSTGRES_USER: nakama
      POSTGRES_PASSWORD: nakama
    ports:
      - "5432:5432"
    volumes:
      - nakama_db:/var/lib/postgresql/data

volumes:
  nakama_db:
```

## 4. Тестирование

После настройки сервера можно протестировать функциональность:

1. Запустить сервер Nakama
2. Запустить клиент Godot
3. Пройти аутентификацию
4. Создать/присоединиться к лобби
5. Начать поиск матча

Все компоненты должны теперь работать вместе для обеспечения полной сетевой функциональности кооперативной песочницы.