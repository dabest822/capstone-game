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

@onready var animated_sprite = $"AnimatedSprite2D" if enemy_type == EnemyType.PTERODACTYL else null
@onready var animated_sprite_2 = $"AnimatedSprite2D2" if enemy_type == EnemyType.TIGER else null
@onready var collision_area = $Area2D

func _ready():
	# Initialize patrol points
	original_height = global_position.y
	patrol_point_a = global_position + Vector2(-patrol_distance, 0)
	patrol_point_b = global_position + Vector2(patrol_distance, 0)
	patrol_target = patrol_point_b
	
	# Set up initial animations
	match enemy_type:
		EnemyType.PTERODACTYL:
			if animated_sprite:
				animated_sprite.play("Flying")
		EnemyType.TIGER:
			if animated_sprite_2:
				animated_sprite_2.play("Walking")
	
	find_player()
	
	# Set up chase area for tiger
	if enemy_type == EnemyType.TIGER:
		setup_chase_area()

func setup_chase_area():
	chase_area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = detection_range
	shape.shape = circle
	chase_area.add_child(shape)
	add_child(chase_area)
	chase_area.body_entered.connect(_on_chase_area_entered)
	chase_area.body_exited.connect(_on_chase_area_exited)

func _on_chase_area_entered(body):
	if enemy_type == EnemyType.TIGER and body == player:
		current_state = State.CHASE
		animated_sprite_2.play("Attacking")  # Changed from animated_sprite

func _on_chase_area_exited(body):
	if enemy_type == EnemyType.TIGER and body == player:
		current_state = State.PATROL
		animated_sprite_2.play("Walking")    # Changed from animated_sprite

func find_player():
	var possible_paths = [
		"../CharacterBody2D1",
		"../../CharacterBody2D1",
		"/root/Node2D/CharacterBody2D1"
	]
	
	for path in possible_paths:
		player = get_node_or_null(path)
		if player:
			return

func _physics_process(delta):
	match enemy_type:
		EnemyType.PTERODACTYL:
			handle_pterodactyl_states()
		EnemyType.TIGER:
			handle_tiger_states()
	
	move_and_slide()
	
	# Update sprite direction
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
	
	# Switch patrol points when reached
	if global_position.distance_to(patrol_target) < 10:
		patrol_target = patrol_point_a if patrol_target == patrol_point_b else patrol_point_b
	
	# Check for player to initiate dive (pterodactyl only)
	if enemy_type == EnemyType.PTERODACTYL and player and global_position.distance_to(player.global_position) < detection_range:
		current_state = State.DIVING
		if animated_sprite:
			animated_sprite.play("FastFlying")
		target_position = player.global_position

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
	
	# Move towards player
	var chase_direction = (player.global_position - global_position).normalized()
	velocity = chase_direction * chase_speed

func play_animation(anim_name: String):
	match enemy_type:
		EnemyType.PTERODACTYL:
			if animated_sprite:
				animated_sprite.play(anim_name)
		EnemyType.TIGER:
			if animated_sprite_2:
				animated_sprite_2.play(anim_name)
