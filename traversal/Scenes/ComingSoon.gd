extends Node2D

@onready var hourglass = $Hourglass
@onready var select_arrow = $SelectArrow
@onready var quit_button = $TheMenu/Quit  # Inside container
@onready var return_to_title_button = $ReturnToTitle  # Outside container
@onready var menu_container = $TheMenu
@onready var demo_end_music = $DemoEndMusic
var selected_index = 0
var menu_items = []
var item_spacing = 80
var scroll_tween: Tween
var initial_menu_position: Vector2
var initial_quit_position: Vector2
var initial_return_position: Vector2

func _ready():
	if demo_end_music:
		demo_end_music.play()
	else:
		print("DemoEndMusic node not found or not set!")
	
	if hourglass:
		hourglass.play("Sand")
	
	initial_menu_position = menu_container.position
	initial_quit_position = quit_button.position
	initial_return_position = return_to_title_button.position
	
	# Add buttons to menu_items in order
	menu_items = []
	menu_items.push_back(quit_button)
	menu_items.push_back(return_to_title_button)
	
	# Set initial states
	for i in range(menu_items.size()):
		var item = menu_items[i]
		
	_update_arrow_position()  # Add this

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_down"):
		select_next_item()
	elif Input.is_action_just_pressed("ui_up"):
		select_previous_item()
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection()

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
	var target_pos = initial_menu_position.y - selected_index * item_spacing
	var quit_target_pos = initial_quit_position.y - selected_index * item_spacing
	var return_target_pos = initial_return_position.y - selected_index * item_spacing
	
	# Tween all positions
	scroll_tween.tween_property(menu_container, "position:y", target_pos, 0.3)
	scroll_tween.parallel().tween_property(return_to_title_button, "position:y", return_target_pos, 0.3)
	
	# Update colors/transparency and scale for menu items
	for i in range(menu_items.size()):
		var item = menu_items[i]
		var is_selected = (i == selected_index)
		
		# Set z-index for layering
		item.z_index = 1 if is_selected else 0
		
		if item == quit_button:
			# Scale effect for menu items
			var target_scale = Vector2(1.2, 1.2) if is_selected else Vector2(0.8, 0.8)
			var target_alpha = 1.0 if is_selected else 0.5
			scroll_tween.parallel().tween_property(item, "scale", target_scale, 0.3)
		else:
			# For ReturnToTitle, use opacity only
			var target_alpha = 1.0 if is_selected else 0.5
			scroll_tween.parallel().tween_property(item, "modulate:a", target_alpha, 0.3)
			
	_update_arrow_position()  # Add this

func handle_selection():
	match selected_index:
		0:  # Quit button
			print("Quitting game...")
			get_tree().quit()
		1:  # Return to Title button
			print("Returning to Title Screen...")
			get_tree().change_scene_to_file("res://Scenes/titlescreen.tscn")

func _update_arrow_position():
	match selected_index:
		0:  # Quit button position
			select_arrow.position = Vector2(427, 349)  # Change these coordinates
			print("Arrow moved to Quit position")  # Debug print
		1:  # Return to Title button position
			select_arrow.position = Vector2(415, 377)  # Change these coordinates
			print("Arrow moved to Return position")  # Debug print
