extends Node2D  # Or your main player or game script

@onready var shader_material = $AnimatedSprite2D.material  # Update path to your material

func _ready():
	# Set the initial viewport size
	update_viewport_size()
	# Optionally set the light position (e.g., player's position)
	shader_material.set_shader_param("light_position", $AnimatedSprite2D.global_position)

func _process(delta):
	# Dynamically update the light position to follow the player or a specific light source
	shader_material.set_shader_param("light_position", $AnimatedSprite2D.global_position)

func update_viewport_size():
	# Pass the viewport size to the shader
	var viewport_size = get_viewport().get_visible_rect().size
	shader_material.set_shader_param("viewport_size", viewport_size)
