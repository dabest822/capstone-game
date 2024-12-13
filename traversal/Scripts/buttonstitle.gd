extends Button

@onready var traversal_title = get_node("/root/Node2D/TraversalTitle") # Correct path to the TraversalTitle node
var float_direction = 1 # Direction of floating (1 for up, -1 for down)
var float_speed = 15.0 # Speed of the floating effect
var float_range = 10.0 # Maximum range of the floating effect
var initial_position = Vector2()

func _ready():
	# Remove focus styling
	focus_mode = Control.FOCUS_NONE
	
	# Set normal text color (white or whatever your default is)
	add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# Set hover color
	add_theme_color_override("font_hover_color", Color(0, 0.8, 0.8, 1))
	
	# Optional: Set pressed color
	add_theme_color_override("font_pressed_color", Color(0, 0.9, 0.7, 1))
	
	# Connect the pressed signal to our handler
	pressed.connect(_on_pressed)

	# Store the initial position of the title label
	if traversal_title:
		initial_position = traversal_title.position

func _on_pressed():
	# Check which button was pressed based on name
	if name == "Quit":
		get_tree().quit()
	# You can add other button functions here
	# elif name == "Play":
	#     start_game()
	# elif name == "Options":
	#     show_options()

func _process(delta):
	# Apply floating effect to the title
	if traversal_title:
		traversal_title.position.y += float_speed * float_direction * delta
		if traversal_title.position.y - initial_position.y > float_range:
			float_direction = -1 # Reverse direction to go up
		elif traversal_title.position.y - initial_position.y < -float_range:
			float_direction = 1 # Reverse direction to go down
