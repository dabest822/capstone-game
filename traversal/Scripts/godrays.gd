extends ColorRect

func _ready():
	# Flip horizontally
	scale.x = -1
	# Adjust position to compensate for flip
	position.x += size.x
