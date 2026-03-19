# Быстрый старт: 3D Third-Person с Netfox

## Готовые примеры в проекте

После установки Netfox доступны примеры в папке:
```
godot-project/examples/
├── multiplayer-fps/    # 3D шутер от первого лица (база для third-person)
├── forest-brawl/       # Полноценная арена-игра ( party game)
└── shared/             # Общие ресурсы
```

## Рекомендации

| Пример | Для чего | Сложность |
|--------|----------|-----------|
| **multiplayer-fps** | Быстрый тест, база для third-person | ⭐ Простой |
| **forest-brawl** | Полноценная игра с механиками | ⭐⭐⭐ Средняя |

## Запуск примера Multiplayer FPS

### 1. Откройте проект в Godot Editor
```bash
godot --path godot-project/ --editor
```

### 2. Запустите сервер
- Откройте сцену: `examples/multiplayer-fps/multiplayer-fps.tscn`
- Нажмите F5 (запуск сцены)
- Или создайте отдельный проект для сервера

### 3. Запустите клиент(ы)
- Откройте ту же сцену в другом окне Godot
- Или запустите несколько экземпляров

## Адаптация под Third-Person

### 1. Измените камеру

**Было (FPS):**
```gdscript
# player.gd - камера внутри игрока
@onready var camera = $Camera3D
```

**Сделайте (Third-Person):**
```gdscript
# player.gd - камера сзади игрока
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

func _ready():
    camera_pivot.position = Vector3(0, 1.5, 0)  # Уровень головы
    camera.position = Vector3(0, 0.5, 2.5)      # Сзади и выше
```

### 2. Добавьте модель персонажа

```gdscript
# player.gd
@onready var model = $Model
@onready var animation_player = $Model/AnimationPlayer

func _process(delta):
    if velocity.length() > 0.1:
        model.look_at(global_position + velocity)
        animation_player.play("walk")
    else:
        animation_player.play("idle")
```

### 3. Настройте управление

```gdscript
# player-input.gd
func _input(event):
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * sensitivity)
        camera_pivot.rotate_x(-event.relative.y * sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.5, 1.5)
```

## Интеграция с Nakama (опционально)

### 1. Авторизация клиента
```gdscript
# client_main.gd
extends Node

var nakama_client: NakamaClient
var nakama_session: NakamaSession
var netfox_client: NetfoxClient

func _ready():
    # 1. Авторизация через Nakama
    nakama_client = NakamaClient.new("defaultkey", "127.0.0.1", 7350, "http")
    nakama_session = await nakama_client.authenticate_async()
    
    # 2. Подключение к игровому серверу
    netfox_client = NetfoxClient.new()
    netfox_client.setup(NetfoxClient.Config.new())
    netfox_client.set_auth_token(nakama_session.token)
    netfox_client.connect_to_server("127.0.0.1", 7777)
```

### 2. Валидация на сервере
```gdscript
# server_main.gd
extends Node

var nakama_client: NakamaClient
var netfox_host: NetfoxHost

func _ready():
    nakama_client = NakamaClient.new("defaultkey", "127.0.0.1", 7350, "http")
    
    netfox_host = NetfoxHost.new()
    netfox_host.setup(NetfoxHost.Config.new())
    add_child(netfox_host)
    
    netfox_host.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(peer_id: int):
    # Валидация токена через Nakama RPC
    var token = get_peer_token(peer_id)
    var response = await nakama_client.rpc_async("validate_session", {"token": token})
    if not response.valid:
        kick_peer(peer_id)
```

## Минимальный пример без Nakama

### Сервер (server.tscn)
```gdscript
extends Node

var host: NetfoxHost

func _ready():
    host = NetfoxHost.new()
    var config := NetfoxHost.Config.new()
    config.tick_rate = 20
    config.max_clients = 64
    host.setup(config)
    add_child(host)
    
    print("[Server] Started on port 7777")
```

### Клиент (client.tscn)
```gdscript
extends Node

var client: NetfoxClient

func _ready():
    client = NetfoxClient.new()
    var config := NetfoxClient.Config.new()
    config.tick_rate = 20
    client.setup(config)
    add_child(client)
    
    client.connect_to_server("127.0.0.1", 7777)
    print("[Client] Connected to server")
```

### Игрок (player.tscn)
```gdscript
extends CharacterBody3D
class_name Player

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var model = $Model

var rollback_sync: RollbackSynchronizer

func _ready():
    if is_multiplayer_authority():
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        
        rollback_sync = RollbackSynchronizer.new()
        rollback_sync.enable_input_broadcast = true
        add_child(rollback_sync)

func _physics_process(_delta):
    var input_dir := Input.get_vector("left", "right", "forward", "backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        model.look_at(global_position + direction)
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    
    move_and_slide()
```

## Проверка работы

### 1. Запустите сервер
```bash
cd godot-project
godot --headless --path . examples/multiplayer-fps/multiplayer-fps.tscn
```

### 2. Запустите 2-3 клиента
- Откройте проект в Godot Editor
- Запустите сцену `examples/multiplayer-fps/multiplayer-fps.tscn` (F5)
- Повторите в других окнах

### 3. Проверьте синхронизацию
- Двигайтесь на одном клиенте
- Наблюдайте синхронизацию на других

## Следующие шаги

1. **Добавьте анимации** — используйте AnimationPlayer для walk/run/idle
2. **Настройте камеру** — добавьте преследование и сглаживание
3. **Добавьте стрельбу/атаки** — используйте Netfox для rollback
4. **Подключите Nakama** — для авторизации и matchmaking
5. **Оптимизируйте** — настройте tick rate и interpolation delay

## Ресурсы

- **Netfox Docs:** https://foxssake.github.io/netfox/
- **Примеры:** `godot-project/examples/`
- **Документация:** `godot-project/addons/NETFOX_README.md`
