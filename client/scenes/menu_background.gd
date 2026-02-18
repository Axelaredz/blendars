extends Node3D

@export var rotation_speed: float = 0.25

@onready var platform: Node3D = $Platform

func _process(delta: float) -> void:
	if platform:
		platform.rotate_y(rotation_speed * delta)
