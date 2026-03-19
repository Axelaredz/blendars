# Styleguide: Киберпанк-аниме

## Visual Identity
Стиль: Studio Trigger × MAPPA × Guilty Gear Strive
Ключевые черты: высокий контраст, неоновые акценты, sharp outlines, dramatic lighting

## Цветовая палитра (reference)

| Назначение | Характер |
|---|---|
| Фон / среда | Тёмные тона: deep blue, charcoal, industrial grey |
| Акценты | Неон: cyan, magenta, electric yellow |
| UI primary | High contrast на тёмном фоне |
| Danger / alert | Red-orange, pulsing |

## Анимация — Limited Animation Style

| Принцип | Что это значит |
|---|---|
| **Stepped interpolation** | Нет плавного tweening — ключи без интерполяции (Nearest) |
| **Animation on 2s/3s** | 12 или 8 уникальных кадров в секунду, не 30/60 |
| **Hold frames** | Длинные паузы на ключевых позах для драматического эффекта |
| **Limited animation** | Двигается только то, что нужно — остальное статично |

### Настройки в Godot
```gdscript
# AnimationPlayer: stepped interpolation
# В .tres ресурсах анимации:
# tracks → interpolation_type = 0 (Nearest)

# Для AnimationTree: используй BlendTree с TimeScale
# чтобы управлять on 2s/3s динамически
```

### В Blender (export pipeline)
- Анимация на 12 FPS (on 2s) или 8 FPS (on 3s)
- Constant interpolation между ключами
- Export: glTF 2.0, НЕ включать baked smooth interpolation
- Smear frames и anticipation poses — вручную, не процедурно

## Шейдеры
- Anime outline: inverted hull или screen-space edge detection
- Cel-shading: 2-3 ступени света, резкие переходы
- Rim light: неоновый, привязан к palette акцентов

## UI-стиль
- Тёмные полупрозрачные панели
- Неоновые borders / glow на интерактивных элементах
- Шрифты: geometric sans-serif, uppercase для заголовков
- Анимации UI: snappy (ease-out, короткие, ≤ 0.2s), не bouncy