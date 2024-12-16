extends Node2D

@onready var pterodactyl = $"../Pterodactyl"  # Adjust path as needed
@onready var tiger = $"../Tiger"  # Adjust path as needed

var viewport_size: Vector2

func _ready():
	viewport_size = get_viewport_rect().size
	
	# Position the pterodactyl in the top third of screen
	if pterodactyl:
		var spawn_x = randf_range(100, viewport_size.x - 100)
		var spawn_y = randf_range(50, viewport_size.y / 3)
		pterodactyl.global_position = Vector2(spawn_x, spawn_y)
