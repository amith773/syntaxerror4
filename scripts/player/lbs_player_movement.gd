
extends CharacterBody2D

@export var speed: float = 220.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(direction * speed, 0.0)
	move_and_slide()
