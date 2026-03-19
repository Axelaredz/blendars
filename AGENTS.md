# MMORPG Cyberpunk-Anime — Agent Rules

## Commands
- Run project: open in Godot Editor → F5
- Run server: `docker compose -f infrastructure/docker-compose.local.yml up`
- Run headless: `godot --headless --main-pack server.pck`

## Stack
Godot 4.7+ (GDScript) · Nakama · Netfox · Blender · Docker · Ubuntu 24.04

## Project Shape
Online 3D MMORPG. Monorepo: client + dedicated server + shared + infra.
- `godot-project/src/{client,server,shared}` — game code
- `res/` — Godot resources, scenes, UI
- `nakama-server/`, `nakama/modules/`, `infrastructure/nakama_modules/` — backend
- `infrastructure/` — Docker, nginx, scripts

## Art Style
Cyberpunk-anime (Studio Trigger × MAPPA × Guilty Gear Strive).
Limited animation: stepped interpolation, on 2s/3s, hold frames.
Cel-shading, anime outlines, neon accents on dark backgrounds.

## Code Style
- GDScript: type hints required, snake_case, signals in past_tense
- Script order: class_name → extends → signals → enums → constants → @export → vars → lifecycle → methods
- One scene = one responsibility
- `res://` for resources, `user://` for saves

## Boundaries
| ✅ Allowed | ⚠️ Ask First | ❌ Forbidden |
|---|---|---|
| CRUD .gd, .tscn, .tres | Delete scenes | Modify export configs |
| Read any file | Add autoload | Modify Nakama configs |
| Use GDAI MCP | Modify docker-compose | Read/write .env |
| Create resources in res/ | Modify project.godot | Push without review |
| Run project & tests | Add plugins | Modify infrastructure/ |

## Roles
Gameplay · UI · Network · Art · Infra — see `.rules/context/roles.md`

## Patterns
- UI components: separate scene + @export, or Theme Override
- Signals: direct connection (parent-child) or autoload event bus
- Network: Netfox state sync for frequent data, RPC for events
- Server authority: always validate on server, never trust client

## Testing
- New scene → open + check errors via GDAI MCP
- Network changes → headless server + test client
- Docker changes → `docker compose up` locally

## Git
- Never commit .env or credentials
- Use `${VAR_NAME}` placeholders in code

## Debug Mode
- `/debug` at end of message → rule trace after response
- `/debug full` → + improvement recommendations
- Without command → normal mode
- Details: `.rules/debug.md`

→ Full rules: `.rules/`