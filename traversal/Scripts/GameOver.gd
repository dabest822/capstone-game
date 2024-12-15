extends Node2D

@onready var game_over_music = $GameOverMusic  # Adjust the path if necessary

func _ready():
	# Play the GameOver music when the scene is loaded
	if game_over_music:
		game_over_music.play()
	else:
		print("GameOverMusic node not found or not set!")
