# res://client/ui/ui_kit/templates/layout_main_menu.gd
class_name TemplateMainMenu
extends Control

## Шаблон: макет главного меню.
## Определяет ТОЛЬКО расположение зон.
## НЕ содержит конкретных организмов — это делает Screen.
##
## ┌────────────────────────────────────┐
## │            TITLE_SLOT              │  8vh
## ├──────────┬─────────────────────────┤
## │          │                         │
## │ NAV_SLOT │     VIEWPORT_SLOT       │  flex
## │  280px   │                         │
## │          │                         │
## ├──────────┴─────────────────────────┤
## │           BOTTOM_SLOT              │  6vh
## └────────────────────────────────────┘

@onready var title_slot: MarginContainer = %TitleSlot
@onready var nav_slot: MarginContainer = %NavSlot
@onready var viewport_slot: MarginContainer = %ViewportSlot
@onready var bottom_slot: MarginContainer = %BottomSlot
@onready var _background: ColorRect = %Background


func _ready() -> void:
	# Full screen
	anchors_preset = Control.PRESET_FULL_RECT
	
	# Фон — 70% доминирующий цвет
	_background.color = UiTokens.COLOR_BG_PRIMARY
	_background.anchors_preset = Control.PRESET_FULL_RECT
	
	# Расположение зон через код
	_layout_zones()


func _layout_zones() -> void:
	# TITLE SLOT — верх, 8% высоты
	title_slot.anchor_left = 0.0
	title_slot.anchor_right = 1.0
	title_slot.anchor_top = 0.0
	title_slot.anchor_bottom = 0.08
	title_slot.offset_left = 0
	title_slot.offset_right = 0
	title_slot.offset_top = 0
	title_slot.offset_bottom = 0
	
	# NAV SLOT — лево, 280px, между title и bottom
	nav_slot.anchor_left = 0.0
	nav_slot.anchor_right = 0.0
	nav_slot.anchor_top = 0.08
	nav_slot.anchor_bottom = 0.94
	nav_slot.offset_right = 280
	
	# VIEWPORT SLOT — центр, от 280px до правого края
	viewport_slot.anchor_left = 0.0
	viewport_slot.anchor_right = 1.0
	viewport_slot.anchor_top = 0.08
	viewport_slot.anchor_bottom = 0.94
	viewport_slot.offset_left = 280
	
	# BOTTOM SLOT — низ, 6%
	bottom_slot.anchor_left = 0.0
	bottom_slot.anchor_right = 1.0
	bottom_slot.anchor_top = 0.94
	bottom_slot.anchor_bottom = 1.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_zones()