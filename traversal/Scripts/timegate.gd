extends CanvasLayer

@export var display_time: float = 6.0
@export var fade_time: float = 1.0

func _ready():
	# When loading PrehistoricEra directly, just hide the shader
	visible = false
	$ColorRect.visible = false

func _process(delta):
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
