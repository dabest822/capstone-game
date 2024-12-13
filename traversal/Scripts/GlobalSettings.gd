extends Node

var volume_value = 50  # Default volume

func save_settings():
	# Use FileAccess to write settings
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if file:
		file.store_var(volume_value)  # Save the volume value
		file.close()
		print("Settings saved to user://settings.cfg")
	else:
		print("Failed to save settings!")

func load_settings():
	# Use FileAccess to check and read settings
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		if file:
			volume_value = file.get_var(50)  # Load the saved volume, default to 50
			file.close()
			print("Settings loaded from user://settings.cfg")
		else:
			print("Failed to load settings!")
	else:
		print("No saved settings file found!")
