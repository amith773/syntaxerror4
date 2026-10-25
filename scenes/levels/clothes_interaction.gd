extends Area2D

@onready var clothes = get_parent().get_node_or_null("Clothes")
@onready var detection = get_parent().get_node_or_null("girldetection")

var player_in_range: bool = false
var clothes_unlocked: bool = false
var clothes_taken: bool = false

func _ready() -> void:
	print("ClothesInteraction script started.")

	if clothes == null:
		print("ERROR: Cannot find the Clothes node.")
		return

	if detection == null:
		print("ERROR: Cannot find the girldetection node.")
		return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	detection.girl_sequence_completed.connect(_on_girl_sequence_completed)

func _on_girl_sequence_completed() -> void:
	clothes_unlocked = true
	print("Clothes unlocked! Go near the hanger and press E.")

func _on_body_entered(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		player_in_range = true
		print("Player entered ClothesInteraction area.")

func _on_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		player_in_range = false
		print("Player left ClothesInteraction area.")

func _process(_delta: float) -> void:
	if player_in_range and clothes_unlocked and not clothes_taken:
		if Input.is_key_pressed(KEY_E):
			print("E pressed! Trying to take clothes.")
			if clothes.has_method("take_clothes"):
				clothes.take_clothes()
				clothes_taken = true
			else:
				print("ERROR: Clothes node has no take_clothes() function.")
