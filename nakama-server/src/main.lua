-- Main Nakama server module
-- Загружает все подмодули и регистрирует RPC
-- Копируй в: nakama/modules/main.lua

local nk = require("nakama")

-- Import auth modules (they self-register)
dofile("modules/auth/vk.lua")
dofile("modules/auth/telegram.lua")

-- Health check RPC
local function rpc_health_check(context, payload)
    return nk.json_encode({
        status = "ok",
        version = "1.0.0",
        timestamp = os.time()
    })
end

-- Get client version - для проверки версии клиента
local function rpc_get_client_version(context, payload)
    return nk.json_encode({
        version = "0.1.0",
        min_version = "0.1.0",
        update_required = false,
        server_url = "https://your-game-server.com"
    })
end

-- Validate session token from game server
-- Game server передаёт token от Nakama, мы проверяем его валидность
local function rpc_validate_session(context, payload)
    local params = nk.json_decode(payload) or {}
    local token = params.token
    
    if not token then
        return nk.json_encode({
            valid = false,
            error = "Missing token"
        })
    end
    
    -- Parse and validate token
    local ok, session = pcall(nk.session_from_token, token)
    
    if not ok or not session then
        return nk.json_encode({
            valid = false,
            error = "Invalid token"
        })
    end
    
    -- Check expiration
    local expires_at = session.expires_at
    if expires_at and expires_at < os.time() then
        return nk.json_encode({
            valid = false,
            error = "Token expired"
        })
    end
    
    return nk.json_encode({
        valid = true,
        user_id = session.user_id,
        vars = session.vars
    })
end

-- Register all RPC functions
nk.register_rpc(rpc_health_check, "health_check")
nk.register_rpc(rpc_get_client_version, "get_client_version")
nk.register_rpc(rpc_validate_session, "validate_session")

nk.logger_info("========================================")
nk.logger_info("Blendars Nakama Server v1.0.0 loaded")
nk.logger_info("VK Auth: enabled")
nk.logger_info("Telegram Auth: enabled")
nk.logger_info("========================================")
