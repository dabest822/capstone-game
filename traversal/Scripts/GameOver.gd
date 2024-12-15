extends Node2D

@onready var game_over_music = $GameOverMusic
@onready var retry_button = $Retry
@onready var return_title_button = $ReturnToTitle
@onready var select_arrow = $SelectArrow  # Reference to the arrow node
@onready var delorean = $Delorean        # Reference to the AnimatedSprite2D

var selected_index = 0
var menu_items = []
var item_spacing = 80
var scroll_tween: Tween
var initial_retry_position: Vector2
var initial_return_position: Vector2

# Delorean driving variables
var delorean_speed = 300.0  # Pixels per second
var is_driving_left = false

# Manually set positions
var delorean_start_position = Vector2(68, 625)  # Starting position off-screen to the left
var delorean_left_edge = -100                    # Left boundary
var delorean_right_edge = 1250                   # Right boundary (adjust this to match your screen width)

func _ready():
	# Play game over music
	if game_over_music:
		game_over_music.play()
	else:
		print("GameOverMusic node not found or not set!")
	
	# Store initial positions
	initial_retry_position = retry_button.position
	initial_return_position = return_title_button.position
	
	# Set up menu items in correct order
	menu_items = []
	menu_items.push_back(return_title_button)  # Return to Title first
	menu_items.push_back(retry_button)         # Retry second
	
	# Set initial transparency and arrow position
	for i in range(menu_items.size()):
		var item = menu_items[i]
		item.modulate.a = 1.0 if i == selected_index else 0.5
	
	_update_arrow_position()

	# Initialize Delorean position and start driving + floating
	if delorean:
		delorean.global_position = delorean_start_position  # Set manual starting position
		delorean.flip_h = false
		delorean.play("Drive")
		_float_delorean()  # Start floating immediately
		move_delorean()    # Start moving across the screen

func _unhandled_input(event):
	# Menu navigation (fixed direction)
	if Input.is_action_just_pressed("ui_down"):
		select_next_item()
	elif Input.is_action_just_pressed("ui_up"):
		select_previous_item()
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection()

func move_delorean():
	# Tween for driving Delorean across the screen
	var tween = create_tween()
	var target_position = Vector2()

	if is_driving_left:
		target_position = Vector2(delorean_left_edge, delorean.global_position.y)
	else:
		target_position = Vector2(delorean_right_edge, delorean.global_position.y)

	tween.tween_property(delorean, "global_position", target_position, abs(target_position.x - delorean.global_position.x) / delorean_speed)
	tween.tween_callback(func():
		# Flip direction and continue
		is_driving_left = !is_driving_left
		delorean.flip_h = !delorean.flip_h

		# Immediately play Idle animation and start floating
		delorean.play("Idle")
		if not delorean.is_connected("animation_finished", _float_delorean):
			_float_delorean()  # Start floating instantly
		move_delorean()  # Restart the movement loop
	)

func _float_delorean():
	# Fixed baseline position for floating
	var base_y = delorean_start_position.y  # Use the manual Y-coordinate as a baseline

	# Continuous floating effect independent of driving
	var float_tween = create_tween()
	float_tween.set_loops()  # Infinite looping for continuous floating
	float_tween.set_trans(Tween.TRANS_SINE)  # Smooth sinusoidal movement
	
	# Tween relative to the baseline position
	float_tween.tween_property(delorean, "position:y", base_y - 25, 0.5)


func select_next_item():
	if selected_index < menu_items.size() - 1:
		selected_index += 1
		scroll_to_selected()

func select_previous_item():
	if selected_index > 0:
		selected_index -= 1
		scroll_to_selected()

func scroll_to_selected():
	if scroll_tween:
		scroll_tween.kill()
	
	scroll_tween = create_tween()
	scroll_tween.set_trans(Tween.TRANS_CUBIC)
	scroll_tween.set_ease(Tween.EASE_OUT)
	
	# Calculate target positions
	var retry_target_pos = initial_retry_position.y - selected_index * item_spacing
	var return_target_pos = initial_return_position.y - selected_index * item_spacing
	
	# Tween positions
	scroll_tween.tween_property(retry_button, "position:y", retry_target_pos, 0.3)
	scroll_tween.parallel().tween_property(return_title_button, "position:y", return_target_pos, 0.3)
	
	# Tween transparency
	for i in range(menu_items.size()):
		var item = menu_items[i]
		var target_alpha = 1.0 if i == selected_index else 0.5
		scroll_tween.parallel().tween_property(item, "modulate:a", target_alpha, 0.3)
	
	# Update the arrow position
	_update_arrow_position()

func _update_arrow_position():
	# Manually set positions for the arrow for each menu item
	match selected_index:
		0:  # Return to Title
			select_arrow.global_position = Vector2(415, 409)
		1:  # Retry
			select_arrow.global_position = Vector2(430, 425)

func handle_selection():
	match selected_index:
		0:  # Return to Title
			get_tree().change_scene_to_file("res://Scenes/titlescreen.tscn")
		1:  # Retry
			get_tree().reload_current_scene()
