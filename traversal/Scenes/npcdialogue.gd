extends Node2D

@onready var area = $Area2D
@export var dialogue_lines = ["Hello!", "Welcome to the lab.", "Press Shift to run!"]

var player_in_range = false
var dialogue_index = 0

func _ready():
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.name == "CharacterBody2D":  # Ensure it's the player
		player_in_range = true
		print("Player in range! Press 'E' to talk.")

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		player_in_range = false
		print("Player left range.")

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):  # 'E' by default
		show_dialogue()

func show_dialogue():
	var dialogue_box = get_tree().get_root().get_node("Node2D/DialogueBox")
	if dialogue_index < dialogue_lines.size():
		dialogue_box.show()
		dialogue_box.get_node("Label").text = dialogue_lines[dialogue_index]
		dialogue_index += 1
	else:
		dialogue_box.hide()
		dialogue_index = 0  # Reset dialogue for next interaction
