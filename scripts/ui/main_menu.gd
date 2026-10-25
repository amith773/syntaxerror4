extends Control

@onready var start_button: Button = $CenterContainer/MenuVBox/StartButton
@onready var quit_button: Button = $CenterContainer/MenuVBox/QuitButton

@onready var background: CanvasItem = $background
@onready var title: CanvasItem = $Title
@onready var subtitle: CanvasItem = $Subtitle
@onready var intro_video: VideoStreamPlayer = $IntroVideo

@onready var menu_container: Control = $CenterContainer


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Hide the menu while the intro plays.
	background.hide()
	title.hide()
	subtitle.hide()
	menu_container.hide()

	# Make the video cover the screen.
	intro_video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_video.expand = true
	intro_video.show()

	# Show the menu when the video finishes.
	intro_video.finished.connect(_on_intro_finished)

	if intro_video.stream:
		intro_video.play()
	else:
		push_warning("IntroVideo has no video assigned. Showing the menu.")
		_show_menu()


func _on_intro_finished() -> void:
	_show_menu()


func _show_menu() -> void:
	intro_video.hide()
	background.show()
	title.show()
	subtitle.show()
	menu_container.show()


func _on_start_pressed() -> void:
	var campus_scene := "res://scenes/campus/campus_map.tscn"

	if ResourceLoader.exists(campus_scene):
		get_tree().change_scene_to_file(campus_scene)
	else:
		push_warning("Campus map scene not found: " + campus_scene)
		print("Create scenes/campus/campus_map.tscn or update the path in main_menu.gd.")


func _on_quit_pressed() -> void:
	get_tree().quit()
