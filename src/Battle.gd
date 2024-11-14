extends Node2D
class_name Battle
#TODO battle basics
# Attack - apply atk to enemy def, eva miss/crit chance, update enemy hp, animations and waiting for them (tweens with unlock callbacks?)
# Enemy Attack - pick attack, apply atk to player def, eva miss/crit chance
# Kill - when enemy hp 0 - remove sprite. When all enemies die, battle end. money and item drops - result screen?
# Die - when player hp 0 - death screen, kick to main menu?
# weaknesses and turns
# Item use
# animations for attacks, getting attacked
# multi target attacks
# party target buffs/heals
# show party hp/mp all the time?

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
@onready var base_3d : Node3D = %Base3D
@onready var char_turn_label : Label = %CharTurnLabel
@onready var attack_name_container : Container = %AttackNameContainer
@onready var attack_name_label : Label = %AttackNameLabel
@onready var enemy_name_label : Label3D = %EnemyNameLabel
@onready var audio_stream_player : AudioStreamPlayer = %AudioStreamPlayer

var can_run := true
var enemy_names := []
var enemies : Array[Enemy] = []
var defeated_enemies : Array[Enemy] = []
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
var attack_name_tween : Tween


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
		enemies[i].hp = enemies[i].stats.hp
		enemies[i].position = %EnemyPos1.position
		enemies[i].position.z -= i * 1.25
		var sprite := Sprite3D.new()
		sprite.texture = load(enemies[i].texture_path)
		if enemies[i].region_rect:
			sprite.region_enabled = true
			sprite.region_rect = enemies[i].region_rect
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.shaded = true
		sprite.flip_h = enemies[i].flip_h
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sprite.position = enemies[i].position
		enemies[i].ingame_sprite = sprite
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
	action_cam_shaky_tween_v.tween_property(action_cam, "rotation_degrees:x", action_cam_start_rot.x - 2, 5)
	action_cam_shaky_tween_v.tween_property(action_cam, "rotation_degrees:x", action_cam_start_rot.x + 2, 5)
	action_cam_shaky_tween_h = Globals.get_tween(action_cam_shaky_tween_h, self)
	action_cam_shaky_tween_h.set_trans(Tween.TRANS_SINE)
	action_cam_shaky_tween_h.set_loops()
	action_cam_shaky_tween_h.tween_property(action_cam, "rotation_degrees:y", action_cam_start_rot.y - 2, 11)
	action_cam_shaky_tween_h.tween_property(action_cam, "rotation_degrees:y", action_cam_start_rot.y + 2, 11)
	
	#setup hp/mp/turns
	update_bars(0)
	turns_label.text = "%d" % turns
	
	#move enemy indicator
	update_selected_enemy()


func _process(_delta: float) -> void:
	idle_cam.look_at(battle_center.position)


func update_bars(party_num):
	#turns_label.text = "%d" % turns
	hp_label.text = "%d/%d" % [Globals.party.p[party_num]["hp"], Globals.party.p[party_num]["stats"].hp]
	hp_bar.max_value = Globals.party.p[party_num]["stats"].hp
	hp_bar.value = Globals.party.p[party_num]["hp"]
	mp_label.text = "%d/%d" % [Globals.party.p[party_num]["mp"], Globals.party.p[party_num]["stats"].mp]
	mp_bar.max_value = Globals.party.p[party_num]["stats"].mp
	mp_bar.value = Globals.party.p[party_num]["mp"]
	

func _on_run_button_pressed() -> void:
	if can_run:
		Events.battle_end.emit()
	else:
		show_enemy_attack("Can't run!")
	
	
