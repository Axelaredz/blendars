-- MMORPG Server main module for Nakama

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
        packs = {
            {
                name = "core.pck",
                url = "https://cdn.blendars.ru/core.pck",
                size = 0,
                hash = ""
            }
        }
    }
    return nk.json_encode(response)
end

-- Register RPC functions
nk.register_rpc(health_check, "health_check")
nk.register_rpc(get_client_version, "get_client_version")

-- Log successful load
nk.logger_info("MMORPG Server module loaded successfully!")