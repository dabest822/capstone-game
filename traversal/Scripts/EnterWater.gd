extends Node2D

@onready var interaction_area = $WaterInteraction  # Refers to the Area2D node

func _ready():
	# Connect signals for Area2D
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "CharacterBody2D1":  # Match your player's node name
		print("Player entered water!")
		if body.has_method("set_physics_process"):  # Ensure the player has velocity handling
			body.velocity.y = 0.5  # Slow player in water (example logic)

func _on_body_exited(body):
	if body.name == "CharacterBody2D1":  # Match your player's node name
		print("Player exited water!")
		if body.has_method("set_physics_process"):  # Ensure the player has velocity handling
			body.velocity.y = 2.0  # Restore player speed (example logic)