func player_attack(which_attack:String):
	
	turns -= 1
	Abilities.abilities[which_attack]["callable"].call(0, Globals.party, enemies, targeted_enemy, self)
	audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
	audio_stream_player.play()
	#update enemy hp bar
	enemy_hp_bar.value = enemies[targeted_enemy].hp
	if enemies[targeted_enemy].hp <= 0:
		enemies[targeted_enemy].ingame_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		enemies[targeted_enemy].ingame_sprite.rotation_degrees.x = 90.0
		enemies[targeted_enemy].ingame_sprite.rotation_degrees.y = 90.0
		enemies[targeted_enemy].ingame_sprite.position.y = -0.45
		defeated_enemies.push_back(enemies[targeted_enemy])
		enemies.remove_at(targeted_enemy)
		if enemies.size() > 0:
			_on_target_left_button_pressed()
	%TurnsLabel.text = "%d" % turns
	
	var all_dead := true
	for e in enemies:
		if e.hp > 0:
			all_dead = false
	if all_dead:
		battle_won()
		
	if turns <= 0:
		turns = enemies.size()
		for e in enemies:
			if e.hp <= 0:
				turns -= 1
		is_player_turn = false
		enemy_attack(0)
	else:
		curr_party += 1
		if curr_party >= Globals.party.num:
			curr_party = 0
	
	
func enemy_attack(which_enemy:int):
	
	turns -= 1
	#TODO pick attack and target
	var enemy_attack := "punch"
	var target_party := 0
	Abilities.abilities[enemy_attack]["callable"].call(0, Globals.party, enemies, 0 - (target_party + 1), self)
	audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
	audio_stream_player.play()
	show_enemy_attack(Abilities.abilities[enemy_attack]["enemy_flavor"].replace("CHAR", Globals.party.names[target_party]))
	#update party hp
	update_bars(0)
	%TurnsLabel.text = "%d" % turns
	var all_dead := true
	for p in Globals.party.p:
		if p["hp"] > 0:
			all_dead = false
	if all_dead:
		battle_lost()
	if turns > 0:
		enemy_attack(which_enemy + 1)
	else:
		idle_cam.make_current()
		is_player_turn = true
		turns = Globals.party.num
		for i in Globals.party.num:
			if Globals.party.p[i]["hp"] <= 0:
				turns -= 1


func show_dmg_label(dmg:int, pos:Vector3):
	var dl := dmg_label.duplicate()
	dl.text = "-%d" % dmg
	dl.position = pos
	base_3d.add_child(dl)
	var t := get_tree().create_tween()
	t.tween_property(dl, "position:y", pos.y + 1.0, 2.0)
	t.tween_callback(dl.queue_free)


func _on_basic_attack_button_pressed() -> void:
	disable_buttons()
	show_targeting()
	curr_ability = "punch"


func show_targeting():
	%TargetContainer.visible = true
	indicator_light.visible = true
	enemy_hp_mesh.visible = true
	action_cam.make_current()

	
func hide_targeting():
	%TargetContainer.visible = false
	indicator_light.visible = false
	enemy_hp_mesh.visible = false
	idle_cam.make_current()


func _on_target_left_button_pressed() -> void:
	targeted_enemy = (targeted_enemy - 1) % enemies.size()
	if targeted_enemy < 0:
		targeted_enemy = enemies.size() - 1
	update_selected_enemy()


func _on_target_right_button_pressed() -> void:
	targeted_enemy = (targeted_enemy + 1) % enemies.size()
	update_selected_enemy()


func update_selected_enemy():
	#print("targeted %d" % targeted_enemy)
	indicator_light.position = enemies[targeted_enemy].position
	indicator_light.position.y += 1.0
	indicator_light.position.x -= 0.2
	enemy_hp_mesh.position = enemies[targeted_enemy].position
	enemy_hp_mesh.position.y += 0.75
	enemy_hp_bar.value = enemies[targeted_enemy].hp
	enemy_hp_bar.max_value = enemies[targeted_enemy].stats.hp
	enemy_name_label.text = enemies[targeted_enemy].enemy_name.capitalize()


func battle_won():
	for e in defeated_enemies:
		Globals.cash += e.cash_reward
		Globals.party.xp += e.xp_reward
	var required_to_level := 0
	for i in Globals.party.level + 1:
		required_to_level += i * 10
	if Globals.party.xp >= required_to_level:
		#level up
		print("level up %d! %d/%d required" % [Globals.party.level + 1, Globals.party.xp, required_to_level])
		Globals.party.level += 1
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
	enable_buttons()
	#_on_cancel_button_pressed()
	
	
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


func show_enemy_attack(attack:String):
	attack_name_label.text = attack
	attack_name_container.visible = true
	attack_name_tween = Globals.get_tween(attack_name_tween, self)
	attack_name_tween.tween_interval(2.0)
	attack_name_tween.tween_property(attack_name_container, "visible", false, 0)
