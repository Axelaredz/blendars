# ТОЛЬКО если у тебя ДЕЙСТВИТЕЛЬНО динамический контент
# из внешних данных (моды, user-generated content)

# res://client/ui/ui_kit/tokens/ui_factory.gd — ОПЦИОНАЛЬНЫЙ

class_name UiFactory
extends RefCounted

## Реестр компонентов. Используй ТОЛЬКО для динамической
## генерации UI из data-driven конфигов.

const REGISTRY := {
    &"menu_item": preload(       # preload, НЕ load!
        "res://ui_kit/molecules/menu_item.tscn"),
    &"hotkey_hint": preload(
        "res://ui_kit/molecules/hotkey_hint.tscn"),
    &"stat_line": preload(
        "res://ui_kit/molecules/stat_line.tscn"),
    &"divider": preload(
        "res://ui_kit/atoms/divider.tscn"),
}


static func create(
    type_id: StringName,
    props: Dictionary = {}
) -> Control:
    if not REGISTRY.has(type_id):
        push_error("UiFactory: unknown type '%s'" % type_id)
        return null

    var instance := REGISTRY[type_id].instantiate() as Control

    # Применяем свойства
    for key in props:
        if key in instance:
            instance.set(key, props[key])

    return instance


# Использование (ТОЛЬКО для data-driven UI):
# var items_config := load_from_json("menu.json")
# for cfg in items_config:
#     var node := UiFactory.create(cfg.type, cfg.props)
#     container.add_child(node)