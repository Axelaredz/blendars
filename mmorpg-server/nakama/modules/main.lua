-- MMORPG Server main module for Nakama

local nk = require("nakama")

-- Health check RPC function
local function health_check(context, payload)
    local response = {
        status = "ok",
        server = "mmorpg_server",
        version = "0.1.0",
        timestamp = os.time()
    }
    return nk.json_encode(response)
end

-- Client version RPC function
local function get_client_version(context, payload)
    local response = {
        version = "0.1.0",
        min_version = "0.1.0",
        update_required = false,
        packs = {}
    }
    return nk.json_encode(response)
end

-- Telegram Authentication via Bot API
local function authenticate_telegram(context, payload)
    local params = {}
    
    if type(payload) == "table" then
        params = payload
    elseif type(payload) == "string" and payload ~= "" then
        local user_id_match = string.match(payload, '"user_id"[%s:]+"([^"]+)"')
        local username_match = string.match(payload, '"username"[%s:]+"([^"]+)"')
        local first_name_match = string.match(payload, '"first_name"[%s:]+"([^"]+)"')
        
        if user_id_match then
            params.user_id = user_id_match
            params.username = username_match or ""
            params.first_name = first_name_match or "Telegram User"
        end
    end
    
    local user_id = params.user_id
    local username = params.username or ""
    local first_name = params.first_name or "Telegram User"
    
    if not user_id then
        return nk.json_encode({error = "user_id required"})
    end
    
    -- Используем стандартный Nakama authenticate_custom
    local custom_id = "telegram_" .. tostring(user_id)
    
    -- Для простоты возвращаем успешный ответ
    -- Сессия будет создана на стороне клиента
    return nk.json_encode({
        success = true,
        custom_id = custom_id,
        username = username,
        display_name = first_name,
        message = "Telegram auth ready. Use authenticate_custom with custom_id: " .. custom_id
    })
end

-- Register RPC functions
nk.register_rpc(health_check, "health_check")
nk.register_rpc(get_client_version, "get_client_version")
nk.register_rpc(authenticate_telegram, "authenticate_telegram")

nk.logger_info("MMORPG Server module loaded with Telegram auth!")
