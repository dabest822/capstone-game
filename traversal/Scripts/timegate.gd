extends CanvasLayer

@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
	# Make sure ColorRect fills screen (even if not used later)
	var _color_rect = $ColorRect
	# Nothing else needed here - let it run forever

# Optional: Keep pause support
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
