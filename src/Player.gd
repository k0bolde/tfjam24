extends CharacterBody2D
class_name Player

@export var speed := 150.0
var is_sprinting = false
var encounter_area : EncounterArea


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pass
	
	if event.is_action_pressed("sprint"):
		is_sprinting = true
	if event.is_action_released("sprint"):
		is_sprinting = false


func _physics_process(delta: float) -> void:
	if Globals.main.is_menu_up():
		return
	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	if is_sprinting:
		velocity *= 2.0
	move_and_slide()
	if velocity.length_squared() > 0.0 and encounter_area:
		#TODO fight cooldown - don't get right after we fight one
		#TODO should pass delta
		#ask if we hit a battle
		encounter_area.check_for_battle()
		if is_sprinting:
			#TODO more checks if sprint (3 -4)
			pass
