# Netfox — Библиотека сетевой синхронизации

**Версия:** 1.40.2  
**Совместимость:** Godot 4.1+  
**Лицензия:** MIT

## Установленные компоненты

| Компонент | Описание |
|-----------|----------|
| `netfox` | Ядро — тайминг, откат, prediction |
| `netfox.extras` | Высокоуровневые удобства (input, оружие) |
| `netfox.internals` | Общие утилиты (автоматическая зависимость) |
| `netfox.noray` | Интеграция noray для соединения игроков |
| `vest` | Вспомогательная библиотека |

## Структура

```
godot-project/addons/
├── netfox/              # Ядро
│   ├── netfox.gd        # Главный скрипт плагина
│   ├── core/            # Основные классы
│   ├── timing/          # Синхронизация времени
│   └── prediction/      # Prediction и rollback
├── netfox.extras/       # Дополнения
├── netfox.internals/    # Внутренние утилиты
└── netfox.noray/        # Noray интеграция
```

## Быстрый старт

### 1. Настройка сервера

```gdscript
# server_main.gd
extends Node

var host: NetfoxHost

func _ready() -> void:
    host = NetfoxHost.new()
    host.setup(NetfoxHost.Config.new())
    add_child(host)
```

### 2. Настройка клиента

```gdscript
# client_main.gd
extends Node

var client: NetfoxClient

func _ready() -> void:
    client = NetfoxClient.new()
    client.setup(NetfoxClient.Config.new())
    add_child(client)
    
    # Подключение к серверу
    client.connect_to_server("127.0.0.1", 7777)
```

### 3. Игрок с rollback

```gdscript
# player.gd
extends CharacterBody3D
class_name Player

@export var peer_id: int = 0

var rollback_sync: RollbackSynchronizer

func _ready() -> void:
    rollback_sync = RollbackSynchronizer.new()
    add_child(rollback_sync)
    
    # Настройка broadcast для input
    rollback_sync.enable_input_broadcast = true

func _physics_process(delta: float) -> void:
    # Netfox обработает input с rollback
    handle_input()
    move_and_slide()
```

## Основные возможности

### Синхронизированное время
```gdscript
var current_time := NetfoxTime.current_tick
var interpolation := NetfoxTime.get_interpolation_factor()
```

### Интерполяция состояний
```gdscript
@export var interpolator: StateInterpolator

func _process(delta: float) -> void:
    var state := interpolator.get_interpolated_state()
    apply_state(state)
```

### Компенсация лагов (CSP)
```gdscript
@export var csp: ContinuousStatePredictor

func predict_movement(input: InputData) -> Vector3:
    return csp.predict(input)
```

## Конфигурация для MMORPG

### Сервер (server_main.gd)
```gdscript
var config := NetfoxHost.Config.new()
config.tick_rate = 20                    # 20 TPS
config.max_clients = 64                  # 64 игрока
config.enable_lag_compensation = true    # Компенсация лагов
config.enable_prediction = false         # Сервер не предсказывает
```

### Клиент (client_main.gd)
```gdscript
var config := NetfoxClient.Config.new()
config.tick_rate = 20
config.enable_lag_compensation = true    # Включить компенсацию
config.enable_prediction = true          # Локальное предсказание
config.interpolation_delay = 100         # мс задержка интерполяции
```

## Интеграция с Nakama

```gdscript
# После авторизации через Nakama
var session: NakamaSession = ...

# Создаём Netfox клиент с токеном
var client := NetfoxClient.new()
client.setup(NetfoxClient.Config.new())
client.set_auth_token(session.token)
client.connect_to_server(game_server_host, game_server_port)
```

## Сеть с Netfox + ENet

```gdscript
# Создаём ENet peer
var peer := ENetMultiplayerPeer.new()
peer.create_client("127.0.0.1", 7777)
multiplayer.multiplayer_peer = peer

# Netfox будет использовать этот peer для синхронизации
var client := NetfoxClient.new()
client.use_peer(peer)
```

## Рекомендации для MMORPG

1. **Tick Rate:** 20-30 TPS для баланса между точностью и производительностью
2. **Интерполяция:** 100-150мс задержка для плавности
3. **Prediction:** Включить на клиенте, отключить на сервере
4. **Rollback:** Использовать для важных действий (combat, movement)
5. **Bandwidth:** Ограничить broadcast важных событий

## Обновление с предыдущих версий

### v1.35+
- Проверьте узлы `RollbackSynchronizer`
- Настройте `enable_input_broadcast` если нужно

### v1.1+
- `Interpolators` теперь static class
- Удалите из autoload если был

## Ресурсы

- **Документация:** https://github.com/foxssake/netfox
- **Примеры:** https://github.com/foxssake/netfox/tree/main/examples
- **Discord:** https://discord.gg/godotengine

## Примечания для проекта Blendars

- Netfox используется для синхронизации позиций игроков
- Сервер авторитетный — валидация на сервере
- Клиент prediction для отзывчивости
- Интеграция с Nakama для авторизации
