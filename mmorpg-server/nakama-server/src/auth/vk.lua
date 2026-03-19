-- VK OAuth authentication module for Nakama
-- Копируй в: nakama/modules/vk_auth.lua

local http = require("nakama.util.http")
local nk = require("nakama")

-- Config from environment
local VK_CLIENT_ID = os.getenv("VK_CLIENT_ID") or ""
local VK_CLIENT_SECRET = os.getenv("VK_CLIENT_SECRET") or ""
local VK_REDIRECT_URI = os.getenv("VK_REDIRECT_URI") or ""

-- VK API endpoints
local VK_TOKEN_URL = "https://oauth.vk.com/access_token"
local VK_USER_INFO_URL = "https://api.vk.com/method/users.get"

--[[
    VK OAuth flow:
    1. Client redirects user to VK authorization page
    2. VK redirects back with code
    3. Server exchanges code for access_token
    4. Server gets user info from VK
    5. Server creates/updates user in Nakama
]]

-- Generate VK authorization URL
local function get_vk_auth_url(state: string): string
    local params = {
        client_id = VK_CLIENT_ID,
        redirect_uri = VK_REDIRECT_URI,
        response_type = "code",
        scope = "email",
        state = state,
        v = "5.131"
    }
    
    local query_string = ""
    for k, v in pairs(params) do
        query_string = query_string .. k .. "=" .. nk.url_encode(v) .. "&"
    end
    
    return "https://oauth.vk.com/authorize?" .. query_string:gsub("%&$", "")
end

-- Exchange code for access token
local function exchange_code_for_token(code: string): {string: any}
    local post_data = {
        client_id = VK_CLIENT_ID,
        client_secret = VK_CLIENT_SECRET,
        code = code,
        redirect_uri = VK_REDIRECT_URI
    }
    
    local post_fields = ""
    for k, v in pairs(post_data) do
        post_fields = post_fields .. k .. "=" .. nk.url_encode(tostring(v)) .. "&"
    end
    
    local response, code = http.request(VK_TOKEN_URL, {
        method = "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        },
        body = post_fields:gsub("%&$", "")
    })
    
    if code ~= 200 then
        nk.logger_error("VK token exchange failed: " .. tostring(code))
        return nil
    end
    
    return nk.json_decode(response)
end

-- Get user info from VK
local function get_vk_user_info(access_token: string, user_id: string): {string: any}
    local params = {
        user_ids = user_id,
        access_token = access_token,
        fields = "photo_200,first_name,last_name,screen_name,sex,bdate",
        v = "5.131"
    }
    
    local query_string = ""
    for k, v in pairs(params) do
        query_string = query_string .. k .. "=" .. nk.url_encode(tostring(v)) .. "&"
    end
    
    local response, code = http.request(VK_USER_INFO_URL .. "?" .. query_string:gsub("%&$", ""), {
        method = "GET"
    })
    
    if code ~= 200 then
        nk.logger_error("VK user info request failed: " .. tostring(code))
        return nil
    end
    
    local data = nk.json_decode(response)
    if data and data.response and #data.response > 0 then
        return data.response[1]
    end
    
    return nil
end

-- RPC: Start VK OAuth flow
-- Returns auth URL to which client should redirect user
local function rpc_vk_auth(context: any, payload: string): string
    local params = nk.json_decode(payload) or {}
    local state = params.state or nk.uuid_v4()
    
    local auth_url = get_vk_auth_url(state)
    
    return nk.json_encode({
        auth_url = auth_url,
        state = state
    })
end

-- RPC: Handle VK callback
-- Called after user returns from VK with code
local function rpc_vk_callback(context: any, payload: string): string
    local params = nk.json_decode(payload) or {}
    local code = params.code
    local state = params.state
    
    if not code then
        return nk.json_encode({
            success = false,
            error = "Missing code parameter"
        })
    end
    
    -- Exchange code for token
    local token_data = exchange_code_for_token(code)
    if not token_data then
        return nk.json_encode({
            success = false,
            error = "Failed to exchange code for token"
        })
    end
    
    -- Get user info
    local vk_user = get_vk_user_info(token_data.access_token, token_data.user_id)
    if not vk_user then
        return nk.json_encode({
            success = false,
            error = "Failed to get user info"
        })
    end
    
    -- Create or get Nakama user
    -- Use VK user_id as custom_id for linking
    local vk_id = "vk:" .. tostring(token_data.user_id)
    
    local user_id, is_new
    local users = nk.users_fetch_id({vk_id})
    
    if #users > 0 then
        -- User exists, get their ID
        user_id = users[1].id
        is_new = false
    else
        -- Create new user
        local metadata = {
            vk_id = tostring(token_data.user_id),
            vk_screen_name = vk_user.screen_name,
            first_name = vk_user.first_name,
            last_name = vk_user.last_name,
            photo_200 = vk_user.photo_200,
            sex = vk_user.sex,
            bdate = vk_user.bdate
        }
        
        -- Also store email if available
        if token_data.email then
            metadata.email = token_data.email
        end
        
        user_id = nk.users_create({
            {
                id = vk_id,
                metadata = metadata,
                display_name = vk_user.first_name .. " " .. vk_user.last_name
            }
        })[1].id
        
        is_new = true
    end
    
    -- Create session for user
    local session = nk.session_create(user_id, {
        vk_id = tostring(token_data.user_id),
        email = token_data.email or "",
        platform = "vk"
    }, 3600 * 24 * 7) -- 7 days
    
    return nk.json_encode({
        success = true,
        is_new = is_new,
        session_token = session.token,
        user_id = user_id,
        expires_at = session.expires_at
    })
end

-- Register RPC functions
nk.register_rpc(rpc_vk_auth, "vk_auth")
nk.register_rpc(rpc_vk_callback, "vk_callback")

nk.logger_info("VK OAuth module loaded successfully")
