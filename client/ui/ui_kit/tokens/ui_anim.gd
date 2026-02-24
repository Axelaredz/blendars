# res://client/ui/ui_kit/tokens/ui_anim.gd
# AUTOLOAD: "UiAnim"
class_name UiAnimClass
extends Node

## Библиотека анимационных пресетов.
## Каждый пресет соблюдает правило 70/20/10:
## - 70% вызовов = subtle (20% визуального веса)
## - 20% вызовов = normal transitions
## - 10% вызовов = dramatic effects (10% визуального)


# ══════════════════════════════════
#  🔹 FADE (появление/исчезновение)
# ══════════════════════════════════

## Плавное появление (20% — мягкая анимация)
func fade_in(
    node: CanvasItem,
    duration: float = UiTokens.ANIM_DURATION_NORMAL,
    delay: float = 0.0
) -> Tween:
    node.modulate.a = 0.0
    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_OUT)
    tw.set_trans(Tween.TRANS_CUBIC)
    if delay > 0.0:
        tw.tween_interval(delay)
    tw.tween_property(node, "modulate:a", 1.0, duration)
    return tw


## Плавное исчезновение
func fade_out(
    node: CanvasItem,
    duration: float = UiTokens.ANIM_DURATION_NORMAL,
    delay: float = 0.0
) -> Tween:
    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_IN)
    tw.set_trans(Tween.TRANS_CUBIC)
    if delay > 0.0:
        tw.tween_interval(delay)
    tw.tween_property(node, "modulate:a", 0.0, duration)
    return tw


# ══════════════════════════════════
#  🔹 SLIDE (въезд/выезд)
# ══════════════════════════════════

enum SlideDirection { LEFT, RIGHT, TOP, BOTTOM }

## Въезд из-за края (20% — structural animation)
func slide_in(
    node: Control,
    direction: SlideDirection = SlideDirection.LEFT,
    duration: float = UiTokens.ANIM_DURATION_SLOW,
    delay: float = 0.0
) -> Tween:
    var start_offset := _get_slide_offset(node, direction)
    var original_pos := node.position

    node.position = original_pos + start_offset
    node.modulate.a = 0.0

    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_OUT)
    tw.set_trans(Tween.TRANS_CUBIC)
    tw.set_parallel(true)

    if delay > 0.0:
        tw.chain().tween_interval(delay)

    tw.tween_property(node, "position",
        original_pos, duration)
    tw.tween_property(node, "modulate:a",
        1.0, duration * 0.6)
    return tw


## Выезд за край
func slide_out(
    node: Control,
    direction: SlideDirection = SlideDirection.LEFT,
    duration: float = UiTokens.ANIM_DURATION_SLOW
) -> Tween:
    var end_offset := _get_slide_offset(node, direction)

    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_IN)
    tw.set_trans(Tween.TRANS_CUBIC)
    tw.set_parallel(true)

    tw.tween_property(node, "position",
        node.position + end_offset, duration)
    tw.tween_property(node, "modulate:a",
        0.0, duration * 0.6)
    return tw


func _get_slide_offset(
    node: Control,
    dir: SlideDirection
) -> Vector2:
    match dir:
        SlideDirection.LEFT:
            return Vector2(-node.size.x - 50, 0)
        SlideDirection.RIGHT:
            return Vector2(node.size.x + 50, 0)
        SlideDirection.TOP:
            return Vector2(0, -node.size.y - 50)
        SlideDirection.BOTTOM:
            return Vector2(0, node.size.y + 50)
    return Vector2.ZERO


# ══════════════════════════════════
#  🔹 STAGGER (каскадное появление)
# ══════════════════════════════════

## Последовательное появление детей (20% — elegant)
## Пример: пункты меню появляются один за другим
func stagger_fade_in(
    children: Array[Control],
    per_item_delay: float = 0.05,
    item_duration: float = UiTokens.ANIM_DURATION_NORMAL
) -> Tween:
    var tw: Tween = null
    for i in children.size():
        for child in [children[i]]:
            child.modulate.a = 0.0
        tw = fade_in(children[i], item_duration,
            i * per_item_delay)
    return tw  # Возвращает последний tween


## Каскадный slide для списков
func stagger_slide_in(
    children: Array[Control],
    direction: SlideDirection = SlideDirection.LEFT,
    per_item_delay: float = 0.06,
    item_duration: float = UiTokens.ANIM_DURATION_SLOW
) -> Tween:
    var tw: Tween = null
    for i in children.size():
        tw = slide_in(children[i], direction,
            item_duration, i * per_item_delay)
    return tw


