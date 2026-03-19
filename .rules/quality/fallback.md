# Fallback: что делать когда правил не хватает

## Общий принцип
Нет правила → действуй по intent ближайшего правила.
Не можешь определить intent → спроси.

## По ролям

| Ситуация | Fallback |
|---|---|
| Неизвестный UI-паттерн | Следуй styleguide.md → тёмный фон, неон, snappy анимации |
| Неизвестный network-паттерн | Server authority, validate on server, ask if unsure |
| Новый тип ресурса | Создай в res/ с snake_case именем, отдельная сцена |
| Задача вне всех ролей | Спроси пользователя какая роль ближе |
| Конфликт между правилами | Priority chain: safety > constraints > task > architecture > style |

## Запрещено угадывать
- Удаление файлов → всегда Ask
- Nakama-конфигурация → всегда Ask
- Export-конфиги → всегда Forbidden
- Credentials → всегда Forbidden