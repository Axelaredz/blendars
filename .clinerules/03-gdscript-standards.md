# GDScript 4.x Стандарты

## Синтаксис (строго)
✅ @onready, @export, @signal — аннотации Godot 4.x
✅ Типизация: var health: int = 100, func process(delta: float) -> void
✅ await для асинхронных вызовов
❌ Нет export (устарело), нет Godot 3.x API
❌ Нет C# или Python синтаксиса

## Code Quality Checklist
- [ ] Типизация переменных и функций
- [ ] Сигналы объявлены и подключены
- [ ] Пути res:// полные и существуют
- [ ] Нет print() в продакшене (push_warning/push_error)
- [ ] Обработка ошибок: if err != OK:
- [ ] Нет магических чисел (вынести в константы)
- [ ] Один класс — одна ответственность

## Performance
- @onready для кэширования нод
- set_process(false) когда не нужно
- Object pooling для частых spawn/despawn
- Избегать _process() для UI (использовать сигналы)
- Batch draw для Control-нод (общий parent)

## Структура проекта
res://core/autoload/          — синглтоны
res://core/networking/        — NetworkManager, AuthManager, LobbyManager
res://client/ui/              — UI экраны, компоненты
res://client/ui/theme/        — глобальная тема
res://client/ui/shaders/      — UI шейдеры
res://client/scenes/          — игровые сцены
res://infrastructure/         — docker-compose, nginx, nakama_modules
res://addons/                 — ⛔ не редактировать напрямую