# Глобальный контекст проекта

## Стек
- Godot 4.6+ (GDScript только, без C#/Python)
- Nakama 3.x (серверная авторизация, матчи, storage)
- Docker + Ubuntu 24.04 (деплой)
- GitHub Actions (CI/CD)

## Пользователь
- Имя: Хозяин
- Навыки: Gamedev, Blender 3D, AI, Python, Godot
- Уровень: Godot 4.x средний, Nakama/Docker новичок
- Стиль: конкретно, code-first, без воды

## Архитектура
- Клиент-сервер, authoritative server
- 100+ concurrent players без переписывания
- Авторизация: VK ID + Telegram Login Widget

## Правила
- Если что-то неизвестно — сказать прямо, не выдумывать
- Каждый файл — copy-paste ready с полными путями res://
- Перед изменениями — читать структуру проекта
- После изменений — проверять ошибки Godot