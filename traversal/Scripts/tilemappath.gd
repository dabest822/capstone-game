extends Node2D

@onready var path_segments = get_children()
@export var segment_size: float = 200.0
@onready var player = $"/root/Node2D/CharacterBody2D1"
@export var move_speed_multiplier: float = 1.0
@export var viewport_buffer: float = 400.0

var initial_positions: Array = []
var total_height: float = 0.0
var last_scroll_speed: float = 0.0
var current_scroll_speed: Vector2 = Vector2.ZERO

func _ready():
	# Store initial positions and calculate total height
	for segment in path_segments:
		initial_positions.append(segment.position.y)
	total_height = segment_size * path_segments.size()
	
	# Sort segments by Y position
	path_segments.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	# Initialize shader parameters for all segments
	for segment in path_segments:
		if segment.material:
			segment.material.set_shader_parameter("scroll_speed", Vector2.ZERO)
			segment.material.set_shader_parameter("time_multiplier", 1.0)

func _process(_delta):
	if not player:
		return
		
	# Get player's vertical velocity
	var player_velocity = player.velocity.y
	
	# Only update scroll when player is moving
	if abs(player_velocity) > 0.1:  # Small threshold to prevent micro-movements
		var scroll_direction = sign(player_velocity)
		var scroll_speed = abs(player_velocity) / 400.0  # Normalize speed
		
		# Update current scroll speed
		current_scroll_speed = Vector2(0.0, scroll_direction * scroll_speed)
		
		# Update shader parameters
		for segment in path_segments:
			if segment.material:
				segment.material.set_shader_parameter("scroll_speed", current_scroll_speed)
				# Keep time_multiplier constant while moving
				segment.material.set_shader_parameter("time_multiplier", 1.0)
	else:
		# When stopped, keep the last scroll_speed but set time_multiplier to 0
		for segment in path_segments:
			if segment.material:
				segment.material.set_shader_parameter("scroll_speed", current_scroll_speed)
				segment.material.set_shader_parameter("time_multiplier", 0.0)

func find_top_segment() -> Node2D:
	var top = path_segments[0]
	for segment in path_segments:
		if segment.position.y < top.position.y:
			top = segment
	return top

func find_bottom_segment() -> Node2D:
	var bottom = path_segments[0]
	for segment in path_segments:
		if segment.position.y > bottom.position.y:
			bottom = segment
	return bottom

func reset_positions():
	current_scroll_speed = Vector2.ZERO
	for i in path_segments.size():
		path_segments[i].position.y = initial_positions[i]
		if path_segments[i].material:
			path_segments[i].material.set_shader_parameter("scroll_speed", Vector2.ZERO)
			path_segments[i].material.set_shader_parameter("time_multiplier", 1.0)
