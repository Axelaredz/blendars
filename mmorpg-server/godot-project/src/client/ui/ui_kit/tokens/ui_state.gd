# res://client/ui/ui_kit/tokens/ui_state.gd
# AUTOLOAD: "UiState"
class_name UiStateClass
extends Node

## Централизованное состояние UI.
## Хранит ТОЛЬКО данные.
## Не содержит логику отображения.
## Компоненты ПОДПИСЫВАЮТСЯ на сигналы и РЕАГИРУЮТ сами.


# ══════════════════════════════════
#  Сигналы
# ══════════════════════════════════

## Экран изменился
signal screen_changed(
    new_screen: StringName,
    old_screen: StringName
)

## Активный пункт навигации изменился
signal active_nav_changed(item_id: StringName)

## Hover-фокус навигации (для превью)
signal nav_hovered(item_id: StringName)

## Модальное окно
signal modal_opened(modal_id: StringName)
signal modal_closed(modal_id: StringName)

## Состояние загрузки
signal loading_changed(is_loading: bool, message: String)

## Уведомление
signal notification_requested(
    text: String,
    type: StringName,  # "info" | "warning" | "error"
    duration: float
)


# ══════════════════════════════════
#  Состояние
# ══════════════════════════════════

var current_screen: StringName = &"":
    set(value):
        var old := current_screen
        current_screen = value
        screen_changed.emit(value, old)

var previous_screen: StringName = &""

var active_nav_item: StringName = &"":
    set(value):
        active_nav_item = value
        active_nav_changed.emit(value)

var hovered_nav_item: StringName = &"":
    set(value):
        hovered_nav_item = value
        nav_hovered.emit(value)

var is_modal_open: bool = false
var current_modal: StringName = &""

var is_loading: bool = false:
    set(value):
        is_loading = value
        loading_changed.emit(value, loading_message)

var loading_message: String = ""

## Стек экранов для навигации "назад"
var _screen_stack: Array[StringName] = []


# ══════════════════════════════════
#  Методы навигации
# ══════════════════════════════════

## Перейти на экран (с запоминанием)
func navigate_to(screen_id: StringName) -> void:
    if current_screen != &"":
        _screen_stack.push_back(current_screen)
    previous_screen = current_screen
    current_screen = screen_id


## Вернуться на предыдущий экран
func navigate_back() -> bool:
    if _screen_stack.is_empty():
        return false
    previous_screen = current_screen
    current_screen = _screen_stack.pop_back()
    return true


## Можно ли вернуться назад
func can_go_back() -> bool:
    return not _screen_stack.is_empty()


## Очистить стек (при переходе в главное меню)
func clear_history() -> void:
    _screen_stack.clear()
    previous_screen = &""


# ══════════════════════════════════
#  Методы модальных окон
# ══════════════════════════════════

func open_modal(modal_id: StringName) -> void:
    current_modal = modal_id
    is_modal_open = true
    modal_opened.emit(modal_id)


func close_modal() -> void:
    var closing := current_modal
    current_modal = &""
    is_modal_open = false
    modal_closed.emit(closing)


# ══════════════════════════════════
#  Методы уведомлений
# ══════════════════════════════════

func notify(
    text: String,
    type: StringName = &"info",
    duration: float = 3.0
) -> void:
    notification_requested.emit(text, type, duration)


func notify_error(text: String) -> void:
    notify(text, &"error", 5.0)