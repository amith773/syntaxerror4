extends Node2D

@export var broken_cable_texture: Texture2D
@export var move_speed: float = 220.0

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var player_sprite: Sprite2D = $CharacterBody2D/ProtagonistIdle

@onready var chandelier: Node2D = $ChandelierModern
@onready var cable: Sprite2D = $CableSingle
@onready var cart: Node2D = $FileCart

@onready var accident_trigger: Marker2D = $AccidentTrigger
@onready var chandelier_start: Marker2D = $ChandelierStart
@onready var chandelier_fall: Marker2D = $ChandelierFall
@onready var cart_stop: Marker2D = $CartStopPosition

var original_bg: Sprite2D
var closed_bg: Sprite2D
var intact_cable_texture: Texture2D

var phase: String = "approach"


func _ready() -> void:
	original_bg = find_sprite_by_name(self, "SAC_bg")
	closed_bg = find_sprite_by_name(self, "ClosedDoorsBG")

	if original_bg == null:
		push_error("Cannot find SAC_bg anywhere under this scene's root.")
		return

	if closed_bg == null:
		push_error("Cannot find ClosedDoorsBG anywhere under this scene's root.")
		return

	intact_cable_texture = cable.texture

	original_bg.visible = true
	closed_bg.visible = false

	chandelier.global_position = chandelier_start.global_position

	if broken_cable_texture == null:
		push_warning("Assign the broken cable PNG in the Inspector.")


func find_sprite_by_name(parent: Node, target_name: String) -> Sprite2D:
	if parent.name == target_name and parent is Sprite2D:
		return parent as Sprite2D

	for child in parent.get_children():
		var result: Sprite2D = find_sprite_by_name(child, target_name)
		if result != null:
			return result

	return null


func _physics_process(_delta: float) -> void:
	if original_bg == null or closed_bg == null:
		return

	var previous_x: float = player.global_position.x
	var axis: float = get_movement_axis()

	if phase == "pushing":
		axis = minf(axis, 0.0)

	if phase == "at_cables":
		axis = 0.0

	player.velocity.x = axis * move_speed
	player.move_and_slide()

	if absf(axis) > 0.01:
		player_sprite.flip_h = axis < 0.0

	if phase == "approach" and axis > 0.0:
		if previous_x < accident_trigger.global_position.x \
		and player.global_position.x >= accident_trigger.global_position.x:
			start_accident()

	if phase == "accident" and axis < -0.01:
		start_rewind()

	if phase == "pushing":
		if cart.global_position.x <= cart_stop.global_position.x:
			var cart_offset: float = (
				cart.global_position.x - player.global_position.x
			)

			player.global_position.x = (
				cart_stop.global_position.x - cart_offset
			)

			player.velocity = Vector2.ZERO
			phase = "at_cables"
			print("Cart reached the cables. Press E to release it.")

	if phase == "ready_to_push" \
	and Input.is_action_just_pressed("pick_up"):
		equip_cart()
	elif phase == "at_cables" \
	and Input.is_action_just_pressed("pick_up"):
		release_cart()


func get_movement_axis() -> float:
	var left_pressed: bool = (
		Input.is_key_pressed(KEY_A)
		or Input.is_key_pressed(KEY_LEFT)
	)

	var right_pressed: bool = (
		Input.is_key_pressed(KEY_D)
		or Input.is_key_pressed(KEY_RIGHT)
	)

	if left_pressed == right_pressed:
		return 0.0

	if left_pressed:
		return -1.0

	return 1.0


func start_accident() -> void:
	if phase != "approach":
		return

	phase = "falling"

	var tween: Tween = create_tween()
	tween.tween_property(
		chandelier,
		"global_position",
		chandelier_fall.global_position,
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.finished.connect(_on_chandelier_fell)


func _on_chandelier_fell() -> void:
	if phase != "falling":
		return

	if broken_cable_texture != null:
		cable.texture = broken_cable_texture
	else:
		push_warning("Broken cable texture is not assigned.")

	original_bg.visible = false
	closed_bg.visible = true

	phase = "accident"
	print("Chandelier fell. Walk left to rewind.")


func start_rewind() -> void:
	if phase != "accident":
		return

	phase = "rewinding"

	cable.texture = intact_cable_texture
	original_bg.visible = true
	closed_bg.visible = false

	var tween: Tween = create_tween()
	tween.tween_property(
		chandelier,
		"global_position",
		chandelier_start.global_position,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_rewind_finished)


func _on_rewind_finished() -> void:
	if phase == "rewinding":
		phase = "ready_to_push"
		print("Rewind complete. Stand to the right of the cart and press E.")


func equip_cart() -> void:
	if player.global_position.x <= cart.global_position.x:
		print("Stand to the right of the cart.")
		return

	if absf(player.global_position.x - cart.global_position.x) > 140.0:
		print("Move closer to the cart.")
		return

	cart.reparent(player, true)

	phase = "pushing"
	print("Cart equipped. Walk left to push it.")


func release_cart() -> void:
	if phase != "at_cables":
		return

	cart.reparent(self, true)

	phase = "released"
	print("Cart released. You can walk independently.")
