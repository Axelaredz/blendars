extends Button

## Кнопка со скошенным правым нижним углом в киберпанк стиле (Dracula)

@export var skew_amount: float = 15.0  # Величина скоса
@export var border_color: Color = Color(1, 0.475, 0.776, 0.9)  # Dracula Pink
@export var hover_color: Color = Color(0.545, 0.914, 0.992, 1)  # Dracula Cyan

var hovering: bool = false
var pressed_animation: bool = false

func _ready() -> void:
	# Отключаем стандартный фон
	flat = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	hovering = true
	queue_redraw()

func _on_mouse_exited() -> void:
	hovering = false
	queue_redraw()

func _on_button_down() -> void:
	pressed_animation = true
	queue_redraw()

func _on_button_up() -> void:
	pressed_animation = false
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	var width := rect.size.x
	var height := rect.size.y
	
	# Создаём полигон со скошенным правым нижним углом
	var points := PackedVector2Array([
		Vector2(0, 0),                          # Верхний левый
		Vector2(width - skew_amount, 0),        # Верхний правый (без скоса)
		Vector2(width, height),                 # Нижний правый (скошенный)
		Vector2(0, height - skew_amount * 0.5), # Нижний левый
	])
	
	# Цвета Dracula
	var fill_color := Color(0.267, 0.278, 0.353, 0.9)  # Current Line
	var current_border_color := border_color
	
	if hovering:
		fill_color = Color(0.314, 0.98, 0.482, 0.4)  # Green с прозрачностью
		current_border_color = hover_color  # Cyan
	
	if pressed_animation:
		fill_color = Color(0.745, 0.576, 0.976, 0.6)  # Purple
		current_border_color = Color(0.314, 0.98, 0.482, 1)  # Green
	
	# Рисуем заливку
	draw_colored_polygon(points, fill_color)
	
	# Рисуем границу (линию)
	draw_polyline(points, current_border_color, 2.5)
	
	# Рисуем внутреннюю линию (эффект свечения)
	draw_polyline(points, current_border_color * Color(1, 1, 1, 0.4), 1.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()
