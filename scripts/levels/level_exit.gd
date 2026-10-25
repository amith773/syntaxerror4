extends Area2D

var exiting: bool = false


func _ready() -> void:
	print("Sarojini LevelExit is ready")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Exit detected body: ", body.name)

	if exiting or body.name != "Player":
		return

	exiting = true

	# Tell the campus scene to return to Sarojini Bhawan.
	get_tree().set_meta("return_marker", "SarojiniReturnPoint")

	var campus_scene := "res://scenes/campus/campus_map.tscn"
	var error := get_tree().change_scene_to_file(campus_scene)

	print("Scene change error code: ", error)

	if error != OK:
		exiting = false
