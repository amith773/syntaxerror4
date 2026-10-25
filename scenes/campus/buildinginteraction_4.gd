extends Area2D

@onready var prompt: Label = $PromptLabel

var player_near: bool = false

const DESTINATION_SCENE: String = "res://scenes/levels/sarojini_5a.tscn"


func _ready() -> void:
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):
		print("Entering Sarojini Bhawan!")

		var error := get_tree().change_scene_to_file(DESTINATION_SCENE)

		if error != OK:
			push_error("Failed to load Sarojini Bhawan. Error code: " + str(error))


func _on_body_entered(body: Node2D) -> void:
	if body.name == "campus_player":
		player_near = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "campus_player":
		player_near = false
		prompt.visible = false
