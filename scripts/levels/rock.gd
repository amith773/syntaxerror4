
extends Sprite2D

@export var throwing_texture: Texture2D

var nearby_player: CharacterBody2D = null
var e_was_pressed := false

func _process(_delta: float) -> void:
	var e_pressed := Input.is_key_pressed(KEY_E)

	if e_pressed and not e_was_pressed:
		if is_instance_valid(nearby_player):
			collect_stone()

	e_was_pressed = e_pressed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		nearby_player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null

func collect_stone() -> void:
	if not nearby_player.get_meta("has_approached_guard", false):
		print("Approach the guard first!")
		return

	nearby_player.set_meta("has_stone", true)

	var player_art = nearby_player.get_node_or_null("ProtagonistArt")
	if player_art is Sprite2D and throwing_texture != null:
		player_art.texture = throwing_texture

	print("Stone picked up! Press F to throw.")
	queue_free()
