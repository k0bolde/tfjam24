extends CharacterBody2D
class_name Player
#TODO add hp/mp ui in overworld
#TODO party follow while in dungeon. drop breadcrumbs while moving and followers move towards certain distances
# or just lerp towards player?

@onready var cam : Camera2D = $Camera2D
@onready var interact_container : Container = %InteractContainer
@onready var interact_label : Label = %InteractLabel
@onready var player_sprite : Sprite2D = %PlayerSprite

@export var speed := 150.0
var is_sprinting = false
var encounter_area : EncounterArea
var npc : NPC
var is_battling := false
var is_talking := false
var in_cutscene := false
var interact_callback
var button_dir := Vector2()


func _ready() -> void:
	var is_mobile := OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile")
	%PhoneButtons.visible = is_mobile
	%PhoneDirections.visible = is_mobile
	#remove the left mouse click binding to interact, otherwise you get stuck in a door opening loop
	if is_mobile:
		var ie := InputMap.action_get_events("interact")
		for i in ie:
			if i is InputEventMouseButton:
				InputMap.action_erase_event("interact", i)


func _unhandled_input(event: InputEvent) -> void:
	if Globals.main.is_menu_up() or is_battling or is_talking or in_cutscene:
		return
		
	if event.is_action_pressed("interact"):
		interact_pressed()
	
	
func interact_pressed():
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


func _physics_process(delta: float) -> void:
	if Globals.main.is_menu_up() or is_battling or is_talking:
		return
	var dir := Input.get_vector("left", "right", "up", "down")
	if button_dir != Vector2.ZERO:
		dir = button_dir
	if not is_zero_approx(dir.x):
		player_sprite.flip_h = dir.x > 0
	velocity = dir * speed
	if is_sprinting:
		velocity *= 2.0
	move_and_slide()
	if velocity.length_squared() > 0.0 and encounter_area and not Globals.debug_disable_random_encounters:
		#ask if we hit a battle
		if is_sprinting:
			encounter_area.check_for_battle(delta * 4.0)
		else:
			encounter_area.check_for_battle(delta)


func _on_up_button_button_down() -> void:
	button_dir = Vector2.UP


func _on_up_button_button_up() -> void:
	button_dir = Vector2.ZERO


func _on_left_button_button_down() -> void:
	button_dir = Vector2.LEFT


func _on_left_button_button_up() -> void:
	button_dir = Vector2.ZERO


func _on_right_button_button_down() -> void:
	button_dir = Vector2.RIGHT


func _on_right_button_button_up() -> void:
	button_dir = Vector2.ZERO


func _on_down_button_button_down() -> void:
	button_dir = Vector2.DOWN


func _on_down_button_button_up() -> void:
	button_dir = Vector2.ZERO


func _on_interact_button_pressed() -> void:
	interact_pressed()


func _on_menu_button_pressed() -> void:
	Globals.main.menu_pressed()


func _on_run_button_button_down() -> void:
	is_sprinting = true


func _on_run_button_button_up() -> void:
	is_sprinting = false
