extends Node2D
class_name Battle
#TODO basic battles - attack, select, kill, die, end
# Attack - pick ability, pick target, apply atk to enemy def, eva miss/crit chance, update enemy hp, animations and waiting for them (tweens with unlock callbacks?). Ability select menu
# Enemy Attack - pick attack, apply atk to player def, eva miss/crit chance, update player hp
# Select - left/right buttons? mouse select (would need physics object picking on viewport), move light indicator
# Kill - when enemy hp 0 - remove sprite. When all enemies die, battle end. money and item drops - result screen?
# Die - when player hp 0 - death screen, kick to main menu?

@onready var idle_cam : Camera3D = %IdleCamera
@onready var action_cam : Camera3D = %ActionCamera
@onready var battle_center : Marker3D = %BattleCenter
@onready var enemies_node : Node3D = %Enemies
@onready var party_node : Node3D = %Party
@onready var indicator_light : SpotLight3D = %IndicatorLight
@onready var turns_label : Label = %TurnsLabel
@onready var hp_bar : ProgressBar = %HPBar
@onready var hp_label : Label = %HPLabel
@onready var mp_bar : ProgressBar = %MPBar
@onready var mp_label : Label = %MPLabel
@onready var enemy_hp_bar : ProgressBar = %EnemyHPBar
@onready var enemy_hp_mesh : MeshInstance3D = %EnemyHPMesh
@onready var weakness_label : Label3D = %WeaknessLabel
@onready var dmg_label : Label3D = %DmgLabel
@onready var buttons_grid_container : Container = %ButtonsGridContainer
@onready var ability_container : Container = %AbilityContainer
@onready var ability_grid_container : Container = %AbilityGridContainer

var enemy_names := []
var enemies : Array[Enemy] = []
var cam_tween : Tween
var turns := 1
var targeted_enemy := 0
# the party member with the current turn
var curr_party := 0
# the enemy with the current turn
var curr_enemy := 0
var is_player_turn := true
var curr_ability : String
var action_cam_shaky_tween_v : Tween
var action_cam_shaky_tween_h : Tween


func _ready() -> void:
	#make enemies from names
	if enemy_names.size() > 0:
		for en in enemy_names:
			enemies.push_back(Globals.enemies[en.to_lower()].duplicate())
	else:
		printerr("no enemy names, loading test enemies")
		enemies.push_back(Globals.enemies["slime"].duplicate())
		enemies.push_back(Globals.enemies["rat"].duplicate())
	#Setup enemy sprites
	for i in enemies.size():
		enemies[i].position = %EnemyPos1.position
		enemies[i].position.z -= i * 0.75
		var sprite := Sprite3D.new()
		sprite.texture = load(enemies[i].texture_path)
		sprite.region_enabled = true
		sprite.region_rect = enemies[i].region_rect
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.shaded = true
		sprite.flip_h = true
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sprite.position = enemies[i].position
		enemies_node.add_child(sprite)
		
	# fade in
	%FadeRect.visible = true
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(%FadeRect, "modulate", Color(0, 1, 0, 0), 1)
	
	# set up idle cam movement
	cam_tween = Globals.get_tween(cam_tween, self)
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.set_loops()
	var cam_start_pos := idle_cam.position
	cam_tween.tween_property(idle_cam, "position:x", cam_start_pos.x + 2, 5)
	cam_tween.tween_property(idle_cam, "position:x", cam_start_pos.x, 0)
	cam_tween.tween_property(idle_cam, "position:z", 0, 0)
	cam_tween.tween_property(idle_cam, "position:y", cam_start_pos.y + 0.5, 5)
	cam_tween.tween_property(idle_cam, "position:y", cam_start_pos.y, 0)
	cam_tween.tween_property(idle_cam, "position:z", cam_start_pos.z, 0)
	
	#action cam shaky cam
	var action_cam_start_rot := action_cam.rotation_degrees
	action_cam_shaky_tween_v = Globals.get_tween(action_cam_shaky_tween_v, self)
	action_cam_shaky_tween_v.set_trans(Tween.TRANS_SINE)
	action_cam_shaky_tween_v.set_loops()
	action_cam_shaky_tween_v.tween_property(action_cam, "rotation_degrees:x", action_cam_start_rot.x - 5, 5)
	action_cam_shaky_tween_v.tween_property(action_cam, "rotation_degrees:x", action_cam_start_rot.x + 5, 5)
	action_cam_shaky_tween_h = Globals.get_tween(action_cam_shaky_tween_h, self)
	action_cam_shaky_tween_h.set_trans(Tween.TRANS_SINE)
	action_cam_shaky_tween_h.set_loops()
	action_cam_shaky_tween_h.tween_property(action_cam, "rotation_degrees:y", action_cam_start_rot.y - 5, 11)
	action_cam_shaky_tween_h.tween_property(action_cam, "rotation_degrees:y", action_cam_start_rot.y + 5, 11)
	
	#setup hp/mp/turns
	update_bars(Globals.party.p[0]["hp"], Globals.party.p[0]["stats"].hp, Globals.party.p[0]["mp"], Globals.party.p[0]["stats"].mp)
	

