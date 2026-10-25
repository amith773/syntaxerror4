
extends Sprite2D

var nearby_player: CharacterBody2D = null
var collected := false

func _process(_delta: float) -> void:
	if not collected and Input.is_key_pressed(KEY_E):
		if is_instance_valid(nearby_player):
			pick_up()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		nearby_player = body
		print("Player near stone. Press E.")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null

func pick_up() -> void:
	if collected or not is_instance_valid(nearby_player):
		return

	var normal_sprite = nearby_player.get_node_or_null("ProtagonistArt")
	var stone_sprite = nearby_player.get_node_or_null("ProtagonistWithStone")

	if normal_sprite == null or stone_sprite == null:
		print("ERROR: Check player sprite node names.")
		return

	normal_sprite.visible = false
	stone_sprite.visible = true
	nearby_player.set_meta("has_stone", true)

	collected = true
	visible = false
	print("Stone collected!")
