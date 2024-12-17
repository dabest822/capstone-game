extends CharacterBody2D

enum EnemyType {PTERODACTYL, TIGER }
enum State {PATROL, DIVING, RETURNING, CHASE }

@export var enemy_type: EnemyType
@export var patrol_speed: float = 150.0
@export var dive_speed: float = 300.0
@export var chase_speed: float = 200.0
@export var detection_range: float = 100.0  # Reduced from 300
@export var patrol_distance: float = 50.0   # Reduced from 200

var current_state = State.PATROL
var patrol_point_a: Vector2
var patrol_point_b: Vector2
var patrol_target: Vector2
var original_height: float
var player: Node2D = null

# Dynamically assigned variables
var animated_sprite: AnimatedSprite2D
var animated_sprite_2: AnimatedSprite2D
var tiger_area: Area2D
var pterodactyl_area: Area2D

func _ready():
	print("Current node name: ", name)
	print("Current node path: ", get_path())
	print("Enemy type: ", enemy_type)
	
	# Set up enemy-specific nodes
	if enemy_type == EnemyType.PTERODACTYL:
		animated_sprite = get_node("AnimatedSprite2D")
		pterodactyl_area = get_node("PterodactylArea")
		var pterodactyl_collision = get_node("PterodactylArea/CollisionShape2DPterodactyl")
		if pterodactyl_collision:
			patrol_distance = pterodactyl_collision.shape.extents.x
		print("Pterodactyl nodes found:")
		print("- AnimatedSprite2D: ", animated_sprite)
		print("- PterodactylArea: ", pterodactyl_area)
		if animated_sprite:
			animated_sprite.play("Flying")
			print("Starting pterodactyl animations")
			
	elif enemy_type == EnemyType.TIGER:
		animated_sprite_2 = get_node("AnimatedSprite2D2")
		tiger_area = get_node("TigerArea")
		var tiger_collision = get_node("TigerArea/CollisionShape2DTiger")
		
		if tiger_collision:
			# Use the collision shape's size for patrol distance
			patrol_distance = tiger_collision.shape.extents.x
			# Use slightly larger range for detection
			detection_range = tiger_collision.shape.extents.x * 1.5
			
		print("Tiger nodes found:")
		print("- AnimatedSprite2D2: ", animated_sprite_2)
		print("- TigerArea: ", tiger_area)
		print("- Patrol distance set to: ", patrol_distance)
		print("- Detection range set to: ", detection_range)
		
		if animated_sprite_2:
			animated_sprite_2.play("Walking")
			print("Starting tiger animations")
		if tiger_area:
			print("Tiger area found, checking signal connection...")
			print("Is body_entered already connected?", tiger_area.body_entered.is_connected(_on_area_2d_body_entered))
		
		# Connect signals for Tiger's TigerArea
		if tiger_area:
			print("Tiger collision layer before:", tiger_area.collision_layer)
			print("Tiger collision mask before:", tiger_area.collision_mask)
			
			# Area2D should NOT collide, only detect
			tiger_area.collision_layer = 0  # No collision layer (won't block anything)
			tiger_area.collision_mask = 1   # Only detect layer 1 (player)
			tiger_area.monitorable = true   # Can be detected
			tiger_area.monitoring = true    # Can detect others
			
			print("Tiger collision layer after:", tiger_area.collision_layer)
			print("Tiger collision mask after:", tiger_area.collision_mask)
			
			print("Connecting tiger area signals...")
		# Disconnect any existing connections first
		if tiger_area.body_entered.is_connected(_on_area_2d_body_entered):
			tiger_area.body_entered.disconnect(_on_area_2d_body_entered)
		if tiger_area.body_exited.is_connected(_on_area_2d_body_exited):
			tiger_area.body_exited.disconnect(_on_area_2d_body_exited)
			
		# Connect signals
			tiger_area.body_entered.connect(_on_area_2d_body_entered)
			tiger_area.body_exited.connect(_on_area_2d_body_exited)
			print("Signals connected successfully")
			# Get the regular collision shape (for physical collisions)
			var collision_shape = get_node_or_null("CollisionShape2D")
			if collision_shape:
				print("Found main collision shape")
				# This one should have physical collision
				collision_layer = 1  # Set the Tiger's physical collision layer
				collision_mask = 1   # What the Tiger can collide with

func find_player():
	print("Attempting to find player...")
	var possible_paths = [
		"../CharacterBody2D1",
		"../../CharacterBody2D1",
		"/root/Node2D/CharacterBody2D1"
	]
	
	for path in possible_paths:
		print("Trying path: ", path)
		player = get_node_or_null(path)
		if player:
			print("Found player at path: ", path)
			# Setup player collision
			player.collision_layer = 1
			player.collision_mask = 1
			print("Set player collision settings:")
			print("- Layer: ", player.collision_layer)
			print("- Mask: ", player.collision_mask)
			print("Player position: ", player.global_position)
			return
		else:
			print("No player at path: ", path)
	
	print("Player not found in any path!")

func _physics_process(delta):
	if enemy_type == EnemyType.TIGER and player:
		var distance = global_position.distance_to(player.global_position)
		print("Distance to player: ", distance)
	if enemy_type == EnemyType.PTERODACTYL:
		handle_pterodactyl_states()
	elif enemy_type == EnemyType.TIGER:
		handle_tiger_states()

	move_and_slide()

func handle_pterodactyl_states():
	if current_state == State.PATROL:
		handle_patrol()

func handle_tiger_states():
	if current_state == State.PATROL:
		handle_patrol()
	elif current_state == State.CHASE:
		handle_chase()

func handle_patrol():
	var direction = (patrol_target - global_position).normalized()
	velocity = direction * patrol_speed
	
	# Flip sprite based on movement direction
	if enemy_type == EnemyType.TIGER and animated_sprite_2:
		animated_sprite_2.flip_h = direction.x < 0  # Flip when moving left
		animated_sprite_2.play("Walking")
		
	if global_position.distance_to(patrol_target) < 10:
		patrol_target = patrol_point_a if patrol_target == patrol_point_b else patrol_point_b

func handle_chase():
	if not player:
		current_state = State.PATROL
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * chase_speed

	if animated_sprite_2:
		animated_sprite_2.flip_h = player.global_position.x < global_position.x
		animated_sprite_2.play("Attacking")

func _on_area_2d_body_entered(body):
	print("Body entered tiger area:", body.name)
	print("Body collision layer:", body.collision_layer)
	print("Is body the player?", body == player)
	print("Is body self?", body == self)
	
	if body == self:
		print("Tiger detected itself, ignoring...")
		return
		
	if body == player:
		print("Tiger detected player!")
		current_state = State.CHASE
	else:
		print("Tiger detected unknown body:", body.name)

func _on_area_2d_body_exited(body):
	print("Body exited tiger area:", body.name)  # Debug all bodies
	if body == player:
		print("Player exited Tiger area")
		current_state = State.PATROL

func _on_tiger_area_body_exited(body):
	print("Body exited tiger area:", body.name)  # Debug all bodies
	if body == player:
		print("Player exited Tiger area")
		current_state = State.PATROL
