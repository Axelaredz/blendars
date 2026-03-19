# res://client/ui/ui_kit/tokens/ui_navigation.gd
# AUTOLOAD: "UiNav"
class_name UiNavigationClass
extends Node

## Центральный контроллер клавиатурной/геймпад навигации.
## Управляет фокусом между зонами и внутри зон.
##
## Зона (zone) = группа связанных фокусируемых элементов
## (например, MainNav — одна зона, SettingsPanel — другая)
##
## Только ОДНА зона активна в любой момент.


# ══════════════════════════════════
#  Сигналы
# ══════════════════════════════════

signal focus_changed(
    node: Control,
    zone_id: StringName
)
signal zone_changed(
    new_zone: StringName,
    old_zone: StringName
)
signal navigation_action(action: StringName)
    # &"confirm", &"cancel", &"tab_next", &"tab_prev"


# ══════════════════════════════════
#  Внутреннее состояние
# ══════════════════════════════════

## Зарегистрированные зоны
## { zone_id: { nodes: Array[Control], current_index: int } }
var _zones: Dictionary = {}

## Порядок зон для Tab-навигации
var _zone_order: Array[StringName] = []

## Текущая активная зона
var _active_zone: StringName = &""

## Блокировка навигации (например, во время анимации)
var _locked: bool = false


# ══════════════════════════════════
#  Регистрация зон
# ══════════════════════════════════

## Зарегистрировать зону с массивом focusable-нод
func register_zone(
    zone_id: StringName,
    nodes: Array[Control],
    make_active: bool = false
) -> void:
    _zones[zone_id] = {
        "nodes": nodes,
        "current_index": 0,
    }

    if zone_id not in _zone_order:
        _zone_order.append(zone_id)

    # Подписываемся на удаление нод
    for node in nodes:
        if not node.tree_exiting.is_connected(
            _on_node_removed.bind(zone_id, node)):
            node.tree_exiting.connect(
                _on_node_removed.bind(zone_id, node))

    if make_active or _active_zone == &"":
        activate_zone(zone_id)


## Убрать зону
func unregister_zone(zone_id: StringName) -> void:
    _zones.erase(zone_id)
    _zone_order.erase(zone_id)

    if _active_zone == zone_id:
        if _zone_order.size() > 0:
            activate_zone(_zone_order[0])
        else:
            _active_zone = &""


## Обновить ноды в зоне (при динамической перестройке)
func update_zone_nodes(
    zone_id: StringName,
    nodes: Array[Control]
) -> void:
    if _zones.has(zone_id):
        _zones[zone_id]["nodes"] = nodes
        _zones[zone_id]["current_index"] = clampi(
            _zones[zone_id]["current_index"],
            0, maxi(nodes.size() - 1, 0)
        )


# ══════════════════════════════════
#  Управление зонами
# ══════════════════════════════════

## Активировать зону и сфокусировать текущий элемент
func activate_zone(zone_id: StringName) -> void:
    if not _zones.has(zone_id):
        return

    var old := _active_zone
    _active_zone = zone_id
    zone_changed.emit(zone_id, old)

    _focus_current()


## Получить активную зону
func get_active_zone() -> StringName:
    return _active_zone


## Заблокировать навигацию (во время переходов)
func lock() -> void:
    _locked = true


## Разблокировать
func unlock() -> void:
    _locked = false


# ══════════════════════════════════
#  Фокусировка
# ══════════════════════════════════

## Сфокусировать первый элемент активной зоны
func focus_first() -> void:
    if not _zones.has(_active_zone):
        return
    _zones[_active_zone]["current_index"] = 0
    _focus_current()


## Сфокусировать последний элемент
func focus_last() -> void:
    if not _zones.has(_active_zone):
        return
    var nodes: Array = _zones[_active_zone]["nodes"]
    _zones[_active_zone]["current_index"] = nodes.size() - 1
    _focus_current()


## Сфокусировать конкретный элемент по ноде
func focus_node(node: Control) -> void:
    for zone_id in _zones:
        var nodes: Array = _zones[zone_id]["nodes"]
        var idx := nodes.find(node)
        if idx != -1:
            _active_zone = zone_id
            _zones[zone_id]["current_index"] = idx
            _focus_current()
            return


