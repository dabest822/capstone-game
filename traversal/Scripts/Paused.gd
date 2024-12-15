extends CanvasLayer

@onready var overlay = $Panel/Transparency
@onready var menu_container = $Panel/MenuContainer
@onready var continue_button = $Panel/Continue
@onready var volume_label = $Panel/Volume
@onready var volume_bar = $Panel/VolumeBar
@onready var options_button = $Panel/MenuContainer/Options
@onready var hourglass = $Panel/SpinningHourglass
@onready var select_arrow = $Panel/SelectArrow
var selected_index = 0
var menu_items = []
var item_spacing = 80
var scroll_tween: Tween
var initial_menu_position: Vector2
var initial_continue_position: Vector2
var initial_volume_label_position: Vector2
var initial_volume_bar_position: Vector2
var is_paused = true

func _ready():
	hide()
	set_process(false)
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("PauseMenu initialized - Process mode set to ALWAYS")
	visibility_changed.connect(_on_visibility_changed)
	
	if overlay:
		overlay.color = Color(0, 0, 0, 0.5)
		overlay.size = Vector2(1136, 632)
	
	initial_menu_position = menu_container.position
	initial_continue_position = continue_button.position
	initial_volume_label_position = volume_label.position
	initial_volume_bar_position = volume_bar.position
	var current_db = AudioServer.get_bus_volume_db(0)
	var current_volume = db_to_linear(current_db) * 100
	volume_bar.value = current_volume
	
	# Create menu items array without Volume label
	menu_items = []
	menu_items.push_back(continue_button)
	menu_items.push_back(volume_bar)        # Now second item
	menu_items.push_back(options_button)    # Now third item
	
	# Set initial colors/opacity
	for i in range(menu_items.size()):
		var item = menu_items[i]
		if item == options_button:
			item.modulate = Color(1, 1, 1, 1)  # Just set the color directly
	
	# Keep Volume label always white
	volume_label.modulate = Color(1, 1, 1, 1)

func _unhandled_input(event):
	# Only handle menu navigation and options
	if event.is_action_pressed("pause"):
		print("Escape pressed in PauseMenu")
		GlobalSettings.toggle_pause()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("ui_down"):
		select_next_item()
	elif Input.is_action_just_pressed("ui_up"):
		select_previous_item()
	elif Input.is_action_just_pressed("ui_accept"):
		if selected_index == 2:  # Options is now index 2 instead of 3
			hide()
			set_process(false)
			get_tree().paused = false
			get_tree().change_scene_to_file("res://Scenes/Options.tscn")
	elif Input.is_action_just_pressed("returntogame"):
		GlobalSettings.toggle_pause()
	# Volume control when Volume or VolumeBar is selected
	if selected_index == 1:  # VolumeBar is now index 1
		if Input.is_action_pressed("ui_right"):
			volume_bar.value += 1
			update_volume()
		elif Input.is_action_pressed("ui_left"):
			volume_bar.value -= 1
			update_volume()

func update_volume():
	var volume_db = linear_to_db(volume_bar.value / 100.0)
	AudioServer.set_bus_volume_db(0, volume_db)

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
	var continue_target_pos = initial_continue_position.y - selected_index * item_spacing
	var volume_label_target_pos = initial_volume_label_position.y - selected_index * item_spacing
	var volume_bar_target_pos = initial_volume_bar_position.y - selected_index * item_spacing
	
	# Tween all positions
	scroll_tween.tween_property(menu_container, "position:y", target_pos, 0.3)
	scroll_tween.parallel().tween_property(continue_button, "position:y", continue_target_pos, 0.3)
	scroll_tween.parallel().tween_property(volume_label, "position:y", volume_label_target_pos, 0.3)
	scroll_tween.parallel().tween_property(volume_bar, "position:y", volume_bar_target_pos, 0.3)
	
# Update colors/transparency for each item based on type
	for i in range(menu_items.size()):
		var item = menu_items[i]
		if item == options_button:
			# For Volume label and Options, change color
			var target_color = Color(0, 0.8, 0.8, 1) if i == selected_index else Color(1, 1, 1, 1)
			scroll_tween.parallel().tween_property(item, "modulate", target_color, 0.3)
		else:
			# For other items (Continue button, volume bar), use opacity
			var target_alpha = 1.0 if i == selected_index else 0.5
			scroll_tween.parallel().tween_property(item, "modulate:a", target_alpha, 0.3)
			
	# Update the arrow position
	_update_arrow_position()
	
	# Update volume bar grabber color
	if volume_bar:
		var grabber_style = StyleBoxFlat.new()
		grabber_style.bg_color = Color(0, 0.8, 0.8, 1) if selected_index == 1 else Color(1, 1, 1, 1)
		volume_bar.add_theme_stylebox_override("grabber_area", grabber_style)
		volume_bar.add_theme_stylebox_override("grabber_area_highlight", grabber_style)

func return_to_previous_scene():
	GlobalSettings.toggle_pause()  # Use toggle_pause instead of unpause_game

func restore_volume():
	var previous_volume_db = GlobalSettings.previous_volume
	AudioServer.set_bus_volume_db(0, previous_volume_db)
	print("Restored volume to: ", previous_volume_db)

func unpause_game():
	if is_paused:
		is_paused = false
		var pause_menu = get_node("/root/PauseMenu")
		if pause_menu:
			pause_menu.hide()
			get_tree().paused = false
			print("Game unpaused")

func _on_visibility_changed():
	if visible:  # Menu just became visible
		selected_index = 0
		scroll_to_selected()
		if hourglass:
			hourglass.play("default")
	else:  # Menu is being hidden
		if hourglass:
			hourglass.stop()

func _update_arrow_position():
	# Manually set positions for the arrow for each menu item
	match selected_index:
		0:  # Continue button
			select_arrow.global_position = Vector2(341, 317)  # Set X and Y for Continue
		1:  # VolumeBar
			select_arrow.global_position = Vector2(420, 330)  # Set X and Y for Volume
		2:  # Options button
			select_arrow.global_position = Vector2(415, 365)  # Set X and Y for Options
