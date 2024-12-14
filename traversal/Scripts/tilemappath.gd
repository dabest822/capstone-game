extends Node2D
@onready var path_segments = get_children()  # Automatically fetch all children of this Node2D
@onready var player = $"/root/Node2D/CharacterBody2D1"
@export var segment_size: float = 200.0
@export var move_speed_multiplier: float = 1.0
@export var viewport_buffer: float = 400.0
var initial_positions: Array = []
var total_height: float = 0.0
func _ready():
	# Ensure there are path segments
	if path_segments.is_empty():
		push_warning("No path segments found under the current node!")
		return

	# Store initial positions and calculate total height
	for segment in path_segments:
		initial_positions.append(segment.position.y)
	total_height = segment_size * path_segments.size()
	# Sort segments by Y position
	path_segments.sort_custom(func(a, b): return a.position.y < b.position.y)
	# Initialize shader parameters for segments
	for segment in path_segments:
		if segment.material:
			segment.material.set_shader_parameter("scroll_speed", Vector2(0.0, 0.0))
			segment.material.set_shader_parameter("time_multiplier", 1.0)
func _process(delta):
	if not player or path_segments.is_empty():
		return
	# Get the player's vertical velocity
	var player_velocity = player.velocity.y
	# Only scroll the path when the player is moving
	if abs(player_velocity) > 0.1:
		var scroll_direction = sign(player_velocity)
		var scroll_speed = abs(player_velocity) / 400.0
		# Update only PathSegments children
		for segment in path_segments:
			# Move the segment
			segment.position.y += player_velocity * move_speed_multiplier * delta
			# Update shader scroll speed
			if segment.material:
				segment.material.set_shader_parameter("scroll_speed", Vector2(0.0, scroll_direction * scroll_speed))
			# Get the viewport-relative position
			var relative_pos = segment.global_position.y - get_viewport().get_camera_2d().global_position.y
			# Wrap segments when they go too far off screen
			if player_velocity > 0:  # Moving down
				if relative_pos > get_viewport_rect().size.y + viewport_buffer:
					var top_segment = find_top_segment()
					segment.position.y = top_segment.position.y - segment_size
			elif player_velocity < 0:  # Moving up
				if relative_pos < -viewport_buffer:
					var bottom_segment = find_bottom_segment()
					segment.position.y = bottom_segment.position.y + segment_size
	else:
		# Stop scrolling when player is not moving
		for segment in path_segments:
			if segment.material:
				segment.material.set_shader_parameter("scroll_speed", Vector2(0.0, 0.0))
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
	for i in range(path_segments.size()):
		path_segments[i].position.y = initial_positions[i]
		if path_segments[i].material:
			path_segments[i].material.set_shader_parameter("scroll_speed", Vector2(0.0, 0.0))
