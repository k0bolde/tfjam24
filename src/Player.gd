extends CharacterBody2D
@export var speed := 150.0
var is_sprinting = false


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
	
