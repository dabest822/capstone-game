extends CharacterBody2D

enum EnemyType {PTERODACTYL, TIGER}
enum State {PATROL, DIVING, RETURNING, CHASE}

@export var enemy_type: EnemyType
@export var patrol_speed: float = 200.0
@export var dive_speed: float = 300.0
@export var chase_speed: float = 200.0
@export var patrol_width: float = 800.0  # Increased patrol range
@export var attack_cooldown: float = 2.0  # Time between attacks

var current_state = State.PATROL
var patrol_direction: int = 1  # 1 for right, -1 for left
var start_position: Vector2
var player: Node2D = null
var can_attack: bool = true
var attack_timer: float = 0.0

# Dynamically assigned variables
var animated_sprite: AnimatedSprite2D
var animated_sprite_2: AnimatedSprite2D
var tiger_area: Area2D
var pterodactyl_area: Area2D

func _ready():
	print("Current node name: ", name)
	print("Current node path: ", get_path())
	print("Enemy type: ", enemy_type)
	
	start_position = global_position
	find_player()
	setup_enemy()

func find_player():
	print("Attempting to find player...")
	var possible_paths = ["../CharacterBody2D1", "../../CharacterBody2D1", "/root/Node2D/CharacterBody2D1"]
	
	for path in possible_paths:
		print("Trying path: ", path)
		player = get_node_or_null(path)
		if player:
			print("Found player at path: ", path)
			return
			
	print("Player not found!")

func setup_enemy():
	if enemy_type == EnemyType.PTERODACTYL:
		setup_pterodactyl()
	else:
		setup_tiger()

func setup_pterodactyl():
	animated_sprite = get_node("AnimatedSprite2D")
	pterodactyl_area = get_node("PterodactylArea")
	
	if animated_sprite:
		animated_sprite.play("Flying")
		print("Starting pterodactyl animations")

func setup_tiger():
	animated_sprite_2 = get_node("AnimatedSprite2D2")
	tiger_area = get_node("TigerArea")
	
	if animated_sprite_2:
		animated_sprite_2.play("Walking")
		animated_sprite_2.animation_finished.connect(_on_animation_finished)  # Connect signal
		print("Starting tiger animations")
	
	if tiger_area:
		# Setup tiger detection area
		tiger_area.collision_layer = 0  # No collision
		tiger_area.collision_mask = 1   # Only detect player
		tiger_area.monitoring = true
		tiger_area.monitorable = true
		
		# Connect signals for detection
		if tiger_area.body_entered.is_connected(_on_area_2d_body_entered):
			tiger_area.body_entered.disconnect(_on_area_2d_body_entered)
		if tiger_area.body_exited.is_connected(_on_area_2d_body_exited):
			tiger_area.body_exited.disconnect(_on_area_2d_body_exited)
		
		tiger_area.body_entered.connect(_on_area_2d_body_entered)
		tiger_area.body_exited.connect(_on_area_2d_body_exited)

func _physics_process(delta):
	if not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
			attack_timer = 0.0
			
	if enemy_type == EnemyType.PTERODACTYL:
		handle_pterodactyl_states()
	elif enemy_type == EnemyType.TIGER:
		handle_tiger_states()

func handle_pterodactyl_states():
	if current_state == State.PATROL:
		handle_patrol()

func handle_tiger_states():
	if current_state == State.PATROL:
		handle_patrol()
	elif current_state == State.CHASE:
		handle_chase()

func handle_patrol():
	if enemy_type == EnemyType.TIGER:
		# Calculate patrol boundaries
		var left_bound = start_position.x - patrol_width/2
		var right_bound = start_position.x + patrol_width/2
		
		# Set velocity based on patrol direction
		velocity.x = patrol_speed * patrol_direction
		velocity.y = 0
		
		if animated_sprite_2:
			animated_sprite_2.flip_h = patrol_direction > 0
			animated_sprite_2.play("Walking")
		
		# Check if we need to turn around
		if (patrol_direction > 0 and global_position.x >= right_bound) or \
		   (patrol_direction < 0 and global_position.x <= left_bound):
			patrol_direction *= -1
			
	move_and_slide()

func handle_chase():
	if not player:
		current_state = State.PATROL
		return

	# Calculate direction to the player
	var direction = (player.global_position - global_position).normalized()

	# Only attack when cooldown is ready
	if can_attack:
		# Play Attacking animation and leap
		if animated_sprite_2.animation != "Attacking":
			animated_sprite_2.play("Attacking")
			velocity = direction * chase_speed * 2  # Leap towards the player
			can_attack = false
			attack_timer = 0.0
	else:
		# Slowly move toward the player between attacks
		if animated_sprite_2.animation != "Attacking":
			velocity = direction * patrol_speed * 0.5  # Slow movement
			if animated_sprite_2.animation != "Walking":
				animated_sprite_2.play("Walking")

	# Face the player
	if velocity.x != 0:
		animated_sprite_2.flip_h = velocity.x > 0

	# Handle cooldown timer
	if not can_attack:
		attack_timer += get_process_delta_time()
		if attack_timer >= attack_cooldown:
			can_attack = true

	# Apply movement unless attacking
	if animated_sprite_2.animation != "Attacking":
		move_and_slide()

func _on_area_2d_body_entered(body):
	if body == self:
		return
		
	if body.collision_layer == 1 and body != self:
		print("Player detected - starting chase!")
		current_state = State.CHASE

func _on_area_2d_body_exited(body):
	if body == self:
		return
		
	if body.collision_layer == 1 and body != self:
		print("Player left - returning to patrol")
		current_state = State.PATROL
		if animated_sprite_2:
			animated_sprite_2.play("Walking")

func _on_animation_finished():
	if animated_sprite_2.animation == "Attacking":
		print("Attack animation finished!")
		can_attack = true
		animated_sprite_2.play("Walking")
