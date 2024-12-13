extends CharacterBody2D

const SPEED = 250.0
const RUN_SPEED = 500.0
const JUMP_VELOCITY = -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $SpriteContainer/AnimatedSprite2D1

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("JumpStraight")

	# Handle movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		if Input.is_action_pressed("ui_shift"):
			velocity.x = direction * RUN_SPEED
			if is_on_floor():
				animated_sprite.play("Run")
		else:
			velocity.x = direction * SPEED
			if is_on_floor():
				animated_sprite.play("Walk")

		# Flip the sprite based on direction
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			if animated_sprite.flip_h:
				animated_sprite.play("Idle2") # Play Idle2 if facing left
			else:
				animated_sprite.play("Idle") # Play Idle if facing right

	# Handle airborne animation
	if not is_on_floor() and velocity.y < 0:
		animated_sprite.play("JumpStraight")

	move_and_slide()

# Handle portal interaction
func _on_area_2d_portal_body_entered(body):
	if body == self:
		get_tree().quit()  # Close the game when entering portal
