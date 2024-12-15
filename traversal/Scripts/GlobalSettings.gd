extends Node

var volume_value = 50  # Default volume for settings saving
const PAUSE_MENU_SCENE = "res://Scenes/PauseMenu.tscn"

var previous_scene_path = ""  # Stores the path of the previous scene
var previous_volume = 1.0  # Stores the previous volume level

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if file:
		file.store_var(volume_value)
		file.close()
		print("Settings saved to user://settings.cfg")
	else:
		print("Failed to save settings!")

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		if file:
			volume_value = file.get_var(50)
			file.close()
			print("Settings loaded from user://settings.cfg")
		else:
			print("Failed to load settings!")
	else:
		print("No saved settings file found!")

func _process(delta):
	# Detect the "pause" input
	if Input.is_action_just_pressed("pause"):
		if get_tree().current_scene.name != "PauseMenu":
			_open_pause_menu()

func _open_pause_menu():
	# Store the current scene path and volume
	previous_scene_path = get_tree().current_scene.scene_file_path
	previous_volume = AudioServer.get_bus_volume_db(0)
	print("Stored previous scene: ", previous_scene_path)
	print("Stored volume: ", previous_volume)

	# Set volume to 20% (0.2 linear, converted to dB)
	_set_volume_to_20_percent()

	# Load the PauseMenu scene
	get_tree().change_scene_to_file(PAUSE_MENU_SCENE)

func _set_volume_to_20_percent():
	# Convert linear value 0.2 to dB
	var target_db = linear_to_db(0.2)  # Fixed function name
	AudioServer.set_bus_volume_db(0, target_db)
	print("Volume set to 20% (dB): ", target_db)
