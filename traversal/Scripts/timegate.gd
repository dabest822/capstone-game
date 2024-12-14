extends CanvasLayer

@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
	# Check if we're in the titlescreen scene using the explicit path
	var root = get_tree().get_current_scene()
	if root and get_tree().current_scene == load("res://Scenes/titlescreen.tscn"):
		print("On titlescreen. Shader displayed.")
		visible = true
		$ColorRect.visible = true
	else:
		print("Not on titlescreen. Shader hidden.")
		visible = false
		$ColorRect.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()

# This function will only be called during actual portal transitions
func start_transition():
	visible = true
	$ColorRect.visible = true
	
	# Auto-hide after display_time seconds
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = display_time
	timer.timeout.connect(func(): 
		visible = false
		$ColorRect.visible = false
		timer.queue_free()
	)
	timer.start()
