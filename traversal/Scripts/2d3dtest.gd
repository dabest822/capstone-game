extends CharacterBody2D

@export var walk_speed: float = 200.0  # Speed for walking
@export var run_speed: float = 400.0  # Speed for running
@onready var animated_sprite = $SpriteContainer/AnimatedSprite2D1  # Correct node name

enum MovementState { IDLE, WALK, RUN }
var movement_state = MovementState.IDLE

var last_direction = Vector2(0, 1)  # Default facing direction (down)

func _physics_process(_delta):
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if input_dir != Vector2.ZERO:
		# Check if running or walking
		if Input.is_action_pressed("ui_shift"):
			movement_state = MovementState.RUN
			velocity = input_dir.normalized() * run_speed
			animated_sprite.play("Run")
		else:
			movement_state = MovementState.WALK
			velocity = input_dir.normalized() * walk_speed
			animated_sprite.play("Walk")

		# Update last direction for idle animation
		last_direction = input_dir
	else:
		# If no input, switch to idle
		velocity = Vector2.ZERO
		movement_state = MovementState.IDLE
		animated_sprite.play("Idle")

	# Adjust sprite orientation
	adjust_sprite_orientation(input_dir)

	# Apply movement
	move_and_slide()

func adjust_sprite_orientation(direction):
	# Only flip horizontally for left/right movement
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0  # Flip for left
	elif direction.y != 0:
		animated_sprite.flip_h = false  # Reset horizontal flip for up/down
