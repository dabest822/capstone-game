extends AnimatedSprite2D

@onready var portal_area = $"../Area2DPortal"
@onready var shader_display = $"../../ShaderDisplay"
@onready var traveling_sound = $"../Traveling"
var is_transitioning: bool = false
var player_in_portal: bool = false

func _ready():
	setup_portal()
	setup_glow()
	setup_aura()
	setup_particles()
	setup_light()
	
	portal_area.body_entered.connect(_on_player_entered)
	portal_area.body_exited.connect(_on_player_exited)

func get_next_scene() -> String:
	var current_scene = get_tree().current_scene.scene_file_path
	
	match current_scene:
		"res://Scenes/PrehistoricEra.tscn":
			return "res://Scenes/ComingSoon.tscn"
		_:  # Default case for other scenes
			return "res://Scenes/PrehistoricEra.tscn"

func _on_player_entered(body):
	# Check if it's specifically the player (not enemies)
	if body.name == "CharacterBody2D1" and !is_transitioning:
		player_in_portal = true
		print("Player entered portal area")
		trigger_transition()

func _on_player_exited(body):
	if body.name == "CharacterBody2D1":
		player_in_portal = false
		print("Player exited portal area")

func trigger_transition():
	if is_transitioning:
		return
	
	is_transitioning = true
	print("Making shader visible")
	
	# Stop StoneAgeTheme music
	var stone_age_theme = get_node_or_null("../../StoneAgeTheme")
	if stone_age_theme and stone_age_theme.is_playing():
		print("Stopping StoneAgeTheme music...")
		stone_age_theme.stop()
	
	# Stop Roar sound effect
	var roar_sound = get_node_or_null("../../Roar")
	if roar_sound and roar_sound.is_playing():
		print("Stopping Roar sound effect...")
		roar_sound.stop()
	
	# Play Traveling sound effect
	if traveling_sound:
		print("Playing Traveling sound effect...")
		traveling_sound.play()
	
	# Hide MainGUI CanvasLayer
	var main_gui = get_node_or_null("../../MainGUI")
	if main_gui:
		print("Hiding MainGUI...")
		main_gui.hide()
	
	# Remove or hide the Tiger node
	var tiger_node = get_node_or_null("../../Tiger")
	if tiger_node:
		print("Removing Tiger node and its children...")
		tiger_node.queue_free()  # Remove the Tiger node entirely
	
	# Start transition shader
	if shader_display:
		shader_display.start_transition()
	
	print("Hiding player and map")
	var nodes_to_hide = [
		get_node_or_null("../../CharacterBody2D"),
		get_node_or_null("../../TileMapLayer"),
	]
	
	for node in nodes_to_hide:
		if node:
			node.hide()
	
	# Set up transition timer
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 4.0
	timer.timeout.connect(_on_transition_complete)
	timer.start()

func _on_transition_complete():
	print("Timer completed, changing scene...")
	if not is_inside_tree():
		return
	
	var next_scene = get_next_scene()
	print("Loading scene: ", next_scene)
	
	if get_tree():
		var err = get_tree().change_scene_to_file(next_scene)
		if err != OK:
			print("Error loading scene: ", err)
		is_transitioning = false

# Visual Effects Setup
func setup_portal():
	rotation_degrees = 90
	scale = Vector2(3, 1.5)
	play("portalidle")
	
	var border = Sprite2D.new()
	border.texture = sprite_frames.get_frame_texture("portalidle", 0)
	border.z_index = -1
	border.modulate = Color(0, 0, 0, 0.8)
	border.scale = Vector2(1.2, 1.2)
	add_child(border)

func setup_glow():
	var glow = Sprite2D.new()
	glow.z_index = -2
	glow.modulate = Color(0, 0.7, 1.0, 0.3)
	glow.scale = Vector2(4.5, 4.5)
	add_child(glow)
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow, "modulate:a", 0.1, 2.0)
	tween.tween_property(glow, "modulate:a", 0.3, 2.0)

func setup_aura():
	var aura = Sprite2D.new()
	aura.z_index = -3
	aura.modulate = Color(0.5, 0, 1.0, 0.2)
	aura.scale = Vector2(6.0, 6.0)
	add_child(aura)
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(aura, "rotation_degrees", 360.0, 8.0)

func setup_particles():
	var particles = GPUParticles2D.new()
	var particle_material = ParticleProcessMaterial.new()
	
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 60.0
	particle_material.particle_flag_disable_z = true
	particle_material.direction = Vector3(0, -1, 0)
	particle_material.spread = 360.0
	particle_material.initial_velocity_min = 15.0
	particle_material.initial_velocity_max = 45.0
	particle_material.gravity = Vector3(0, 0, 0)
	
	particle_material.color = Color(0, 0.7, 1.0, 1)  # Blue color
	
	particles.process_material = particle_material
	particles.amount = 30
	particles.lifetime = 1.0
	add_child(particles)

func setup_light():
	var light = PointLight2D.new()
	
	light.energy = 2.0
	light.range_layer_min = -1
	light.range_layer_max = 1
	light.color = Color(0, 0.7, 1.0, 1)
	light.shadow_enabled = true
	light.texture_scale = 6.0
	
	var texture = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.colors = [Color(1, 1, 1, 1), Color(0, 0, 0, 0)]
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.width = 256
	texture.height = 256
	light.texture = texture
	
	add_child(light)
