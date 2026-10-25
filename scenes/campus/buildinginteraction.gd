extends Area2D

@onready var prompt: Label = $PromptLabel

var player_near: bool = false


func _ready() -> void:
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		print("E key detected!")

		if player_near:
			print("Entering Main Gate!")

			var scene_path := "res://scenes/levels/main_gate_1a.tscn"
			var error := get_tree().change_scene_to_file(scene_path)

			if error != OK:
				print("Scene change failed. Error code: ", error)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_near = false
		prompt.visible = false
