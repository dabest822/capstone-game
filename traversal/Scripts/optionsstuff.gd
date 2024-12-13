extends Control

@onready var back_button = $Back
@onready var volume_slider = $Music
@onready var fullscreen_sprite = $CheckMark
@onready var fullscreen_button = $CheckMark/CheckMarkBG/FullscreenButton
@onready var resolution_menu = $ResolutionMenu
@onready var custom_font = preload("res://Fonts/Cubic_11_1.013_R.ttf")

var is_fullscreen = false
var previous_window_state = false
var debug_timer = 0.0  # Timer to track debug message intervals
var debug_interval = 5.0  # Interval in seconds for debug messages

func _ready():
	if back_button:
		style_back_button(back_button)
	configure_volume_slider(volume_slider)
	configure_arrow(resolution_menu)
	if resolution_menu:
		resolution_menu.item_selected.connect(_on_resolution_selected)
	configure_fullscreen()
	update_fullscreen_state()  # Ensure the check mark matches the fullscreen state on startup
	set_process(true)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _process(delta):
	debug_timer += delta
	var current_state = is_window_maximized()
	
	# Only update if the state has changed
	if current_state != previous_window_state:
		previous_window_state = current_state
		is_fullscreen = current_state
		
		if is_fullscreen:
			fullscreen_sprite.play("Checked")
			await fullscreen_sprite.animation_finished
			fullscreen_sprite.play("CheckedIdle")
		else:
			fullscreen_sprite.play("Unchecked")
			await fullscreen_sprite.animation_finished
			fullscreen_sprite.play("UncheckedIdle")
			
			# Print debug info every 5 seconds
	if debug_timer >= debug_interval:
		print("Current window mode:", DisplayServer.window_get_mode())
		debug_timer = 0.0  # Reset timer

func is_window_maximized() -> bool:
	var window_mode = DisplayServer.window_get_mode()
	return window_mode in [
		DisplayServer.WINDOW_MODE_MAXIMIZED,
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	]

func update_fullscreen_state():
	# Check if window is either in fullscreen mode or maximized
	var current_state = is_window_maximized()
	
	print("Current window state:", current_state)
	
	# Only update if the state has changed
	if current_state != previous_window_state:
		print("State changed from", previous_window_state, "to", current_state)
		previous_window_state = current_state
		is_fullscreen = current_state
		
		if is_fullscreen:
			print("Setting to checked idle")
			fullscreen_sprite.play("CheckedIdle")
		else:
			print("Setting to unchecked idle")
			fullscreen_sprite.play("UncheckedIdle")

func _on_resolution_selected(index):
	if resolution_menu:
		print("Option selected:", index)
		var resolutions = [
			Vector2(1920, 1080),
			Vector2(1280, 720),
			Vector2(800, 600)
		]
		var selected_resolution = resolutions[index]
		DisplayServer.window_set_size(selected_resolution)
		print("Resolution changed to:", selected_resolution)
		
		# Update the resolution menu text to match the new resolution
		resolution_menu.text = str(selected_resolution.x) + "x" + str(selected_resolution.y)
		
		# Hide the arrow icon by using an empty texture
		var empty_texture = ImageTexture.new()
		resolution_menu.add_theme_icon_override("arrow", empty_texture)
		print("Arrow icon removed!")

func configure_arrow(option_button):
	if option_button:
		var arrow_texture = preload("res://Sprites/Arrow.png")
		var arrow_image = arrow_texture.get_image()
		arrow_image.resize(75, 75)
		var scaled_arrow_texture = ImageTexture.create_from_image(arrow_image)
		option_button.add_theme_icon_override("arrow", scaled_arrow_texture)
		print("Arrow icon added to the OptionButton!")

func style_back_button(button):
	var empty_stylebox = StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty_stylebox)
	button.add_theme_stylebox_override("hover", empty_stylebox)
	button.add_theme_stylebox_override("pressed", empty_stylebox)
	button.add_theme_stylebox_override("disabled", empty_stylebox)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(0, 0.8, 0.8, 1))
	button.add_theme_color_override("font_pressed_color", Color(0, 0.9, 0.7, 1))

func configure_volume_slider(slider):
	if slider:
		slider.min_value = 0
		slider.max_value = 100
		slider.value = 50
		slider.step = 1
		
		# Style for the background track
		var slider_bg = StyleBoxFlat.new()
		slider_bg.bg_color = Color(0.5, 0.5, 0.5, 1)  # Light gray for the track
		slider_bg.set_content_margin_all(4)  # This replaces height
		
		# Style for the grabber (the part you drag)
		var grabber_style = StyleBoxFlat.new()
		grabber_style.bg_color = Color(1, 1, 1, 1)  # White for the grabber
		grabber_style.set_content_margin_all(8)  # This replaces height
		
		# Style for the filled part of the slider
		var filled_style = StyleBoxFlat.new()
		filled_style.bg_color = Color(0.8, 0.8, 0.8, 1)  # Lighter gray for the filled part
		filled_style.set_content_margin_all(4)  # This replaces height
		
		# Apply the styles
		slider.add_theme_stylebox_override("slider", slider_bg)  # Background track
		slider.add_theme_stylebox_override("grabber_area", filled_style)  # Filled part
		slider.add_theme_stylebox_override("grabber_area_highlight", filled_style)  # Filled part when highlighted
		
		slider.custom_minimum_size = Vector2(200, 20)  # Width and height of entire slider
		slider.value_changed.connect(_on_volume_changed)

func configure_fullscreen():
	if fullscreen_sprite:
		fullscreen_sprite.play("UncheckedIdle")
	
	if fullscreen_button:
		var empty_style = StyleBoxEmpty.new()
		fullscreen_button.add_theme_stylebox_override("normal", empty_style)
		fullscreen_button.add_theme_stylebox_override("hover", empty_style)
		fullscreen_button.add_theme_stylebox_override("pressed", empty_style)
		fullscreen_button.custom_minimum_size = Vector2(45, 43)
		fullscreen_button.pressed.connect(toggle_fullscreen)

func toggle_fullscreen():
	print("Toggling fullscreen")
	is_fullscreen = !is_fullscreen
	
	if is_fullscreen:
		print("Switching to fullscreen")
		fullscreen_sprite.play("Checked")
		await fullscreen_sprite.animation_finished
		fullscreen_sprite.play("CheckedIdle")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		print("Switching to windowed")
		fullscreen_sprite.play("Unchecked")
		await fullscreen_sprite.animation_finished
		fullscreen_sprite.play("UncheckedIdle")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_changed(value):
	print("Volume changed to:", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_back_pressed():
	print("Back button pressed. Returning to titlescreen...")
	get_tree().change_scene_to_file("res://Scenes/titlescreen.tscn")
