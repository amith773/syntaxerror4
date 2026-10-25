extends CharacterBody2D

@export var speed: float = 250.0
@export var normal_texture: Texture2D
@export var disguise_texture: Texture2D

@onready var player_sprite: Sprite2D = $Sprite2D

var is_disguised: bool = false

func _ready() -> void:
	if normal_texture != null:
		player_sprite.texture = normal_texture

func _physics_process(_delta: float) -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	velocity.y = 0.0
	move_and_slide()

func wear_disguise() -> void:
	if is_disguised:
		return

	is_disguised = true

	if disguise_texture != null:
		player_sprite.texture = disguise_texture

	print("The boy is now wearing the disguise!")
