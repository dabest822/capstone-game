extends Control

@onready var intro_music = $AudioStreamPlayer  # Reference to the AudioStreamPlayer

@export var title_screen_path: String = "res://Scenes/titlescreen.tscn"  # Path to the Title Screen

func _ready():
	print("Splash screen is running...")
	
	# Play the intro music if it's set
	if intro_music:
		print("Playing intro music...")
		intro_music.play()
	
	# Play the "Intro" animation and queue "FadeOut"
	if $AnimationPlayer.has_animation("Intro"):
		print("Playing Intro animation...")
		$AnimationPlayer.play("Intro")
		$AnimationPlayer.queue("FadeOut")
	else:
		print("Intro animation not found!")
	
# This method is called when an animation finishes playing
func _on_animation_player_animation_finished(_anim_name):
	print("Animation finished: ", _anim_name)
	if _anim_name == "FadeOut":  # Check if "FadeOut" animation finished
		print("Switching to Title Screen...")
		
		# Stop the intro music
		if intro_music:
			intro_music.stop()
		
		# Switch to the Title Screen
		get_tree().change_scene_to_file(title_screen_path)
