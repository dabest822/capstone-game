extends CanvasLayer

@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
   # Hide the shader display by default
	visible = false
	$ColorRect.visible = false

# Keep your existing process function for pause support
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
