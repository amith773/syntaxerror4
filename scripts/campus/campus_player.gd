extends CharacterBody2D

@export var speed: float = 220.0


func _ready() -> void:
	var tree := get_tree()

	if tree.has_meta("return_marker"):
		var marker_name: String = tree.get_meta("return_marker")
		var marker := get_parent().find_child(marker_name, true, false) as Marker2D

		if marker:
			global_position = marker.global_position
			print("Returned to marker: ", marker_name)
		else:
			push_warning("Return marker not found: " + marker_name)

		tree.remove_meta("return_marker")


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	velocity = direction.normalized() * speed
	move_and_slide()
