# Eval: чеклисты проверки

## GDScript
- [ ] Type hints на аргументах и return
- [ ] Сигналы в past_tense
- [ ] Нет хардкод-путей за пределами прямых детей
- [ ] @export с типом
- [ ] Порядок секций по constraints.md

## Сцены (.tscn)
- [ ] Одна ответственность
- [ ] Переиспользуемые элементы = отдельная сцена
- [ ] Нет circular dependencies
- [ ] Корневая нода — осмысленное имя

## UI-компоненты
- [ ] Соответствует styleguide (цвета, анимации)
- [ ] Hover/press feedback
- [ ] Работает на разных разрешениях (anchors/containers)
- [ ] Шрифт читаем на тёмном фоне

## Network
- [ ] Серверная валидация входящих данных
- [ ] Нет client authority на game state
- [ ] Rate limiting на RPC
- [ ] Reconnect handling

## Safety
- [ ] Нет hardcoded credentials
- [ ] .env не читается/выводится
- [ ] Secrets через environment variables