# ══════════════════════════════════
#  🔸 SCREEN TRANSITIONS (10% — dramatic)
# ══════════════════════════════════

## Кинематографическое появление экрана
func screen_enter(node: Control) -> Tween:
    node.modulate.a = 0.0
    node.modulate = Color(0.7, 0.8, 1.0, 0.0)  # холодный оттенок

    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_OUT)
    tw.set_trans(Tween.TRANS_CUBIC)
    tw.tween_property(node, "modulate",
        Color.WHITE, UiTokens.ANIM_DURATION_CINEMATIC)
    return tw


## Кинематографический уход экрана
func screen_exit(node: Control) -> Tween:
    var tw := node.create_tween()
    tw.set_ease(Tween.EASE_IN)
    tw.set_trans(Tween.TRANS_CUBIC)
    tw.tween_property(node, "modulate",
        Color(0.7, 0.8, 1.0, 0.0),
        UiTokens.ANIM_DURATION_CINEMATIC)
    return tw


## Экранный переход с callback
func screen_transition(
    current: Control,
    on_middle: Callable
) -> void:
    var tw := screen_exit(current)
    tw.tween_callback(on_middle)


# ══════════════════════════════════
#  🔸 GLITCH (10% — редкий акцент)
# ══════════════════════════════════

## Глитч-эффект на ноде (10% — ТОЛЬКО для ключевых моментов)
func glitch(
    node: CanvasItem,
    intensity: float = 5.0,
    duration: float = 0.3
) -> Tween:
    var original_pos := node.position if node is Control \
        else Vector2.ZERO
    var tw := node.create_tween()

    var steps := int(duration / 0.03)
    for i in steps:
        var offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity * 0.5, intensity * 0.5)
        )
        var glitch_color := Color(
            randf_range(0.8, 1.2),
            randf_range(0.9, 1.1),
            randf_range(0.8, 1.2)
        )
        tw.tween_property(node, "position",
            original_pos + offset, 0.02)
        tw.parallel().tween_property(node, "modulate",
            glitch_color, 0.02)

    # Возврат в норму
    tw.tween_property(node, "position",
        original_pos, 0.05)
    tw.parallel().tween_property(node, "modulate",
        Color.WHITE, 0.05)
    return tw


## Мерцание (20% — subtle accent)
func flicker(
    node: CanvasItem,
    times: int = 3,
    duration: float = 0.4
) -> Tween:
    var tw := node.create_tween()
    var step := duration / (times * 2)

    for i in times:
        tw.tween_property(node, "modulate:a",
            randf_range(0.3, 0.7), step)
        tw.tween_property(node, "modulate:a",
            1.0, step)

    tw.tween_property(node, "modulate:a", 1.0, 0.05)
    return tw


# ══════════════════════════════════
#  🔹 PULSE (20% — subtle loop)
# ══════════════════════════════════

## Мягкая пульсация (для индикаторов, активных элементов)
## Возвращает Tween — СОХРАНИ ссылку чтобы остановить!
func pulse_glow(
    node: CanvasItem,
    min_alpha: float = 0.6,
    max_alpha: float = 1.0,
    speed: float = 1.5
) -> Tween:
    var tw := node.create_tween()
    tw.set_loops()  # бесконечный цикл
    tw.set_ease(Tween.EASE_IN_OUT)
    tw.set_trans(Tween.TRANS_SINE)
    tw.tween_property(node, "modulate:a",
        min_alpha, speed * 0.5)
    tw.tween_property(node, "modulate:a",
        max_alpha, speed * 0.5)
    return tw  # Остановить: tween.kill()


## Пульсация масштаба (для кнопки "нажми")
func pulse_scale(
    node: Control,
    min_scale: float = 0.97,
    max_scale: float = 1.03,
    speed: float = 2.0
) -> Tween:
    node.pivot_offset = node.size / 2
    var tw := node.create_tween()
    tw.set_loops()
    tw.set_ease(Tween.EASE_IN_OUT)
    tw.set_trans(Tween.TRANS_SINE)
    tw.tween_property(node, "scale",
        Vector2.ONE * min_scale, speed * 0.5)
    tw.tween_property(node, "scale",
        Vector2.ONE * max_scale, speed * 0.5)
    return tw