## Двигаем фокус внутри зоны
func move_focus(direction: int) -> void:
    if _locked:
        return
    if not _zones.has(_active_zone):
        return

    var zone: Dictionary = _zones[_active_zone]
    var nodes: Array = zone["nodes"]
    if nodes.is_empty():
        return

    var total := nodes.size()
    var idx: int = zone["current_index"]

    # Пропускаем disabled/invisible
    var attempts := 0
    while attempts < total:
        idx = wrapi(idx + direction, 0, total)
        var node: Control = nodes[idx]
        if node.visible and not _is_disabled(node):
            break
        attempts += 1

    zone["current_index"] = idx
    _focus_current()


## Переключить зону (Tab / Bumper)
func next_zone() -> void:
    if _locked or _zone_order.is_empty():
        return
    var idx := _zone_order.find(_active_zone)
    idx = wrapi(idx + 1, 0, _zone_order.size())
    activate_zone(_zone_order[idx])


func prev_zone() -> void:
    if _locked or _zone_order.is_empty():
        return
    var idx := _zone_order.find(_active_zone)
    idx = wrapi(idx - 1, 0, _zone_order.size())
    activate_zone(_zone_order[idx])


# ══════════════════════════════════
#  Input
# ══════════════════════════════════

func _unhandled_key_input(event: InputEvent) -> void:
    if _locked:
        return

    if not event.is_pressed():
        return

    if event is InputEventKey:
        match event.keycode:
            KEY_UP:
                move_focus(-1)
                get_viewport().set_input_as_handled()
            KEY_DOWN:
                move_focus(1)
                get_viewport().set_input_as_handled()
            KEY_LEFT:
                # В некоторых зонах ←→ может значить другое
                navigation_action.emit(&"left")
            KEY_RIGHT:
                navigation_action.emit(&"right")
            KEY_ENTER:
                _confirm_current()
                get_viewport().set_input_as_handled()
            KEY_ESCAPE:
                navigation_action.emit(&"cancel")
                get_viewport().set_input_as_handled()
            KEY_TAB:
                if event.shift_pressed:
                    prev_zone()
                else:
                    next_zone()
                get_viewport().set_input_as_handled()


# Геймпад
func _unhandled_input(event: InputEvent) -> void:
    if _locked:
        return

    if event is InputEventJoypadButton and event.pressed:
        match event.button_index:
            JOY_BUTTON_DPAD_UP:
                move_focus(-1)
            JOY_BUTTON_DPAD_DOWN:
                move_focus(1)
            JOY_BUTTON_A:
                _confirm_current()
            JOY_BUTTON_B:
                navigation_action.emit(&"cancel")
            JOY_BUTTON_LEFT_SHOULDER:
                prev_zone()
            JOY_BUTTON_RIGHT_SHOULDER:
                next_zone()
        get_viewport().set_input_as_handled()


# ══════════════════════════════════
#  Внутренние методы
# ══════════════════════════════════

func _focus_current() -> void:
    if not _zones.has(_active_zone):
        return

    var zone: Dictionary = _zones[_active_zone]
    var nodes: Array = zone["nodes"]
    var idx: int = zone["current_index"]

    if idx >= 0 and idx < nodes.size():
        var node: Control = nodes[idx]
        if node and is_instance_valid(node):
            node.grab_focus()
            focus_changed.emit(node, _active_zone)


func _confirm_current() -> void:
    if not _zones.has(_active_zone):
        return

    var zone: Dictionary = _zones[_active_zone]
    var nodes: Array = zone["nodes"]
    var idx: int = zone["current_index"]

    if idx >= 0 and idx < nodes.size():
        var node: Control = nodes[idx]
        # Эмулируем клик
        if node.has_method("_do_press"):
            node._do_press()
        elif node is BaseButton:
            node.emit_signal("pressed")

    navigation_action.emit(&"confirm")


func _is_disabled(node: Control) -> bool:
    if node is BaseButton:
        return node.disabled
    if node.has_method("is_disabled"):
        return node.is_disabled
    if "is_disabled" in node:
        return node.is_disabled
    return false


func _on_node_removed(zone_id: StringName, node: Control) -> void:
    if not _zones.has(zone_id):
        return
    var nodes: Array = _zones[zone_id]["nodes"]
    nodes.erase(node)