extends Area2D

signal girl_sequence_completed

@onready var girl = get_node("../girl")

var boy_was_detected: bool = false
var sequence_completed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Girl sees the boy!")
		boy_was_detected = true
		girl.player_entered_detection()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Girl no longer sees the boy!")
		girl.player_left_detection()

		if boy_was_detected and not sequence_completed:
			sequence_completed = true
			girl_sequence_completed.emit()
			print("Clothes are now unlocked!")
