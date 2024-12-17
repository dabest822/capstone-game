extends CharacterBody2D

enum EnemyType {PTERODACTYL, TIGER}
enum State {PATROL, DIVING, RETURNING, CHASE}

@export var enemy_type: EnemyType
@export var patrol_speed: float = 150.0
@export var dive_speed: float = 300.0
@export var chase_speed: float = 200.0
@export var patrol_width: float = 400.0  # Increased from 200 to 400
@export var attack_cooldown: float = 3.0  # Time between attacks

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
			player.collision_layer = 1
			player.collision_mask = 1
			print("Player collision settings - Layer: ", player.collision_layer, ", Mask: ", player.collision_mask)
			return
	print("Player not found in any path!")

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
		print("Starting tiger animations")
	
	if tiger_area:
		setup_tiger_area()

func setup_tiger_area():
	# Clear any existing connections
	if tiger_area.body_entered.is_connected(_on_area_2d_body_entered):
		tiger_area.body_entered.disconnect(_on_area_2d_body_entered)
	if tiger_area.body_exited.is_connected(_on_area_2d_body_exited):
		tiger_area.body_exited.disconnect(_on_area_2d_body_exited)
	
	# Set up area properties
	tiger_area.collision_layer = 0
	tiger_area.collision_mask = 1
	tiger_area.monitorable = true
	tiger_area.monitoring = true
	
	# Connect signals
	tiger_area.body_entered.connect(_on_area_2d_body_entered)
	tiger_area.body_exited.connect(_on_area_2d_body_exited)
	
	print("Tiger area setup complete - Layer: ", tiger_area.collision_layer, ", Mask: ", tiger_area.collision_mask)

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
		velocity.y = 0  # Keep vertical velocity at 0 for horizontal movement
		
		# Update sprite direction
		if animated_sprite_2:
			animated_sprite_2.flip_h = patrol_direction < 0
			animated_sprite_2.play("Walking")
		
		# Debug patrol boundaries
		print("Current position: ", global_position.x, " Left bound: ", left_bound, " Right bound: ", right_bound)
		
		# Check if we need to turn around
		if (patrol_direction > 0 and global_position.x >= right_bound) or \
		   (patrol_direction < 0 and global_position.x <= left_bound):
			patrol_direction *= -1  # Reverse direction
			print("Turning around, new direction: ", patrol_direction)
			
	# Move the enemy
	move_and_slide()

func handle_chase():
	if not player:
		current_state = State.PATROL
		return

	var direction = (player.global_position - global_position).normalized()
	
	if can_attack:
		velocity = direction * chase_speed * 2  # Leap towards player
		if animated_sprite_2:
			animated_sprite_2.flip_h = player.global_position.x < global_position.x
			animated_sprite_2.play("Attacking")
		can_attack = false
		attack_timer = 0.0
		print("Tiger attacking!")
	else:
		# Stay in place between attacks
		velocity = Vector2.ZERO
	
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body == self or body.collision_layer != 1:
		return
	
	# Check if the body is the player by its collision layer and not self
	var distance = global_position.distance_to(body.global_position)
	print("Player detected at distance: ", distance)
	current_state = State.CHASE

func _on_area_2d_body_exited(body):
	# Check if the body is the player by its collision layer
	if body.collision_layer == 1 and body != self:
		print("Player left area - returning to patrol")
		current_state = State.PATROL
		if animated_sprite_2:
			animated_sprite_2.play("Walking")
