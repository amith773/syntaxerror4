extends Sprite2D

@export var empty_hanger_texture: Texture2D

var clothes_taken: bool = false

func take_clothes() -> void:
	if clothes_taken:
		return

	clothes_taken = true

	if empty_hanger_texture != null:
		texture = empty_hanger_texture

	print("The clothes have been taken!")
