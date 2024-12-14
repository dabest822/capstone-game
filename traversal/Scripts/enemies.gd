extends CharacterBody2D

@export var detection_range: float = 300.0

# Health system
var max_health: int = 75
var current_health: int = max_health

# Movement and AI states
enum State {PATROL, DIVING, RETURNING}
var current_state = State.PATROL
var patrol_point_a: Vector2
var patrol_point_b: Vector2
var patrol_target: Vector2
var original_height: float
var target_position: Vector2
var player: Node2D = null

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_area = $Area2D

func _ready():
	# Set up collision detection
	collision_area.add_to_group("enemy_attack")
	collision_area.add_to_group("enemy_hurt_box")
	collision_area.body_entered.connect(_on_area_body_entered)
	collision_area.area_entered.connect(_on_area_area_entered)
	
	# Initialize patrol points
	original_height = global_position.y
	patrol_point_a = global_position + Vector2(-200, 0)
	patrol_point_b = global_position + Vector2(200, 0)
	patrol_target = patrol_point_b
	
	if animated_sprite:
		animated_sprite.play("Flying")
	
	# Connect to the tree_changed signal to update player reference
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	if node.name == "CharacterBody2D1":
		player = node
		print("Found player node!")

func find_player():
	# Try different possible paths to find the player
	var possible_paths = [
		"../CharacterBody2D1",
		"../../CharacterBody2D1",
		"/root/Node2D/CharacterBody2D1",
		"CharacterBody2D1"
	]
	
	for path in possible_paths:
		var found_player = get_node_or_null(path)
		if found_player:
			player = found_player
			print("Found player at path: ", path)
			return true
	
	return false

func _physics_process(_delta):
	# Try to find player if we don't have a reference
	if !player and !find_player():
		return
		
	match current_state:
		State.PATROL:
			handle_patrol()
		State.DIVING:
			handle_diving()
		State.RETURNING:
			handle_returning()
	
	# Update sprite direction
	if velocity.x != 0 and animated_sprite:
		animated_sprite.flip_h = velocity.x < 0

func handle_patrol():
	# Move towards patrol target
	var direction = (patrol_target - global_position).normalized()
	velocity = direction * 150.0
	
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
	if !player:
		current_state = State.PATROL
		return
		
	var dive_direction = (target_position - global_position).normalized()
	velocity = dive_direction * 300.0
	
	if global_position.distance_to(target_position) < 20:
		if animated_sprite:
			animated_sprite.play("Attack")
		current_state = State.RETURNING

func handle_returning():
	var return_target = Vector2(global_position.x, original_height)
	var direction = (return_target - global_position).normalized()
	velocity = direction * 150.0
	
	if abs(global_position.y - original_height) < 10:
		current_state = State.PATROL
		if animated_sprite:
			animated_sprite.play("Flying")

func take_damage(amount):
	current_health = max(0, current_health - amount)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	
	if current_health <= 0:
		die()

func die():
	queue_free()

func _on_area_body_entered(body):
	if body.name == "CharacterBody2D1" and body.has_method("take_damage"):
		body.take_damage(10)

func _on_area_area_entered(other_area):
	if other_area.name == "PlayerAttackArea":
		take_damage(20)
