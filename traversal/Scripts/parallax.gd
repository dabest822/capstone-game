extends ParallaxBackground

@export var move_speed: float = 0.2  # Adjust to control path movement speed
@onready var player = $CharacterBody2D1  # Adjust the path to locate your player node

var previous_player_position: Vector2

func _ready():
	# Store the initial player position
	previous_player_position = player.global_position

func _process(_delta):
	# Calculate player's movement direction
	var player_movement = player.global_position - previous_player_position
	previous_player_position = player.global_position

	# Move the path based on the player's movement
	motion_offset += player_movement * move_speed
