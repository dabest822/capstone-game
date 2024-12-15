extends Node
var volume_value = 50
const PAUSE_MENU_SCENE = "res://Scenes/PauseMenu.tscn"
var previous_scene_path = ""
var previous_volume = 1.0
var is_paused = false

func _ready():
	# Get reference to pause menu and set it up
	var pause_menu = get_node("/root/PauseMenu")
	if pause_menu:
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		pause_menu.hide()

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

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	var pause_menu = get_node("/root/PauseMenu")
	if !pause_menu:
		print("Pause menu not found!")
		return

	is_paused = !is_paused
	print("GlobalSettings - Pause state changed to: ", is_paused)

	if is_paused:
		pause_menu.show()
		# Enable processing on pause menu before pausing tree
		pause_menu.set_process(true)
		get_tree().paused = true
		print("Game paused - Tree pause state: ", get_tree().paused)
	else:
		pause_menu.hide()
		# Disable processing on pause menu after unpausing tree
		pause_menu.set_process(false)
		get_tree().paused = false
		print("Game unpaused - Tree pause state: ", get_tree().paused)

func unpause_game():
	if is_paused:
		is_paused = false
		var pause_menu = get_node("/root/PauseMenu")
		if pause_menu:
			pause_menu.hide()
			get_tree().paused = false
			print("Game unpaused")
