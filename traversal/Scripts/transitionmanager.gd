extends Node

var is_transitioning = false
var shader_node: CanvasLayer = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func transition_to_scene(next_scene_path: String) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Find shader in current scene
	shader_node = get_tree().get_first_node_in_group("shader_display")
	if shader_node:
		shader_node.visible = true
		var color_rect = shader_node.get_node_or_null("ColorRect")
		if color_rect:
			color_rect.visible = true
	
	# Hide necessary nodes
	var player = get_tree().get_first_node_in_group("player")
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	
	if player:
		player.hide()
	if tilemap:
		tilemap.hide()
	
	# Transition delay (adjust time as necessary)
	await get_tree().create_timer(5.0).timeout
	
	if get_tree():
		get_tree().change_scene_to_file(next_scene_path)
		
		# Ensure the shader is hidden after the transition
		if shader_node:
			shader_node.visible = false
			var color_rect = shader_node.get_node_or_null("ColorRect")
			if color_rect:
				color_rect.visible = false
		
		is_transitioning = false
