extends Node2D

@onready var player: CharacterBody2D = $BuildingPlayer
@onready var clock: Node2D = $BrokenClock
@onready var error_message: Label = $ErrorMessage
@onready var exit_trigger: Area2D = $ExitTrigger

var clock_fixed: bool = false
var exit_busy: bool = false
var near_bench: bool = false
var message_version: int = 0
var bench_message_shown: bool = false

const CLOCK_INTERACT_DISTANCE: float = 180.0
const PLAYER_START_POSITION: Vector2 = Vector2(100, 530)


func _ready() -> void:
	error_message.hide()
	clock.show()

	if not exit_trigger.body_entered.is_connected(
		_on_exit_trigger_body_entered
	):
		exit_trigger.body_entered.connect(
			_on_exit_trigger_body_entered
		)

	var bench = get_node_or_null("BenchInteract")

	if bench is Area2D:
		if not bench.body_entered.is_connected(_on_bench_body_entered):
			bench.body_entered.connect(_on_bench_body_entered)

		if not bench.body_exited.is_connected(_on_bench_body_exited):
			bench.body_exited.connect(_on_bench_body_exited)


func _process(_delta: float) -> void:
	if not clock_fixed:
		var distance: float = player.global_position.distance_to(
			clock.global_position
		)

		if distance <= CLOCK_INTERACT_DISTANCE and Input.is_key_pressed(KEY_E):
			repair_clock()
			return

	if near_bench:
		if Input.is_key_pressed(KEY_E) and not bench_message_shown:
			bench_message_shown = true
			print("It's just a bench. Nothing useful here.")
		elif not Input.is_key_pressed(KEY_E):
			bench_message_shown = false


func repair_clock() -> void:
	if clock_fixed:
		return

	clock_fixed = true
	clock.hide()

	var barrier = get_node_or_null("ExitTrigger/LoopingBarrier")
	if barrier is CollisionShape2D:
		barrier.set_deferred("disabled", true)

	# Also remove the physical barrier if you created one.
	var physical_barrier = get_node_or_null("PhysicalBarrier")
	if physical_barrier is CollisionObject2D:
		physical_barrier.queue_free()

	print("CLOCK REPAIRED!")
	print("INFINITE LOOP DISABLED!")
	print("EXIT UNLOCKED!")

	show_game_message(
		"CLOCK REPAIRED!\nINFINITE LOOP DISABLED!\nEXIT UNLOCKED!",
		3.0
	)


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body != player:
		return

	if clock_fixed:
		print("LEVEL COMPLETE!")
		show_game_message("LEVEL COMPLETE!", 3.0)
		return

	if exit_busy:
		return

	exit_busy = true

	print("SYNTAX ERROR — INFINITE LOOP DETECTED!")
	show_game_message(
		"SYNTAX ERROR — INFINITE LOOP DETECTED!",
		1.5
	)

	await get_tree().create_timer(0.5).timeout

	if is_instance_valid(player):
		player.global_position = PLAYER_START_POSITION
		player.velocity = Vector2.ZERO

	await get_tree().create_timer(1.0).timeout
	exit_busy = false


func show_game_message(message: String, duration: float) -> void:
	message_version += 1
	var current_message: int = message_version

	error_message.text = message
	error_message.show()

	await get_tree().create_timer(duration).timeout

	if current_message == message_version:
		error_message.hide()


func _on_bench_body_entered(body: Node2D) -> void:
	if body == player:
		near_bench = true
		bench_message_shown = false


func _on_bench_body_exited(body: Node2D) -> void:
	if body == player:
		near_bench = false
		bench_message_shown = false
