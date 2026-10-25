extends Area2D

@onready var prompt: Label = $PromptLabel
@onready var ending_video: VideoStreamPlayer = get_parent().get_node("EndingVideo")

var player_near: bool = false
var video_playing: bool = false


func _ready() -> void:
	prompt.hide()
	ending_video.hide()

	# Detect when the player approaches or leaves.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Close the game when the video finishes.
	ending_video.finished.connect(_on_video_finished)


func _process(_delta: float) -> void:
	if player_near and not video_playing:
		if Input.is_action_just_pressed("interact"):
			_play_ending_video()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "campus_player" and not video_playing:
		player_near = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "campus_player":
		player_near = false
		prompt.hide()


func _play_ending_video() -> void:
	if ending_video.stream == null:
		push_error("EndingVideo has no video assigned.")
		return

	video_playing = true
	prompt.hide()

	# Make the video fill the game window.
	var viewport_size := get_viewport_rect().size
	ending_video.position = Vector2.ZERO
	ending_video.size = viewport_size
	ending_video.z_index = 100
	ending_video.show()
	ending_video.play()

	# Stop the player moving during the video.
	var campus_player := get_tree().current_scene.find_child(
		"campus_player", true, false
	)

	if campus_player:
		campus_player.set_physics_process(false)


func _on_video_finished() -> void:
	get_tree().quit()
