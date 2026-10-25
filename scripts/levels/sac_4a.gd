extends Node2D

@export var move_speed: float = 220.0
@export var return_delay: float = 1.5

const CAMPUS_SCENE: String = "res://scenes/campus/campus_map.tscn"

# Player
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var player_sprite: Sprite2D = $CharacterBody2D/ProtagonistIdle

# Objects
@onready var chandelier: Node2D = $ChandelierModern
@onready var cable: Sprite2D = $CableSingle
@onready var broken_cable: Sprite2D = $BrokenCable
@onready var cart: Node2D = $FileCart

# Markers
@onready var accident_trigger: Marker2D = $AccidentTrigger
@onready var chandelier_start: Marker2D = $ChandelierStart
@onready var chandelier_fall: Marker2D = $ChandelierFall
@onready var cart_stop: Marker2D = $CartStopPosition
@onready var chandelier_cart_stop: Marker2D = $ChandelierCartStop

# Backgrounds
var original_bg: Sprite2D
var closed_bg: Sprite2D

var phase: String = "approach_first"
var cart_protects_cable: bool = false


func _ready() -> void:
	var scene_root := get_tree().current_scene

	original_bg = scene_root.find_child("SAC_bg", true, false) as Sprite2D
	closed_bg = scene_root.find_child("ClosedDoorsBG", true, false) as Sprite2D

	if original_bg == null:
		push_error("Cannot find SAC_bg. Check its name in the Scene tree.")
		set_physics_process(false)
		return

	if closed_bg == null:
		push_error("Cannot find ClosedDoorsBG. Check its name in the Scene tree.")
		set_physics_process(false)
		return

	cable.visible = true
	broken_cable.visible = false
	original_bg.visible = true
	closed_bg.visible = false

	chandelier.global_position = chandelier_start.global_position

	print("GAME STARTED")


func _physics_process(_delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")

	if Input.is_key_pressed(KEY_A):
		axis = -1.0
	elif Input.is_key_pressed(KEY_D):
		axis = 1.0

	if phase in [
		"falling_first",
		"rewinding",
		"moving_cart",
		"falling_second",
		"protected",
		"returning_to_campus"
	]:
		axis = 0.0

	player.velocity.x = axis * move_speed
	player.velocity.y = 0.0
	player.move_and_slide()

	if absf(axis) > 0.01:
		player_sprite.flip_h = axis < 0.0

	# First fall
	if phase == "approach_first" and axis > 0.0:
		if player.global_position.x >= accident_trigger.global_position.x:
			start_first_fall()

	# Rewind
	if phase == "accident_first" and axis < -0.01:
		start_rewind()

	# Move cart with E
	if Input.is_key_pressed(KEY_E) and phase == "ready_for_cart":
		move_cart_under_chandelier()

	# Second fall
	if phase == "approach_second" and axis > 0.0:
		if player.global_position.x >= accident_trigger.global_position.x:
			start_second_fall()


func start_first_fall() -> void:
	phase = "falling_first"
	print("First fall started")

	var tween := create_tween()
	tween.tween_property(
		chandelier,
		"global_position",
		chandelier_fall.global_position,
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.finished.connect(finish_first_fall)


func finish_first_fall() -> void:
	cable.visible = false
	broken_cable.visible = true
	original_bg.visible = false
	closed_bg.visible = true

	phase = "accident_first"
	print("Walk left to rewind")


func start_rewind() -> void:
	phase = "rewinding"

	cable.visible = true
	broken_cable.visible = false
	original_bg.visible = true
	closed_bg.visible = false

	var tween := create_tween()
	tween.tween_property(
		chandelier,
		"global_position",
		chandelier_start.global_position,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(func():
		phase = "ready_for_cart"
		print("CART READY. Press E.")
	)


func move_cart_under_chandelier() -> void:
	if phase != "ready_for_cart":
		return

	phase = "moving_cart"
	print("CART MOVING")

	var tween := create_tween()
	tween.tween_property(
		cart,
		"global_position",
		cart_stop.global_position,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(func():
		cart_protects_cable = true
		phase = "approach_second"
		print("CART MOVED. Walk right.")
	)


func start_second_fall() -> void:
	phase = "falling_second"

	var target_position: Vector2

	if cart_protects_cable:
		target_position = chandelier_cart_stop.global_position
	else:
		target_position = chandelier_fall.global_position

	var tween := create_tween()
	tween.tween_property(
		chandelier,
		"global_position",
		target_position,
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.finished.connect(finish_second_fall)


func finish_second_fall() -> void:
	if cart_protects_cable:
		cable.visible = true
		broken_cable.visible = false
		original_bg.visible = true
		closed_bg.visible = false

		print("SUCCESS! Cart protected the cable.")
	else:
		cable.visible = false
		broken_cable.visible = true
		original_bg.visible = false
		closed_bg.visible = true

		print("The cable broke.")

	return_to_campus()


func return_to_campus() -> void:
	if phase == "returning_to_campus":
		return

	phase = "returning_to_campus"

	await get_tree().create_timer(return_delay).timeout

	# Remember the SAC entrance before changing scenes.
	get_tree().set_meta("return_marker", "SACReturnPoint")

	var error := get_tree().change_scene_to_file(CAMPUS_SCENE)

	if error != OK:
		push_error("Could not return to campus map. Error code: " + str(error))
