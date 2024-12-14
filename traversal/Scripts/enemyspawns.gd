extends Node2D

# Preload enemy scenes
@export var pterodactyl_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_enemies: int = 3

var viewport_size: Vector2
var spawn_timer: Timer

func _ready():
	viewport_size = get_viewport_rect().size
	
	# Set up spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		spawn_pterodactyl()

func get_random_spawn_position() -> Vector2:
	# Spawn in top third of screen
	var x = randf_range(100, viewport_size.x - 100)
	var y = randf_range(50, viewport_size.y / 3)
	return Vector2(x, y)

func spawn_pterodactyl():
	var pterodactyl = pterodactyl_scene.instantiate()
	add_child(pterodactyl)
	pterodactyl.add_to_group("enemies")
	
	# Set initial position
	var spawn_pos = get_random_spawn_position()
	pterodactyl.global_position = spawn_pos
