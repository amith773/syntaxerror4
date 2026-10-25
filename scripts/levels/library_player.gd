
extends CharacterBody2D

@export var speed: float = 220.0
@export var left_limit: float = 350.0
@export var right_limit: float = 1300.0

@onready var normal_sprite: Sprite2D = $PlayerSprite
@onready var worried_sprite: Sprite2D = $WorriedSprite
@onready var catch_point: Area2D = get_parent().get_node("CatchPoint")
@onready var balloons: Sprite2D = get_parent().get_node("Balloons")
@onready var balloon_area: Area2D = balloons.get_node("InteractionArea")

var phase: int = 0
var near_balloons: bool = false

func _ready() -> void:
	normal_sprite.visible = true
	worried_sprite.visible = false
	balloon_area.body_entered.connect(_on_balloon_area_body_entered)
	balloon_area.body_exited.connect(_on_balloon_area_body_exited)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	var trigger_x := catch_point.global_position.x

	if phase == 0 and global_position.x >= trigger_x:
		phase = 1
		normal_sprite.visible = false
		worried_sprite.visible = true

	if phase == 1 and direction > 0.0:
		direction = 0.0

	velocity = Vector2(direction * speed, 0.0)
	move_and_slide()

	global_position.x = clampf(global_position.x, left_limit, right_limit)

	if phase == 1 and global_position.x < trigger_x:
		phase = 2
		normal_sprite.visible = true
		worried_sprite.visible = false
		print("Balloons unlocked!")

	if phase == 2 and near_balloons and Input.is_action_just_pressed("interact"):
		balloons.activate()

func _on_balloon_area_body_entered(body: Node2D) -> void:
	if body == self:
		near_balloons = true

func _on_balloon_area_body_exited(body: Node2D) -> void:
	if body == self:
		near_balloons = false
