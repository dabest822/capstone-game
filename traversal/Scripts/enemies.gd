extends CharacterBody2D

enum State {PATROL, DIVING, RETURNING}

@export var patrol_speed: float = 150.0
@export var dive_speed: float = 300.0
@export var detection_range: float = 300.0

var current_state = State.PATROL
var patrol_point_a: Vector2
var patrol_point_b: Vector2
var patrol_target: Vector2
var original_height: float
var target_position: Vector2
var player: Node2D = null

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_area = $Area2D

func _ready():
	# Initialize patrol points
	original_height = global_position.y
	patrol_point_a = global_position + Vector2(-200, 0)
	patrol_point_b = global_position + Vector2(200, 0)
	patrol_target = patrol_point_b
	
	if animated_sprite:
		animated_sprite.play("Flying")
	
	find_player()

func find_player():
	# Try different possible paths to find the player
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
	match current_state:
		State.PATROL:
			handle_patrol()
		State.DIVING:
			handle_diving()
		State.RETURNING:
			handle_returning()
	
	move_and_slide()
	
	# Update sprite direction
	if velocity.x != 0 and animated_sprite:
		animated_sprite.flip_h = velocity.x < 0

func handle_patrol():
	# Move towards patrol target
	var direction = (patrol_target - global_position).normalized()
	velocity = direction * patrol_speed
	
	# Switch patrol points when reached
	if global_position.distance_to(patrol_target) < 10:
		patrol_target = patrol_point_a if patrol_target == patrol_point_b else patrol_point_b
	
	# Check for player to initiate dive
	if player and global_position.distance_to(player.global_position) < detection_range:
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
