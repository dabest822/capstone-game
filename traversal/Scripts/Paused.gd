extends CanvasLayer

@onready var pause_menu_music = $Panel/PauseMenuMusic  # Optional: Music for Pause Menu
@onready var overlay = $Panel/Transparency  # Reference to the transparent overlay

func _ready():
	# Play music if available
	if pause_menu_music:
		pause_menu_music.play()
	print("Pause Menu Ready!")
	
	if overlay:
		overlay.color = Color(0, 0, 0, 0.5)  # Black color with 50% transparency
		overlay.size = get_viewport().size

func _process(delta):
	# Detect the "returntogame" input
	if Input.is_action_just_pressed("returntogame"):
		_return_to_previous_scene()

func _return_to_previous_scene():
	# Restore the volume to its previous value
	_restore_volume()

	# Switch back to the previous scene
	if GlobalSettings.previous_scene_path != "":
		print("Returning to previous scene: ", GlobalSettings.previous_scene_path)
		get_tree().change_scene_to_file(GlobalSettings.previous_scene_path)
	else:
		print("No previous scene to return to!")

func _restore_volume():
	# Restore the previously saved volume
	var previous_volume_db = GlobalSettings.previous_volume
	AudioServer.set_bus_volume_db(0, previous_volume_db)
	print("Restored volume to: ", previous_volume_db)
