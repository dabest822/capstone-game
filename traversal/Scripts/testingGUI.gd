extends CanvasLayer

@onready var health_bar = $GUIRoot/MarginContainer/TopBar/HealthBar
@onready var health_label = $GUIRoot/MarginContainer/TopBar/HealthBar/NumericalHealth
@onready var cooldown_circle = $GUIRoot/MarginContainer/TopBar/AbilityDisplay/CooldownCircle
@onready var cooldown_timer = $GUIRoot/MarginContainer/TopBar/AbilityDisplay/CooldownTimer
@onready var ability_icons = $GUIRoot/MarginContainer/TopBar/AbilityDisplay/AbilityIcons

var max_health = 100
var current_health = 100
var ability_cooldown = 5.0  # Seconds
var ability_ready = true
var cooldown_time_left = 0.0

func _process(delta):
	if not ability_ready:
		cooldown_time_left -= delta
		cooldown_circle.material.set_shader_parameter("progress", cooldown_time_left / ability_cooldown)
		cooldown_timer.text = str(ceil(cooldown_time_left))
		
		if cooldown_time_left <= 0:
			ability_ready = true
			cooldown_timer.hide()
			cooldown_circle.hide()

func update_health(new_health: float):
	current_health = new_health
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_health, 0.5)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	update_health_label()

func update_health_label():
	health_label.text = "%d/%d" % [current_health, max_health]

func start_ability_cooldown():
	ability_ready = false
	cooldown_time_left = ability_cooldown
	cooldown_timer.show()
	cooldown_circle.show()

func is_ability_ready() -> bool:
	return ability_ready
