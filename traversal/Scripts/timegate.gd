extends CanvasLayer

@export var display_time: float = 6.0  # How long to show the effect
@export var fade_time: float = 1.0     # Optional fade out time

func _ready():
	# Make sure ColorRect fills screen
	var color_rect = $ColorRect
	
	# Optional: Add fade out effect
	if fade_time > 0:
		# Wait until just before the end
		await get_tree().create_timer(display_time - fade_time).timeout
		# Fade out
		var tween = create_tween()
		tween.tween_property(color_rect, "modulate:a", 0.0, fade_time)
		await tween.finished  # Corrected this line - removed parentheses
	else:
		# Just wait the full time
		await get_tree().create_timer(display_time).timeout
	
	# Remove the effect
	queue_free()

# Optional: Add pause support
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
