extends CharacterBody2D

enum EnemyType {PTERODACTYL, TIGER}
enum State {PATROL, DIVING, RETURNING, CHASE}

@export var enemy_type: EnemyType
@export var patrol_speed: float = 150.0
@export var dive_speed: float = 300.0
@export var chase_speed: float = 200.0
@export var detection_range: float = 300.0
@export var patrol_distance: float = 200.0  # Distance for patrol points

var current_state = State.PATROL
var patrol_point_a: Vector2
var patrol_point_b: Vector2
var patrol_target: Vector2
var original_height: float
var target_position: Vector2
var player: Node2D = null
var chase_area: Area2D = null

# Dynamically assigned variables
var animated_sprite: AnimatedSprite2D
var animated_sprite_2: AnimatedSprite2D
var collision_area: Area2D

func _ready():
	# Fix: Use absolute paths from the root
	animated_sprite = get_node_or_null("/root/Node2D/Pterodactyl/AnimatedSprite2D")
	animated_sprite_2 = get_node_or_null("/root/Node2D/Tiger/AnimatedSprite2D2")
	collision_area = $Area2D

	# Debugging: Verify nodes are assigned properly
	print("Animated Sprite (Pterodactyl): ", animated_sprite)
	print("Animated Sprite 2 (Tiger): ", animated_sprite_2)

	# Initialize patrol points
	original_height = global_position.y
	patrol_point_a = global_position + Vector2(-patrol_distance, 0)
	patrol_point_b = global_position + Vector2(patrol_distance, 0)
	patrol_target = patrol_point_b

	# Set up initial animations
	if enemy_type == EnemyType.PTERODACTYL and animated_sprite:
		animated_sprite.play("Flying")
		print("Starting pterodactyl animations")
	elif enemy_type == EnemyType.TIGER and animated_sprite_2:
		print("Tiger animation logic running...")
		animated_sprite_2.play("Walking")

	find_player()
	
	# Set up chase area for tiger
	if enemy_type == EnemyType.TIGER:
		setup_chase_area()
		
	print("Enemy Type: ", enemy_type)

func setup_chase_area():
	chase_area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = detection_range
	shape.shape = circle
	
	chase_area.collision_layer = 0
	chase_area.collision_mask = 1
	
	chase_area.add_child(shape)
	add_child(chase_area)
	chase_area.body_entered.connect(_on_chase_area_entered)
	chase_area.body_exited.connect(_on_chase_area_exited)

func _on_chase_area_entered(body):
	# Ensure the body is the player
	if body == player:
		print("Tiger detected player")
		current_state = State.CHASE
		animated_sprite_2.play("Attacking")
	else:
		print("Ignored body: ", body.name)  # Debug print for non-player objects

func _on_chase_area_exited(body):
	if enemy_type == EnemyType.TIGER and body == player:
		current_state = State.PATROL
		animated_sprite_2.play("Walking")

func find_player():
	var possible_paths = [
		"../CharacterBody2D1",
		"../../CharacterBody2D1",
		"/root/Node2D/CharacterBody2D1"
	]
	
	for path in possible_paths:
		player = get_node_or_null(path)
		if player:
			print("Found player at path: ", path)
			return
	
	print("Player not found!")

func _physics_process(delta):
	match enemy_type:
		EnemyType.PTERODACTYL:
			handle_pterodactyl_states()
		EnemyType.TIGER:
			handle_tiger_states()
	
	move_and_slide()
	
	if velocity.x != 0:
		match enemy_type:
			EnemyType.PTERODACTYL:
				if animated_sprite:
					animated_sprite.flip_h = velocity.x < 0
			EnemyType.TIGER:
				if animated_sprite_2:
					animated_sprite_2.flip_h = velocity.x < 0

func handle_pterodactyl_states():
	match current_state:
		State.PATROL:
			handle_patrol()
		State.DIVING:
			handle_diving()
		State.RETURNING:
			handle_returning()

func handle_tiger_states():
	match current_state:
		State.PATROL:
			handle_patrol()
		State.CHASE:
			handle_chase()

func handle_patrol():
	# Move towards patrol target
	var direction = (patrol_target - global_position).normalized()
	velocity = direction * patrol_speed

	# Ensure Tiger plays "Walking" animation
	if enemy_type == EnemyType.TIGER and animated_sprite_2:
		animated_sprite_2.stop()  # Reset animation to force playback
		animated_sprite_2.play("Walking")

func handle_diving():
	if not player:
		current_state = State.PATROL
		return
		
	var dive_direction = (target_position - global_position).normalized()
	velocity = dive_direction * dive_speed
	
	if global_position.distance_to(target_position) < 20:
		if animated_sprite:
			animated_sprite.play("Attack")
		current_state = State.RETURNING

func handle_returning():
	var return_target = Vector2(global_position.x, original_height)
	var direction = (return_target - global_position).normalized()
	velocity = direction * patrol_speed
	
	if abs(global_position.y - original_height) < 10:
		current_state = State.PATROL
		if animated_sprite:
			animated_sprite.play("Flying")

func handle_chase():
	if not player:
		current_state = State.PATROL
		return
	
	var chase_direction = (player.global_position - global_position).normalized()
	velocity = chase_direction * chase_speed
	
	if animated_sprite_2:
		animated_sprite_2.play("Attacking")
