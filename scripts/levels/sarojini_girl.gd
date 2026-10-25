extends Sprite2D

@export var normal_texture: Texture2D
@export var alert_texture: Texture2D

var player_in_range: bool = false
var disguise_completed: bool = false


func _ready() -> void:
	if normal_texture != null:
		texture = normal_texture


func player_entered_detection() -> void:
	player_in_range = true

	if disguise_completed:
		return

	if alert_texture != null:
		texture = alert_texture
		print("Girl changes to alert expression!")


func player_left_detection() -> void:
	player_in_range = false

	if not disguise_completed and normal_texture != null:
		texture = normal_texture


func allow_disguised_player() -> void:
	disguise_completed = true

	if normal_texture != null:
		texture = normal_texture

	print("Girl lets the disguised boy pass!")
