extends CharacterBody2D

const SPEED = 250.0
const DEPTH_SPEED = 150.0
const CUSTOM_GRAVITY = 300.0
const JUMP_FORCE = -500.0
const MAX_FALL_SPEED = 1000.0

@onready var animated_sprite = $SpriteContainer/AnimatedSprite2D1
@onready var collision_shape = $CollisionShapeMark

func _ready():
	# Make sure we're using the exact same collision settings as your TileMap
	set_collision_layer_value(1, false)  # Clear default layer
	set_collision_layer_value(2, true)   # Set to layer 2
	
	# The physics mask needs to match the floor's physics layer
	set_collision_mask_value(1, false)   # Clear default mask
	set_collision_mask_value(2, true)    # Set to layer 2
	
	# Make sure collision shape is enabled and configured
	if collision_shape:
		collision_shape.disabled = false

func _physics_process(delta: float) -> void:
	# Apply gravity with a max fall speed
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		# When on floor, maintain small downward velocity for better floor detection
		velocity.y = 1.0
	
	# Handle horizontal movement
	var direction_x = Input.get_axis("ui_left", "ui_right")
	if direction_x:
		velocity.x = direction_x * SPEED
		animated_sprite.flip_h = direction_x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	# Handle jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	# Update animations before moving
	if not is_on_floor():
		animated_sprite.play("JumpStraight")
	else:
		if abs(velocity.x) > 10:
			if abs(velocity.x) > SPEED * 0.8:
				animated_sprite.play("Run")
			else:
				animated_sprite.play("Walk")
		else:
			animated_sprite.play("Idle")
	
	# Apply movement
	move_and_slide()
