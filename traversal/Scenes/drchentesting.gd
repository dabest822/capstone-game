extends Node2D

@onready var animated_sprite = $CharacterBody2D2/AnimatedSprite2D2
@onready var area = $Area2D
var is_jumping = false
var initial_y_pos = 0.0

func _ready():
	initial_y_pos = position.y
	animated_sprite.play("Idle")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	print("Dr. Chen ready, waiting for player interaction")
	# Debug info
	print("Area2D monitoring: ", area.monitoring)
	print("Area2D monitorable: ", area.monitorable)

func _on_body_entered(body):
	print("Body entered: ", body.name)
	print("Body collision layer: ", body.collision_layer)
	print("Body collision mask: ", body.collision_mask)
	if body is CharacterBody2D and body.name == "CharacterBody2D1":
		print("Player entered Dr. Chen's area.")
		perform_jump()

func perform_jump():
	print("Starting jump")
	if not is_jumping:
		is_jumping = true
		animated_sprite.play("Jump")
		var tween = create_tween()
		tween.tween_property(self, "position:y", initial_y_pos - 100, 0.5)
		tween.tween_property(self, "position:y", initial_y_pos, 0.5)
		tween.finished.connect(_on_jump_finished)

func _on_jump_finished():
	print("Jump finished")
	is_jumping = false
	animated_sprite.play("Idle")

func _on_body_exited(body):
	if body is CharacterBody2D and body.name == "CharacterBody2D1":
		print("Player exited Dr. Chen's area.")
