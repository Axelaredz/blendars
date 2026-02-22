# UI Performance

## Не _process для статичного UI
```gdscript
# ✅ Реактивно
Global.score_changed.connect(_on_score_changed)
func _on_score_changed(new: int): score_label.text = str(new)

# ❌ Каждый кадр
func _process(_delta): score_label.text = str(Global.score)
```

## Отключай для скрытого
```gdscript
func _on_visibility_changed(): set_process(visible); set_process_input(visible)
```

## Текстуры и атласы
- Атлас: Один draw call.
- 9-patch: NinePatchRect / StyleBoxTexture для масштаба.

## RichTextLabel
```gdscript
rich_label.append_text("[color=red]Msg[/color]\n")
if rich_label.get_line_count() > 100: rich_label.clear()
```

## _draw() vs Шейдер vs Текстуры (таблица стоимости)
| Метод               | Draw calls (100 btn) | CPU     | GPU     | VRAM   |
|---------------------|----------------------|---------|---------|--------|
| _draw() GDScript    | 2000+                | Высокая | Низкая  | ≈0     |
| Шейдер              | 100                  | Низкая  | Низкая  | ≈0     |
| Текстуры (атлас)    | 2-5                  | Мин.    | Мин.    | 2 МБ   |
| Текстуры (россыпь)  | 100+                 | Низкая  | Низкая  | 2 МБ   |

Почему шейдер: GPU параллельно, 1 quad per button.

## Анимации
```gdscript
# ✅ Tween
var tw := create_tween()
tw.tween_method(_set_glow, 0.0, 1.0, 0.3)

# ✅ Шейдер: uniform float glow = sin(TIME * 2.0);

# ❌ _process: queue_redraw()
```

## Чеклист
- [ ] _process только для динамики.
- [ ] set_process(false) для скрытого.
- [ ] Атлас для иконок.
- [ ] Append в RichTextLabel.
- [ ] Tween / AnimationPlayer для анимаций.
- [ ] Шейдер для эффектов.
- [ ] 3-5 элементов — не оптимизируй prematurely.
