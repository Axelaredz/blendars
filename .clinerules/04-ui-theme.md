# UI Theme: Sci-Fi / Cyberpunk

## Activation
Triggers: UI, Control, тема, стиль, cyberpunk, экран, шейдер. Command: @ui.

## Theme overrides — ОБЯЗАТЕЛЬНЫЙ duplicate()
```gdscript
# ✅ Безопасно
var style := button.get_theme_stylebox(&"normal").duplicate()
style.bg_color = Color.RED
button.add_theme_stylebox_override(&"normal", style)

# Или новый
var style := StyleBoxFlat.new()
style.bg_color = Color.RED
style.corner_radius_all = 8  # Упрощено: все углы
button.add_theme_stylebox_override(&"normal", style)

# ❌ Мутация shared
var style := button.get_theme_stylebox(&"normal")
style.bg_color = Color.RED  # Изменит все!
```

## Полный набор override методов
```gdscript
control.add_theme_color_override(&"font_color", Color.WHITE)
control.add_theme_font_override(&"font", preloaded_font)
control.add_theme_font_size_override(&"font_size", 24)
control.add_theme_constant_override(&"margin_left", 16)
control.add_theme_stylebox_override(&"panel", stylebox)
control.add_theme_icon_override(&"icon", texture)

# Удаление/проверка
control.remove_theme_color_override(&"font_color")
control.has_theme_color_override(&"font_color")
```

## Массовая стилизация — Theme resource
```gdscript
# ✅ На родителе
var theme := Theme.new()
theme.set_font_size(&"font_size", &"Button", 20)
theme.set_color(&"font_color", &"Button", Color.WHITE)
root_control.theme = theme  # Дочерние наследуют

# ❌ Поштучно
for btn in get_tree().get_nodes_in_group("buttons"): btn.add_theme_font_size_override(&"font_size", 20)
```

## Type Variations
```gdscript
theme.add_type(&"DangerButton")
theme.set_type_variation(&"DangerButton", &"Button")
theme.set_color(&"font_color", &"DangerButton", Color.RED)
button.theme_type_variation = &"DangerButton"
```

## Приоритеты стилизации (таблица)
| Приоритет | Источник                          | Описание                     |
|-----------|-----------------------------------|------------------------------|
| 1 (высший)| add_theme_*_override()            | На конкретной ноде           |
| 2         | theme_type_variation              | Вариация типа                |
| 3         | theme на ноде                     | Собственная тема             |
| 4         | theme на предке                   | Наследование вверх           |
| 5         | Project Settings → Theme          | Глобальная тема              |
| 6 (низший)| Default Theme движка              | Встроенная                   |

## Dracula Palette (strict)
| Color       | Hex     | Usage (70/20/10 rule)    |
|-------------|---------|--------------------------|
| Background  | #282a36 | 70% — фоны панелей       |
| CurrentLine | #44475a | 20% — подложки           |
| Foreground  | #f8f8f2 | Основной текст           |
| Comment     | #6272a4 | Второстепенный текст     |
| Purple      | #bd93f9 | 10% — акцент, заголовки  |
| Pink        | #ff79c6 | Hover, активные          |
| Cyan        | #8be9fd | Иконки, статусы          |
| Green       | #50fa7b | Успех, онлайн            |
| Red         | #ff5555 | Ошибки, здоровье         |
| Orange      | #ffb86c | Ресурсы, предупреждения  |
| Yellow      | #f1fa8c | Подсказки                |

## Rule 70/20/10
| Aspect    | 70%                    | 20%                    | 10%                |
|-----------|------------------------|------------------------|--------------------|
| Colors    | Background             | CurrentLine            | Accents            |
| Space     | Content area           | Padding, nav           | Decor (glow)       |
| Hierarchy | Main content           | Secondary              | CTA, alerts        |
| Weight    | Light (text)           | Medium (buttons)       | Heavy (CTA)        |
| Typography| Base 14-16px Regular   | Large 18-24px Medium   | XL 28-36px Bold    |
| Interactive| Static                | Standard interactive   | Priority CTA       |

## Cyberpunk Techniques
- Glitch/scanlines: Шейдеры (10% decor).
- Beveled corners: StyleBoxFlat corner_radius.
- Font: Monospace.
- Animations: AnimationPlayer / Tween.
- Glow: Border + modulate (10% accents).

## Pre-output Checklist
- [ ] 70% dominant color.
- [ ] 20% secondary (interactive).
- [ ] 10% accents (critical).
- [ ] CTA highlighted.
- [ ] Max 3 font sizes.
Fallback: Если palette не подходит — предложи адаптацию, не применяй blindly.
