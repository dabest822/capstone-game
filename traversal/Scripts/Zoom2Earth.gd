extends Camera2D

@onready var earth_shader = $"../Earth".material # Adjust path to your Earth node
var target_position = Vector2(830, 320) # Target position for zoom-in
var target_zoom = Vector2(7, 7) # Target zoom level
var reset_position = Vector2(575, 300) # Initial camera position
var reset_zoom = Vector2(1, 1) # Initial zoom level
var zoom_duration = 3.0 # Duration for the zoom process (in seconds)
var slowing_duration = zoom_duration # Duration for slowing rotation (in seconds)
var zooming = false # To control when zoom starts
var slowing_down = false # To control when the rotation slows down
var zoom_elapsed = 0.0
var slowing_elapsed = 0.0
var rotation_speed_initial = 0.01 # Default initial rotation speed
var rotation_speed_target = 0.0 # Final rotation speed
var rotation_y_angle = 30.0 # Keep track of Earth's rotation in degrees
var scene_to_load = "res://Scenes/PrehistoricEra.tscn" # Path to the scene to load

func _ready():
	# Set the initial camera position and zoom level
	position = reset_position
	zoom = reset_zoom
	# Check if the Earth material exists
	if not earth_shader:
		print("Error: Earth shader material not found!")
	else:
		# Save the initial rotation speed
		rotation_speed_initial = earth_shader.get_shader_parameter("rotation_speed") as float

func _process(delta):
	# Handle the zooming process
	if zooming:
		zoom_elapsed += delta
		var t = zoom_elapsed / zoom_duration # Calculate progress based on duration
		t = clamp(t, 0.0, 1.0) # Ensure t stays between 0 and 1
		
		# Interpolate the zoom level
		var new_zoom = lerp(reset_zoom, target_zoom, t)
		zoom = new_zoom

		# Interpolate the camera position
		var new_position = lerp(reset_position, target_position, t)
		position = new_position

		if zoom_elapsed >= zoom_duration:
			zooming = false  # Stop zooming after duration completes
			check_transition()

	# Handle slowing down the Earth's rotation
	if slowing_down and earth_shader:
		slowing_elapsed += delta
		var t = slowing_elapsed / slowing_duration # Calculate progress based on duration
		t = clamp(t, 0.0, 1.0) # Ensure t stays between 0 and 1
		
		# Calculate the new rotation speed
		var new_speed = rotation_speed_initial * (1.0 - t)
		earth_shader.set_shader_parameter("rotation_speed", new_speed)
		
		# Update Earth's rotation angle consistently
		rotation_y_angle += 360.0 * rotation_speed_initial * delta
		earth_shader.set_shader_parameter("rotate_y", rotation_y_angle)

		if slowing_elapsed >= slowing_duration:
			earth_shader.set_shader_parameter("rotation_speed", rotation_speed_target)
			slowing_down = false  # Stop slowing down after duration completes
			check_transition()

func check_transition():
	# Check if both zooming and slowing down are complete
	if not zooming and not slowing_down:
		# Stop the title music before changing scenes
		var title_theme = get_node("/root/Node2D/TitleTheme")
		if title_theme and title_theme.playing:
			title_theme.stop()
			
		if get_tree() != null:
			get_tree().change_scene_to_file(scene_to_load)
		else:
			print("Error: Unable to access SceneTree.")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Check if the mouse click is on the "Play" button
		var play_button = get_node("../../Play")
		if play_button and play_button.get_global_rect().has_point(event.global_position):
			# Start both zooming and slowing rotation simultaneously
			zooming = true
			zoom_elapsed = 0.0 # Reset zoom timer
			slowing_down = true
			slowing_elapsed = 0.0 # Reset slowdown timer
			focus_on_point(Vector2(830, 320), Vector2(7, 7)) # Target zoom-in parameters
	elif event.is_action_pressed("ui_accept"): # Reset when pressing "Enter"
		reset_view()

func focus_on_point(world_point: Vector2, zoom_level: Vector2):
	target_position = world_point
	target_zoom = zoom_level

func reset_view():
	# Reset camera to the starting position and zoom
	position = reset_position
	zoom = reset_zoom
	zooming = false
	zoom_elapsed = 0.0
	# Reset the Earth rotation speed
	if earth_shader:
		earth_shader.set_shader_parameter("rotation_speed", 0.1)
		earth_shader.set_shader_parameter("rotate_y", 30.0) # Reset rotation angle
		earth_shader.set_shader_parameter("rotation_enabled", true)
		slowing_down = false  # Stop any ongoing slowdown
		slowing_elapsed = 0.0
		rotation_y_angle = 30.0

func start_game():
	# Start both zooming and slowing rotation simultaneously
	zooming = true
	zoom_elapsed = 0.0 # Reset zoom timer
	slowing_down = true
	slowing_elapsed = 0.0 # Reset slowdown timer
	focus_on_point(Vector2(830, 320), Vector2(7, 7)) # Target zoom-in parameters
