
extends Sprite2D

@export var float_height: float = 450.0
@export var move_right_distance: float = 900.0
@export var move_speed: float = 500.0

var activated := false
var start_position: Vector2
var target_position: Vector2
var moving_up := true

func _ready() -> void:
	start_position = position
	target_position = start_position

func _process(delta: float) -> void:
	if not activated:
		return

	if moving_up:
		position.y = move_toward(
			position.y,
			start_position.y - float_height,
			move_speed * delta
		)

		if position.y <= start_position.y - float_height:
			moving_up = false
			target_position = Vector2(
				start_position.x + move_right_distance,
				start_position.y - float_height
			)

	else:
		position.x = move_toward(
			position.x,
			target_position.x,
			move_speed * delta
		)

func activate() -> void:
	if activated:
		return

	activated = true
