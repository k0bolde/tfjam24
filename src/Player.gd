extends CharacterBody2D
class_name Player
#TODO add hp/mp ui in overworld

@onready var cam : Camera2D = $Camera2D
@onready var interact_container : Container = %InteractContainer
@onready var interact_label : Label = %InteractLabel

@export var speed := 150.0
var is_sprinting = false
var encounter_area : EncounterArea
var npc : NPC
var is_battling := false
var is_talking := false
var in_cutscene := false
var interact_callback


func _unhandled_input(event: InputEvent) -> void:
	if Globals.main.is_menu_up() or is_battling or is_talking or in_cutscene:
		return
		
	if event.is_action_pressed("interact"):
		if interact_callback:
			interact_callback.call()
			interact_container.visible = false
			interact_callback = null
		if npc:
			npc.start_talk()
			is_talking = true
			interact_container.visible = false
			# remove the npc ref so we don't get stuck in a talk loop
			npc = null
	
	if event.is_action_pressed("sprint"):
		is_sprinting = true
	if event.is_action_released("sprint"):
		is_sprinting = false


func _physics_process(_delta: float) -> void:
	if Globals.main.is_menu_up() or is_battling or is_talking:
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
