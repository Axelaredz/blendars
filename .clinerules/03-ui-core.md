# Godot 4.x — UI Rules

## Anchors Preset
```gdscript
control.set_anchors_preset(Control.PRESET_FULL_RECT, true)  # Keep offsets
```
Presets: FULL_RECT (растянуть), CENTER, TOP_WIDE, HCENTER_WIDE.

## Золотое правило: Не мешать anchors и контейнеры
Дочерние контейнера: Только size_flags / custom_minimum_size. Anchors игнорируются.

## Size Flags
```gdscript
control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
control.size_flags_stretch_ratio = 2.0  # Пропорции
```

## Custom Minimum Size
```gdscript
button.custom_minimum_size = Vector2(120, 40)
```

## Корневая структура UI-сцены
```
CanvasLayer (layer=10)
  └── Control (Full Rect)
       └── SafeArea (MarginContainer)
            ├── VBoxContainer (layout)
            │    ├── TopBar (HBox)
            │    ├── Content (Margin)
            │    └── BottomBar (HBox)
            └── Overlays (Control, Full Rect)
```

## Safe Area
```gdscript
func _apply_safe_area() -> void:
    var safe: Rect2i = DisplayServer.get_display_safe_area()
    var full: Rect2i = DisplayServer.screen_get_usable_rect()
    # Вычислить margins (left/top/right/bottom)
    for side in ["left", "top", "right", "bottom"]:
        add_theme_constant_override("margin_" + side, maxi(margin_value, 8))
get_tree().root.size_changed.connect(_apply_safe_area)
```

## Mouse Filter
```gdscript
# STOP: Ловит, не пропускает (default)
# PASS: Ловит, пропускает
# IGNORE: Прозрачный
background.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Декор
```

## gui_input vs _input vs _unhandled_input
```gdscript
func _gui_input(event: InputEvent) -> void:  # На ноде
    if event is InputEventMouseButton: accept_event()

func _input(event: InputEvent) -> void:  # Глобальные хоткеи
    if event.is_action_pressed(&"ui_cancel"): get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:  # Игровые действия
    if event.is_action_pressed(&"shoot"): shoot()
```
Порядок: _input → gui_input → _shortcut_input → _unhandled_input.

## Focus
```gdscript
button.focus_mode = Control.FOCUS_ALL
button1.focus_neighbor_bottom = button2.get_path()
func open_menu() -> void:
    menu.visible = true
    await get_tree().process_frame
    first_button.grab_focus()
```

## Accessibility-минимум
- Tooltip_text на interactive.
- Buttons ≥44×44 px.
- Контраст ≥4.5:1.
- Не только цвет — иконки/текст.

## Модальные окна
```gdscript
func show_modal(content_scene: PackedScene) -> void:
    var dimmer := ColorRect.new()
    dimmer.color = Color(0,0,0,0.5)
    dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
    dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
    var content := content_scene.instantiate()
    dimmer.add_child(content)
    overlay_layer.add_child(dimmer)
    get_tree().paused = true
    await content.closed
    dimmer.queue_free()
    get_tree().paused = false
```

## Чеклист ловушек
- [ ] set_anchors_preset(), не прямое присваивание.
- [ ] Size_flags в контейнерах, не anchors.
- [ ] duplicate() для StyleBox.
- [ ] grab_focus() при открытии.
- [ ] Mouse_filter=IGNORE на декоре.
- [ ] set_deferred для size/position.
