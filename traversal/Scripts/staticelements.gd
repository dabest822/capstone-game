extends CanvasLayer

@onready var right_wall = $RightWall
@onready var left_wall = $LeftWall

var right_transform: Transform2D
var left_transform: Transform2D

func _ready():
	# Save the initial transforms
	right_transform = right_wall.transform
	left_transform = left_wall.transform

func _process(_delta):
	# Lock the x translation in the transform
	right_wall.transform.origin.x = right_transform.origin.x
	left_wall.transform.origin.x = left_transform.origin.x
