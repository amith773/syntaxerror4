extends Area2D

@onready var clothes: Sprite2D = get_parent().get_node("Clothes")
@onready var detection: Area2D = get_parent().get_node("girldetection")
@onready var player: CharacterBody2D = get_parent().get_node("player")
@onready var girl: Sprite2D = get_parent().get_node("girl")
@onready var girl_barrier: StaticBody2D = get_parent().get_node("GirlBarrier")

var player_in_range: bool = false
var clothes_unlocked: bool = false
var clothes_taken: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	detection.girl_sequence_completed.connect(_on_girl_sequence_completed)

	print("ClothesInteraction is ready!")


func _on_girl_sequence_completed() -> void:
	clothes_unlocked = true
	print("Clothes unlocked! Go to the hanger and press E.")


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true

		if clothes_unlocked and not clothes_taken:
			print("Press E to take the clothes.")


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false


func _process(_delta: float) -> void:
	if player_in_range and clothes_unlocked and not clothes_taken:
		if Input.is_key_pressed(KEY_E):
			clothes.take_clothes()
			player.wear_disguise()
			girl.allow_disguised_player()

			# Remove the barrier so the disguised boy can pass.
			girl_barrier.queue_free()

			clothes_taken = true
			clothes_unlocked = false

			print("Disguise complete! The way is clear.")
