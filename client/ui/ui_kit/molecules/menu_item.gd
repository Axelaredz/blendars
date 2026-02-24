# res://client/ui/ui_kit/molecules/menu_item.gd

## Молекула: пункт меню.
## Состоит из AccentBar + опциональной иконки + текста.
## Испускает сигнал при клике. Поддерживает keyboard navigation.

class_name MoleculeMenuItem
extends PanelContainer

signal item_pressed(item_id: StringName)
signal item_hovered(item_id: StringName)

@export var item_id: StringName = &""
@export var label_text: String = "МЕНЮ":
    set(value):
        label_text = value
        if _label: _label.text = value

@export var is_active: bool = false:
    set(value):
        is_active = value
        _update_visual()

@export var is_disabled: bool = false

@onready var _accent: AtomAccentBar = %AccentBar
@onready var _label: Label = %Label
var _is_hovered := false


func _ready() -> void:
    # ★ Стили берутся из Theme АВТОМАТИЧЕСКИ
    #   (Theme назначена на корень экрана)
    #   Никаких override. Никаких load().

    _label.text = label_text
    custom_minimum_size.y = 44
    focus_mode = Control.FOCUS_ALL
    mouse_default_cursor_shape = CURSOR_POINTING_HAND

    # Сигналы
    mouse_entered.connect(func():
        if is_disabled: return
        _is_hovered = true
        _update_visual()
        item_hovered.emit(item_id)
    )
    mouse_exited.connect(func():
        _is_hovered = false
        _update_visual()
    )
    focus_entered.connect(func():
        _is_hovered = true
        _update_visual()
        item_hovered.emit(item_id)
    )
    focus_exited.connect(func():
        _is_hovered = false
        _update_visual()
    )
    gui_input.connect(_on_input)


func _update_visual() -> void:
    if not is_inside_tree(): return

    if is_active:
        _label.theme_type_variation = &"LabelAccent"  # ★ Одна строка!
        _accent.show_bar()
    elif _is_hovered:
        _label.theme_type_variation = &"Label"        # primary
        _accent.show_bar()
    else:
        _label.theme_type_variation = &"LabelSecondary"
        _accent.hide_bar()


func _on_input(event: InputEvent) -> void:
    if is_disabled: return
    if event is InputEventMouseButton \
        and event.button_index == MOUSE_BUTTON_LEFT \
        and event.pressed:
        _do_press()


func _do_press() -> void:
    UiAnim.flicker(_label, 2, 0.15)  # ★ Одна строка!
    item_pressed.emit(item_id)


# Нет _unhandled_key_input — это делает UiNav ★