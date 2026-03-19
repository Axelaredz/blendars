local nk = require('nakama')

-- Функция для проверки подписи данных Telegram
local function verify_telegram_auth(auth_data)
  local telegram_bot_token = "8437963041:AAFRWQQGvyfsnRT3VX7baj9xtjohq-1UT4c"  -- ЗАМЕНИТЬ на реальный Telegram Bot Token
  
  -- Проверяем обязательные поля
  if not auth_data.id or not auth_data.first_name or not auth_data.hash then
    return false, "Missing required fields"
  end
  
  -- Проверяем время истечения (если указано)
  if auth_data.auth_date then
    local current_time = os.time(os.date("!*t"))
    local auth_time = tonumber(auth_data.auth_date)
    if current_time - auth_time > 3600 then  -- 1 час
      return false, "Auth data expired"
    end
  end
  
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
    table.insert(data_check_arr, k .. "=" .. tostring(auth_data[k]))
  end
  local data_check_string = table.concat(data_check_arr, "\n")
  
  -- Вычисляем HMAC-SHA256 подпись
  local crypto = require('crypto')
  local secret_key = nk.sha256(telegram_bot_token, 'hex')
  local calculated_hash = nk.base64_encode(crypto.hmac.digest('sha256', data_check_string, secret_key, 'binary'))
  
  -- Сравниваем вычисленный хеш с полученным
  return calculated_hash == auth_data.hash
end

-- RPC функция для аутентификации через Telegram
local function auth_telegram(context, payload)
  local success, data = pcall(nk.json_decode, payload)
  if not success then
    nk.logger_error("Failed to decode Telegram auth payload: " .. payload)
    return nil, "Invalid payload"
  end
  
  local telegram_data = data.user_data
  
  -- Проверяем подпись данных
  local verified, error_msg = verify_telegram_auth(telegram_data)
  if not verified then
    nk.logger_error("Invalid Telegram auth data signature: " .. (error_msg or "unknown error"))
    return nil, "Invalid signature: " .. (error_msg or "unknown error")
  end
  
  -- Создаем или получаем пользователя по Telegram ID
  local user_id = tostring(telegram_data.id)
  local username = telegram_data.first_name .. (telegram_data.last_name and " " .. telegram_data.last_name or "")
  local display_name = username
  local avatar_url = telegram_data.photo_url or ""
  
  -- Проверяем, существует ли уже пользователь с таким Telegram ID
  local accounts = nk.account_get_by_ids({user_id})
  if accounts and #accounts > 0 then
    -- Пользователь уже существует, обновляем данные
    nk.account_update_id(user_id, username, display_name, avatar_url)
  else
    -- Создаем нового пользователя
    local account = nk.users_create({{
      id = user_id,
      username = username,
      display_name = display_name,
      avatar_url = avatar_url
    }})
  end
  
  -- Создаем сессию
  local session = nk.session_create(user_id, username, nil, nil, nil)
  
  -- Возвращаем сессионный токен и информацию о пользователе
  return nk.json_encode({
    session = session,
    user_id = user_id,
    username = username,
    display_name = display_name,
    avatar_url = avatar_url
  })
end

-- Регистрируем RPC функцию
nk.register_rpc(auth_telegram, "auth_telegram")