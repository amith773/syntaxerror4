
extends Sprite2D

@export var normal_texture: Texture2D
@export var angry_texture: Texture2D

@onready var blocker = get_parent().get_node_or_null("GuardBlocker")

var player_nearby := false
var guard_fallen := false

func _process(_delta: float) -> void:
	if player_nearby and not guard_fallen and Input.is_key_pressed(KEY_F):
		make_guard_fall()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = true
		if not guard_fallen and angry_texture != null:
			texture = angry_texture

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = false
		if not guard_fallen and normal_texture != null:
			texture = normal_texture

func make_guard_fall() -> void:
	guard_fallen = true

	if normal_texture != null:
		texture = normal_texture

	rotation_degrees = 90

	if blocker != null:
		blocker.set_deferred("disabled", true)

	var stone = get_tree().get_first_node_in_group("stone_pickup")
	if stone != null:
		stone.global_position = global_position + Vector2(0, 35)
		stone.visible = true

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_tree().current_scene.find_child("Player", true, false)

	if player != null:
		var normal_sprite = player.get_node_or_null("ProtagonistArt")
		var stone_sprite = player.get_node_or_null("ProtagonistWithStone")

		if normal_sprite != null:
			normal_sprite.visible = true

		if stone_sprite != null:
			stone_sprite.visible = false

		player.set_meta("has_stone", false)

	print("Guard fallen. Player restored to normal.")
