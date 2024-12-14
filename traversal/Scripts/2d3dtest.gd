extends CharacterBody2D

@export var walk_speed: float = 200.0
@export var run_speed: float = 400.0
@export var movement_range: float = 100.0

@onready var animated_sprite = $SpriteContainer/AnimatedSprite2D1
@onready var path_segments = get_node_or_null("../PathSegments")

var right_wall: Polygon2D
var left_wall: Polygon2D
var right_wall_initial_pos: Vector2
var left_wall_initial_pos: Vector2
var facing_right: bool = true
var is_jumping: bool = false
var initial_x_position: float
var movement_bounds: Vector2
@export var bottom_boundary: float = 0
@export var top_boundary: float = 100

func _ready():
	# Adjust the player's initial position to align with the path
	initial_x_position = global_position.x
	global_position.y = bottom_boundary  # Adjust '50' as needed
	
	# Set movement bounds
	movement_bounds.x = initial_x_position - movement_range
	movement_bounds.y = initial_x_position + movement_range
	
	# Find and store wall references
	right_wall = get_node_or_null("../RightWall") as Polygon2D
	left_wall = get_node_or_null("../LeftWall") as Polygon2D
	
	if not right_wall or not left_wall:
		push_error("RightWall or LeftWall not found! Check the paths.")
		return
	
	right_wall_initial_pos = right_wall.global_position
	left_wall_initial_pos = left_wall.global_position

func _physics_process(_delta):
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	# Handle jumping
	if Input.is_action_just_pressed("ui_select") and not is_jumping:
		is_jumping = true
		animated_sprite.play("JumpStraight")
	
	if is_jumping and animated_sprite.animation == "JumpStraight" and animated_sprite.frame >= animated_sprite.sprite_frames.get_frame_count("JumpStraight") - 1:
		is_jumping = false
	
	# Handle movement and animations
	if input_dir != Vector2.ZERO:
		var current_speed = run_speed if Input.is_action_pressed("ui_shift") else walk_speed
		
		# Allow horizontal movement within bounds
		if global_position.x >= movement_bounds.x and global_position.x <= movement_bounds.y:
			velocity.x = input_dir.x * current_speed
		else:
			velocity.x = 0
		
		# Allow vertical movement within Y boundaries
		if global_position.y >= bottom_boundary and global_position.y <= top_boundary:
			velocity.y = input_dir.y * current_speed
		else:
			velocity.y = 0
		
		# Update facing direction
		if input_dir.x > 0:
			facing_right = true
			animated_sprite.flip_h = false
		elif input_dir.x < 0:
			facing_right = false
			animated_sprite.flip_h = true
		
		# Play movement animations
		if not is_jumping:
			if Input.is_action_pressed("ui_shift"):
				animated_sprite.play("Run")
			else:
				animated_sprite.play("Walk")
	else:
		velocity = Vector2.ZERO
		if not is_jumping:
			animated_sprite.play("Idle" if facing_right else "Idle2")
	
	# Move the character
	move_and_slide()
	
	# Clamp positions to enforce bounds
	global_position.x = clamp(global_position.x, movement_bounds.x, movement_bounds.y)
	global_position.y = clamp(global_position.y, bottom_boundary, top_boundary)
	
	# Keep walls fixed
	if right_wall and left_wall:
		right_wall.global_position = right_wall_initial_pos
		left_wall.global_position = left_wall_initial_pos
