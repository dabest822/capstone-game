extends CanvasLayer

# We can keep these exports in case we want to use them later
@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
	# Make sure ColorRect fills screen
	var color_rect = $ColorRect
	# Nothing else needed here - let it run forever

# Optional: Keep pause support
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
