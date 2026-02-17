# Настройка OAuth провайдеров для Nakama

Для работы авторизации через VK и Telegram необходимо настроить сервер Nakama. Ниже приведены шаги для настройки каждого провайдера.

## VK OAuth

### 1. Создание приложения VK

1. Перейдите на https://vk.com/apps
2. Создайте новое приложение типа "Standalone-приложение"
3. Запишите App ID и App Secret
4. В настройках приложения добавьте ваш домен в "Доверенные redirect URI"

### 2. Настройка сервера Nakama

В конфигурационном файле Nakama (server.yml) добавьте:

```yaml
social:
  vk:
    app_id: "your_vk_app_id" 54454085
    app_secret: "your_vk_app_secret" 
    Защищённый ключ 
 2YzfK5U0iNWnkwvuWSlO

 Сервисный ключ доступа
 2230c11f2230c11f2230c11f24210e265a222302230c11f4ba2e4bb780fdbfe6101e0af

 https://id.vk.com/about/business/go/docs/ru/vkid/latest/vk-id/connection/api-description
 https://id.vk.com/about/business/go/docs/ru/vkid/latest/vk-id/connection/create-application#Sozdanie-prilozheniya
```

## Telegram OAuth

Telegram использует немного другую модель аутентификации. Вместо стандартного OAuth, используется система Web Apps.

### 1. Создание Telegram бота

1. Обратитесь к @BotFather в Telegram
2. Создайте нового бота командой /newbot
3. Запишите токен бота 8437963041:AAFRWQQGvyfsnRT3VX7baj9xtjohq-1UT4c
4. Получите ID бота (это первая часть токена до двоеточия)
8437963041

### 2. Настройка сервера Nakama

Telegram авторизация в Nakama требует серверной логики для проверки подписи данных. Создайте модуль на языке Lua или Go:

#### Пример серверного кода (Lua) для проверки Telegram авторизации:

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

### 3. Размещение серверного кода

Поместите Lua-скрипт в папку `modules` внутри директории сервера Nakama и убедитесь, что сервер настроен на загрузку пользовательских модулей.

## Альтернативный способ: Использование Custom Authentication

Если настройка OAuth провайдеров на сервере затруднительна, можно использовать custom аутентификацию:

1. Пользователь проходит OAuth на стороннем сервисе (в браузере)
2. Приложение получает токен/данные аутентификации
3. Эти данные передаются на сервер Nakama через RPC для проверки
4. При успешной проверке сервер создает сессию для пользователя

Это менее безопасно, чем серверная проверка OAuth токенов, но проще в реализации.

## Тестирование

После настройки провайдеров можно протестировать аутентификацию:

1. Запустите клиентское приложение
2. Вызовите соответствующий метод аутентификации
3. Проверьте, что сессия создается успешно