func _process(_delta: float) -> void:
	idle_cam.look_at(battle_center.position)


func update_bars(hp, hp_max, mp, mp_max):
	turns_label.text = "%d" % turns
	hp_label.text = "%d/%d" % [hp, hp_max]
	hp_bar.max_value = hp_max
	hp_bar.value = hp
	mp_label.text = "%d/%d" % [mp, mp_max]
	mp_bar.max_value = mp_max
	mp_bar.value = mp
	

func _on_run_button_pressed() -> void:
	Events.battle_end.emit()
	
	
func player_attack(which_attack:String):
	
	turns -= 1
	Abilities.abilities[which_attack]["callable"].call(0, Globals.party, enemies, targeted_enemy, self)
	%TurnsLabel.text = "%d" % turns
	var all_dead := true
	for e in enemies:
		if e.hp > 0:
			all_dead = false
	if all_dead:
		battle_won()
	if turns <= 0:
		turns = enemies.size()
		is_player_turn = false
		enemy_attack(0)
	else:
		curr_party += 1
		if curr_party >= Globals.party.num:
			curr_party = 0
	
	
func enemy_attack(which_enemy:int):
	
	turns -= 1
	#TODO pick attack and target
	Abilities.abilities["basic"]["callable"].call(0, Globals.party, enemies, -1, self)
	
	%TurnsLabel.text = "%d" % turns
	var all_dead := true
	if Globals.party.hp1 > 0 or Globals.party.hp2 > 0 or Globals.party.hp3 > 0 or Globals.party.hp4 > 0:
		all_dead = false
	if all_dead:
		battle_lost()
	if turns > 0:
		enemy_attack(which_enemy + 1)
	else:
		idle_cam.make_current()
		is_player_turn = true


func _on_basic_attack_button_pressed() -> void:
	disable_buttons()
	show_targeting()
	curr_ability = "basic"


func show_targeting():
	%TargetContainer.visible = true
	indicator_light.visible = true
	action_cam.make_current()

	
func hide_targeting():
	%TargetContainer.visible = false
	indicator_light.visible = false
	idle_cam.make_current()


func _on_target_left_button_pressed() -> void:
	#TODO move target light to next enemy
	targeted_enemy = (targeted_enemy - 1) % enemies.size()
	update_selected_enemy()


func _on_target_right_button_pressed() -> void:
	targeted_enemy = (targeted_enemy + 1) % enemies.size()
	update_selected_enemy()


func update_selected_enemy():
	indicator_light.position = enemies[targeted_enemy].position
	indicator_light.position.y += 1.0
	enemy_hp_mesh.position = enemies[targeted_enemy].position
	enemy_hp_mesh.position.y += 0.75
	enemy_hp_bar.value = enemies[targeted_enemy].hp
	enemy_hp_bar.max_value = enemies[targeted_enemy].stats.hp


func battle_won():
	Globals.cash += enemies[0].cash_reward
	for i in Globals.party.num:
		Globals.party.p[i]["stats"].xp += enemies[0].xp_reward
	#TODO show results screen
	Events.battle_end.emit()
	
	
func battle_lost():
	#TODO death screen
	Globals.load_game()


func disable_buttons():
	for c in buttons_grid_container.get_children():
		c.disabled = true
		
		
func enable_buttons():
	for c in buttons_grid_container.get_children():
		c.disabled = false
	

func _on_cancel_target_button_pressed() -> void:
	hide_targeting()
	enable_buttons()


func _on_attack_button_pressed() -> void:
	hide_targeting()
	player_attack(curr_ability)
	_on_cancel_button_pressed()
	
	
func _on_abilities_button_pressed() -> void:
	disable_buttons()
	ability_container.visible = true
	for a in Globals.party.p[curr_party]["stats"].abilities:
		var b := Button.new()
		b.text = a.capitalize()
		b.pressed.connect(func ():
			curr_ability = a
			_on_cancel_button_pressed()
			disable_buttons()
			show_targeting()
			)
		b.disabled = Globals.party.p[curr_party]["mp"] < Abilities.abilities[a]["mp"]
		b.add_to_group("ability_button")
		#add it before the cancel button
		ability_grid_container.get_child(3).add_sibling(b)
		
		var mplab := Label.new()
		mplab.text = "%d" % Abilities.abilities[a]["mp"]
		mplab.add_to_group("ability_button")
		mplab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_sibling(mplab)
		
		var typelab := Label.new()
		typelab.text = Abilities.abilities[a]["type"].capitalize()
		typelab.add_to_group("ability_button")
		typelab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mplab.add_sibling(typelab)
		
		var desclab := Label.new()
		desclab.text = Abilities.abilities[a]["desc"]
		desclab.add_to_group("ability_button")
		typelab.add_sibling(desclab)


func _on_cancel_button_pressed() -> void:
	ability_container.visible = false
	for b in get_tree().get_nodes_in_group("ability_button"):
		b.queue_free()
	enable_buttons()
