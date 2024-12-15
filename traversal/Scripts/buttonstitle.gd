extends Button

@onready var traversal_title = get_node("/root/Node2D/TraversalTitle")
@onready var title_theme = get_node("/root/Node2D/TitleTheme")

var float_direction = 1
var float_speed = 10.0
var float_range = 10.0
var initial_position = Vector2()

func _ready():
	# Button display fixes
	print("WynnCredits - Visible:", get_node("/root/Node2D/WynnCredits").visible, 
	", Position:", get_node("/root/Node2D/WynnCredits").position)
	print("Demo - Visible:", get_node("/root/Node2D/Demo").visible, 
	", Position:", get_node("/root/Node2D/Demo").position)
	custom_minimum_size = Vector2(200, 80)  # Adjust these values based on your needs
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Make sure the button grows with the text
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Original button setup
	focus_mode = Control.FOCUS_NONE
	add_theme_color_override("font_color", Color(1, 1, 1, 1))
	add_theme_color_override("font_hover_color", Color(0, 0.8, 0.8, 1))
	add_theme_color_override("font_pressed_color", Color(0, 0.9, 0.7, 1))
	add_theme_constant_override("outline_size", 2)
	
	pressed.connect(_on_pressed)
	
	if traversal_title:
		initial_position = traversal_title.position
		
	# Start playing the title theme
	if title_theme and !title_theme.playing:
		title_theme.play()

func _on_pressed():
	if name == "Quit":
		# Stop music only when quitting
		if title_theme and title_theme.playing:
			title_theme.stop()
		get_tree().quit()
	elif name == "Play":
		var camera = get_node("/root/Node2D/EarthZoom/Camera2D")
		if camera:
			camera.start_game()
	elif name == "Options":
		# Stop music when going to options
		if title_theme and title_theme.playing:
			title_theme.stop()
		get_tree().change_scene_to_file("res://Scenes/Options.tscn")

func _process(delta):
	if traversal_title:
		traversal_title.position.y += float_speed * float_direction * delta
		if traversal_title.position.y - initial_position.y > float_range:
			float_direction = -1
		elif traversal_title.position.y - initial_position.y < -float_range:
			float_direction = 1

func _exit_tree():
	if title_theme and title_theme.playing:
		title_theme.stop()
