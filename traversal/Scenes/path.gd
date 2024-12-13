extends PathFollow2D

@export var movement_speed: float = 0.5
@export var can_move_backwards: bool = true  # Set to false if you only want forward movement

# Current direction of movement (1 for forward, -1 for backward)
var movement_direction: int = 1

func _ready():
	# Start at beginning of path
	progress_ratio = 0.0
	# Don't rotate as we move along the path
	rotates = false

func _process(delta):
	# Check for up/down input
	if Input.is_action_pressed("ui_up"):
		progress_ratio += delta * movement_speed
	elif Input.is_action_pressed("ui_down") and can_move_backwards:
		progress_ratio -= delta * movement_speed
	
	# Clamp progress_ratio between 0 and 1
	progress_ratio = clamp(progress_ratio, 0.0, 1.0)
	
	# Debug info
	if OS.is_debug_build():
		print("Current progress: ", progress_ratio)

# Optional: Function to instantly move to start or end of path
func move_to_start():
	progress_ratio = 0.0

func move_to_end():
	progress_ratio = 1.0
