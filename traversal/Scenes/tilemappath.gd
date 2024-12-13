extends Sprite2D

@export var move_speed: float = 100.0  # Speed of conveyor belt (pixels per second)

func _process(delta):
	# Move the sprite continuously in the Y direction
	position.y += move_speed * delta

	# Wrap-around logic to loop the sprite (if texture repeats)
	if position.y > texture.get_height():
		position.y -= texture.get_height()
	elif position.y < -texture.get_height():
		position.y += texture.get_height()
