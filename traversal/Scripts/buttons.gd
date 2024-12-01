extends Button

func _ready():
	# Remove focus styling
	focus_mode = Control.FOCUS_NONE
	
	# Set normal text color (white or whatever your default is)
	add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# Set hover color
	add_theme_color_override("font_hover_color", Color(0, 0.8, 0.8, 1))
	
	# Optional: Set pressed color
	add_theme_color_override("font_pressed_color", Color(0, 0.9, 0.7, 1))
