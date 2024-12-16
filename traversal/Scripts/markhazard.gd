extends CharacterBody2D

# Movement Constants
const SPEED = 250.0
const RUN_SPEED = 500.0
const JUMP_VELOCITY = -500.0

# Health System Constants
const MAX_HEALTH = 100
const INVINCIBILITY_TIME = 1.5

# Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_health = MAX_HEALTH
var is_invincible = false
var is_in_special_animation = false

# Node References
@onready var animated_sprite = $SpriteContainer/AnimatedSprite2D1
@onready var health_bar = $"../MainGUI/GUIRoot/MarginContainer/TopBar/HealthBar"
@onready var invincibility_timer = Timer.new()

func _ready():
	# Health system setup
	add_child(invincibility_timer)
	invincibility_timer.one_shot = true
	invincibility_timer.wait_time = INVINCIBILITY_TIME
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	
	# Initialize health bar
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = current_health
	
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle special animations first
	if Input.is_action_just_pressed("1"):
		animated_sprite.play("Attack1")
		is_in_special_animation = true
	elif Input.is_action_just_pressed("3"):
		animated_sprite.play("Attack3")
		is_in_special_animation = true
	elif Input.is_action_just_pressed("4"):
		animated_sprite.play("Attack4")
		is_in_special_animation = true
	elif Input.is_action_just_pressed("g"):
		animated_sprite.play("Dying")
		is_in_special_animation = true

	# Only handle regular movement animations if not in special animation
	if not is_in_special_animation:
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
			animated_sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				if animated_sprite.flip_h:
					animated_sprite.play("Idle2")
				else:
					animated_sprite.play("Idle")

		# Handle airborne animation
		if not is_on_floor() and velocity.y < 0:
			animated_sprite.play("JumpStraight")

	move_and_slide()

func take_damage(amount):
	if is_invincible:
		return
		
	current_health = max(0, current_health - amount)
	if health_bar:
		health_bar.value = current_health
	
	# Start invincibility
	is_invincible = true
	invincibility_timer.start()
	
	# Flash effect
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)
	tween.set_loops(int(INVINCIBILITY_TIME / 0.2))
	
	if current_health <= 0:
		die()

func heal(amount):
	current_health = min(MAX_HEALTH, current_health + amount)
	if health_bar:
		health_bar.value = current_health

func _on_invincibility_timeout():
	is_invincible = false
	animated_sprite.modulate.a = 1.0

func die():
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	var err = get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
	if err != OK:
		print("Error loading game over scene: ", err)

func _on_area_body_entered(body):
	if body == self:
		trigger_portal_transition()

func trigger_portal_transition():
	# Get references to nodes we need to hide
	var shader_display = get_node_or_null("../ShaderDisplay")
	var color_rect = get_node_or_null("../ShaderDisplay/ColorRect")
	var tilemap = get_node_or_null("../TileMapLayer")
	
	# Show transition effect
	if shader_display:
		shader_display.visible = true
	if color_rect:
		color_rect.visible = true
	
	# Hide nodes
	if tilemap:
		tilemap.hide()
	hide()
	
	# Create and start transition timer
	var transition_timer = Timer.new()
	add_child(transition_timer)
	transition_timer.one_shot = true
	transition_timer.wait_time = 5.0
	transition_timer.timeout.connect(_on_transition_complete)
	transition_timer.start()

func _on_transition_complete():
	# We need to ensure we're still in the scene tree
	if is_inside_tree():
		var err = get_tree().change_scene_to_file("res://Scenes/PrehistoricEra.tscn")
		if err != OK:
			print("Error changing scene: ", err)

func _on_animation_finished():
	# Return to idle after attack animations finish
	if animated_sprite.animation in ["Attack1", "Attack2", "Attack3", "Attack4"]:
		is_in_special_animation = false
		if animated_sprite.flip_h:
			animated_sprite.play("Idle2")
		else:
			animated_sprite.play("Idle")
