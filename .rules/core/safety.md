# Safety

## Secrets
- `.env` содержит credentials — НИКОГДА не читай, не выводи, не логируй содержимое
- В коде: `${VAR_NAME}` / `OS.get_environment()`, не hardcoded значения
- Docker secrets → через environment в docker-compose, не в Dockerfile

## Nakama Credentials
- Server key, admin password — только через .env
- НЕ коммить `server.yml` с реальными credentials
- Примеры в документации → используй placeholder: `your-server-key-here`

## Network Safety
- Dedicated server = authoritative: клиент НЕ решает game state
- Валидируй ВСЕ клиентские пакеты на сервере
- Rate limiting на RPC вызовах Nakama
WHY: multiplayer без server authority = читы на первый день

## File Safety
- Не удаляй `.tscn`, `.tres` без подтверждения — могут быть зависимости
- Не перезаписывай `project.godot` — ломает весь проект
- Не трогай `export_presets.cfg`