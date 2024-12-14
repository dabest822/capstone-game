extends CanvasLayer

@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
	# Get the current scene name
	var current_scene = get_tree().get_current_scene().get_name()
	
	# If we're in the title screen, keep shader visible
	if current_scene == "Node2D":  # Assuming "Node2D" is your title screen's root node name
		visible = true
		$ColorRect.visible = true
	else:
		# Hide the shader display by default in other scenes
		visible = false
		$ColorRect.visible = false

# Keep your existing process function for pause support
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
