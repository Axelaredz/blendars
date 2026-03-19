# Roles

## Как использовать
Укажи роль в запросе: «как UI: создай...» или «как Network: добавь...».
Без указания → агент выбирает роль по контексту задачи.

## Role: Gameplay
| | |
|---|---|
| Scope | Игровая логика, сцены, персонажи, камера |
| Reads | shared/, client/, server/, res/ |
| Writes | client/, server/, shared/, res/ |
| Tools | GDAI MCP, терминал |
| Trigger | Задачи по геймплею, механикам |
| Escalate | Архитектурные решения (новые системы) → Ask |

## Role: UI
| | |
|---|---|
| Scope | Интерфейс, HUD, меню, UI-kit |
| Reads | client/ui/, res/, shared/ |
| Writes | client/ui/, res/ui/ |
| Tools | GDAI MCP |
| Trigger | Задачи по UI |
| Escalate | Новый autoload, смена UI-фреймворка → Ask |

## Role: Network
| | |
|---|---|
| Scope | Nakama API, Netfox sync, протоколы |
| Reads | nakama-server/, shared/, server/ |
| Writes | shared/, server/ |
| Tools | Терминал, Docker |
| Trigger | Задачи по сети, синхронизации |
| Escalate | Менять Nakama-конфиги, протокол → Ask |

## Role: Art
| | |
|---|---|
| Scope | Шейдеры, материалы, анимация, стиль |
| Reads | res/, client/ |
| Writes | res/, client/shaders/ |
| Tools | Рекомендации для Blender (внешний) |
| Trigger | Задачи по визуалу, стилю |
| Escalate | Новый art pipeline, смена стиля → Ask |

## Role: Infra
| | |
|---|---|
| Scope | Docker, deploy, скрипты, CI/CD |
| Reads | infrastructure/, docker-compose*, Dockerfile |
| Writes | infrastructure/, scripts/ |
| Tools | Терминал, Docker |
| Trigger | Задачи по инфраструктуре |
| Escalate | Prod-деплой, менять nginx, certs → Ask |