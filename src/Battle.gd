extends Node2D
class_name Battle
#FIXME sometimes the player/enemies get unlimited turns? weakness/crit related? check add_turn code?
#major implementations
#TODO special effect attacks - tip the scales/etc
#TODO multi target attacks
#TODO party target buffs/heals - same buff should just refresh cooldown not add to buff
#TODO Item use
#TODO result screen - xp, cash, item, level, stat gains
#tweaks
#TODO some ui to pop up to tell you who's turn it is
#TODO battle enter animation
#TODO battle exit animation
#TODO fix how I call enemy_attack in player_attack and enemy_attack so it can't recurse. use states?

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
@onready var crit_label : Label3D = %CritLabel
@onready var party_bars_container : Container = %PartyBarsContainer
@onready var party_bars_vbox_container : Container = %PartyBarsVBoxContainer
@onready var a_bars_container : Container = %ABarsContainer
@onready var inspect_container : Container = %InspectContainer
@onready var inspect_name_label : Label = %InspectNameLabel
@onready var inspect_desc_label : Label = %InspectDescLabel
@onready var inspect_weak_label : Label = %InspectWeakLabel
@onready var inspect_resist_label : Label = %InspectResistLabel
@onready var side_cam : Camera3D = %SideCam

var can_run := false
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
var side_cam_shaky_tween_v : Tween
var side_cam_shaky_tween_h : Tween
var attack_name_tween : Tween
var total_turns := 0
enum turn_states {PLAYER, ENEMY}
var turn_state := turn_states.PLAYER

func _ready() -> void:
	Globals.verify_enemies()
	if Globals.use_action_cam:
		idle_cam.make_current()
	else:
		side_cam.make_current()
	#make enemies from names
	if enemy_names.size() > 0:
		for en in enemy_names:
			enemies.push_back(Globals.enemies[en.to_lower()].duplicate())
	else:
		printerr("no enemy names, loading test enemies")
		enemies.push_back(Globals.enemies["slime"].duplicate())
		enemies.push_back(Globals.enemies["rat"].duplicate())
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
		#TODO need to move it up a certain amount too
		sprite.scale = Vector3(enemies[i].visual_scale, enemies[i].visual_scale, enemies[i].visual_scale)
		enemies[i].ingame_sprite = sprite
		enemies_node.add_child(sprite)
		var hpmesh = enemy_hp_mesh.duplicate()
		hpmesh.mesh.resource_local_to_scene = true
		enemies[i].name_label = hpmesh.get_node("EnemyNameLabel")
		hpmesh.get_node("EnemyNameLabel").unique_name_in_owner = false
		hpmesh.get_node("EnemyNameLabel").text = enemies[i].enemy_name
		enemies[i].hp_mesh = hpmesh
		hpmesh.position = sprite.position
		hpmesh.unique_name_in_owner = false
		enemies[i].hp_bar = hpmesh.get_node("SubViewport/EnemyHPBar")
		enemies[i].hp_bar.unique_name_in_owner = false
		#enemies[i].hp_bar.value = i * (100.0 / enemies.size())
		# needed to make a new mesh otherwise they all shared the same texture
		var planemesh := PlaneMesh.new()
		planemesh.size = Vector2(0.075, 0.465)
		planemesh.orientation = PlaneMesh.FACE_Z
		planemesh.resource_local_to_scene = true
		hpmesh.mesh = planemesh
		var mat := StandardMaterial3D.new()
		mat.resource_local_to_scene = true
		mat.albedo_color = Color.BLACK
		mat.emission_enabled = true
		mat.disable_ambient_light = true
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		hpmesh.mesh.material = mat
		mat.emission_texture = hpmesh.get_node("SubViewport").get_texture()
		enemies_node.add_child(hpmesh)
		
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
	cam_tween.tween_property(idle_cam, "position:x", cam_start_pos.x + 2, 10)
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
	
	var side_cam_start_rot := side_cam.rotation_degrees
	side_cam_shaky_tween_v = Globals.get_tween(side_cam_shaky_tween_v, self)
	side_cam_shaky_tween_v.set_trans(Tween.TRANS_SINE)
	side_cam_shaky_tween_v.set_loops()
	side_cam_shaky_tween_v.tween_property(side_cam, "rotation_degrees:x", side_cam_start_rot.x - 2, 5)
	side_cam_shaky_tween_v.tween_property(side_cam, "rotation_degrees:x", side_cam_start_rot.x + 2, 5)
	side_cam_shaky_tween_h = Globals.get_tween(side_cam_shaky_tween_h, self)
	side_cam_shaky_tween_h.set_trans(Tween.TRANS_SINE)
	side_cam_shaky_tween_h.set_loops()
	side_cam_shaky_tween_h.tween_property(side_cam, "rotation_degrees:y", side_cam_start_rot.y - 2, 11)
	side_cam_shaky_tween_h.tween_property(side_cam, "rotation_degrees:y", side_cam_start_rot.y + 2, 11)
	
	#heal after battle
	for p in Globals.party.p:
		p["hp"] = p["stats"].hp
	# set up party sprites
	for i in Globals.party.num:
		var sp := Sprite3D.new()
		sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sp.shaded = true
		sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sp.texture = load(Globals.party.p[i]["image"])
		sp.scale = Vector3(0.75, 0.75, 0.75)
		sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sp.position.z = party_node.position.z - i
		Globals.party.p[i]["ingame_sprite"] = sp
		party_node.add_child(sp)
	#setup hp/mp/turns
	turns = Globals.party.num
	a_bars_container.visible = false
	update_bars(0)
	update_turns()
	

func _process(_delta: float) -> void:
	idle_cam.look_at(battle_center.position)


func update_bars(party_num):
	hp_label.text = "%d/%d" % [Globals.party.p[party_num]["hp"], Globals.party.p[party_num]["stats"].hp]
	hp_bar.max_value = Globals.party.p[party_num]["stats"].hp
	hp_bar.value = Globals.party.p[party_num]["hp"]
	mp_label.text = "%d/%d" % [Globals.party.p[party_num]["mp"], Globals.party.p[party_num]["stats"].mp]
	mp_bar.max_value = Globals.party.p[party_num]["stats"].mp
	mp_bar.value = Globals.party.p[party_num]["mp"]
	
	# add all party members not the party_num
	if Globals.party.num == 1:
		party_bars_container.visible = false
	for i in party_bars_vbox_container.get_node("GridContainer").get_children():
		i.queue_free()
	for i in Globals.party.num:
		if i == party_num:
			continue
		var bars := a_bars_container.duplicate()
		bars.get_node("NameLabel").text = Globals.party.p[i]["name"]
		bars.get_node("HPLabel").text = "%d/%d" % [Globals.party.p[i]["hp"], Globals.party.p[i]["stats"].hp]
		bars.get_node("HPBar").max_value = Globals.party.p[i]["stats"].hp
		bars.get_node("HPBar").value = Globals.party.p[i]["hp"]
		bars.get_node("MPLabel").text = "%d/%d" % [Globals.party.p[i]["mp"], Globals.party.p[i]["stats"].mp]
		bars.get_node("MPBar").max_value = Globals.party.p[i]["stats"].mp
		bars.get_node("MPBar").value = Globals.party.p[i]["mp"]
		for n in bars.get_children():
			n.reparent(party_bars_vbox_container.get_node("GridContainer"))
		bars.queue_free()
	
	
func turn_ended():
	if is_player_turn:
		curr_party = find_next_teammate()
		if turns <= 0:
			turns = 0
			for e in enemies:
				turns += e.base_turns
			is_player_turn = false
			total_turns = 0
			turn_state = turn_states.ENEMY
			#TODO change this from a method call to something else
			enemy_attack(0)
		else:
			await get_tree().create_timer(1).timeout
			enable_buttons()
			update_bars(curr_party)
			update_turns()
	else:
		if Globals.party.num_alive() <= 0:
			battle_lost()
		if turns > 0:
			var next_enemy := curr_enemy + 1
			if next_enemy >= enemies.size():
				next_enemy = 0
			#TODO change this from a method call to something else
			enemy_attack(next_enemy)
		else:
			if Globals.use_action_cam:
				idle_cam.make_current()
			else:
				side_cam.make_current()
			is_player_turn = true
			turns = Globals.party.num_alive()
			total_turns = 0
			turn_state = turn_states.PLAYER
			if Globals.party.p[curr_party]["hp"] <= 0:
				curr_party = find_next_teammate()
			update_bars(curr_party)
			update_turns()
			enable_buttons()


func _on_run_button_pressed() -> void:
	if can_run:
		#TODO add together enemies eva and living party's eva
		#if randf() < (enemies[0].stats.eva - Globals.party.p[0]["stats"].eva) / 100.0 + 50.0:
			#Events.battle_end.emit()
		#else:
			#show_enemy_attack("Running unsucessful!")
		add_turn(-1)
		Events.battle_end.emit()
	else:
		show_enemy_attack("Can't run!")
	
	
func player_attack(which_attack:String):
	disable_buttons()
	turns -= 1
	update_turns()
	Abilities.abilities[which_attack]["callable"].call(-(curr_party + 1), Globals.party, enemies, targeted_enemy, self)
	audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
	audio_stream_player.play()
	#update enemy hp bar
	enemy_hp_bar.value = enemies[targeted_enemy].hp
	#TODO show enemy hp bar for a bit after an attack
	if enemies[targeted_enemy].hp <= 0:
		enemies[targeted_enemy].anim_tween.kill()
		enemies[targeted_enemy].hp_bar_tween.kill()
		enemies[targeted_enemy].hp_mesh.visible = false
		enemies[targeted_enemy].ingame_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		enemies[targeted_enemy].ingame_sprite.rotation_degrees.x = 90.0
		enemies[targeted_enemy].ingame_sprite.rotation_degrees.y = 90.0
		enemies[targeted_enemy].ingame_sprite.position.y = -0.45
		defeated_enemies.push_back(enemies[targeted_enemy])
		enemies.remove_at(targeted_enemy)
		if enemies.size() > 0:
			_on_target_right_button_pressed(false)
	
	if enemies.size() == 0:
		battle_won()
	
	curr_party = find_next_teammate()
	if turns <= 0:
		turns = 0
		for e in enemies:
			turns += e.base_turns
		is_player_turn = false
		total_turns = 0
		turn_state = turn_states.ENEMY
		#TODO change this from a method call to something else
		enemy_attack(0)
	else:
		await get_tree().create_timer(0.5).timeout
		enable_buttons()
		update_bars(curr_party)
		update_turns()
	
	
func find_next_teammate() -> int:
	var next_teammate := curr_party + 1
	if next_teammate >= Globals.party.num:
		next_teammate = 0
	var total_checked := 0
	while Globals.party.p[next_teammate]["hp"] <= 0:
		next_teammate += 1
		if next_teammate >= Globals.party.num:
			next_teammate = 0
		total_checked += 1
		#this shouldn't happen? but does?
		if total_checked > Globals.party.num:
			if is_inside_tree():
				battle_lost()
			else:
				break
	return next_teammate
	
	
func enemy_attack(which_enemy:int):
	curr_enemy = which_enemy
	turns -= 1
	#double check is nasty
	if not is_inside_tree() or enemies.is_empty():
		return
	await get_tree().create_timer(1).timeout
	if not is_inside_tree() or enemies.is_empty():
		return
	update_turns()
	var selected_attack : String = ""
	var pick := randf()
	var accum := 0.0
	for attack in enemies[curr_enemy].attack_probs:
		accum += enemies[curr_enemy].attack_probs[attack]
		if pick < accum:
			selected_attack = attack
	if selected_attack == "":
		printerr("oops %s couldn't pick an attack, picking random attack" % enemies[curr_enemy].enemy_name)
		selected_attack = enemies[curr_enemy].stats.abilities.pick_random()
	if Abilities.abilities[selected_attack]["effect"] == 2:
		#healing ability, target an enemy not at max hp
		pass
	var target_party := randi_range(0, Globals.party.num - 1)
	while Globals.party.p[target_party]["hp"] <= 0:
		#bad code
		target_party = randi_range(0, Globals.party.num - 1)
	Abilities.abilities[selected_attack]["callable"].call(curr_enemy, Globals.party, enemies, -(target_party + 1), self)
	audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
	audio_stream_player.play()
	show_enemy_attack(Abilities.abilities[selected_attack]["enemy_flavor"].replace("CHAR", Globals.party.p[target_party]["name"]))
	update_bars(0)
	turns_label.text = "%d" % turns
	if Globals.party.num_alive() <= 0:
		battle_lost()
	if turns > 0:
		var next_enemy := curr_enemy + 1
		if next_enemy >= enemies.size():
			next_enemy = 0
		#TODO change this from a method call to something else
		enemy_attack(next_enemy)
	else:
		if Globals.use_action_cam:
			idle_cam.make_current()
		else:
			side_cam.make_current()
		is_player_turn = true
		turns = Globals.party.num_alive()
		total_turns = 0
		turn_state = turn_states.PLAYER
		if Globals.party.p[curr_party]["hp"] <= 0:
			curr_party = find_next_teammate()
		update_bars(curr_party)
		update_turns()
		enable_buttons()


func kill_party_member(party_num:int):
	var sp : Sprite3D = Globals.party.p[party_num]["ingame_sprite"]
	sp.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sp.rotation_degrees.x = 90.0
	sp.rotation_degrees.y = -90.0
	sp.position.y = -0.45
	

# type 0 = normal, 1 = weakness, 2 = resist, 3 = miss
func show_dmg_label(dmg:int, target:int, type:=0, is_crit:=false):
	if not is_inside_tree():
		return
	var wl := weakness_label.duplicate()
	var cl := crit_label.duplicate()
	var the_target : Node3D
	if target >= 0:
		the_target = enemies[target].ingame_sprite
		var bar := enemies[target].hp_bar
		enemies[target].hp_mesh.visible = true
		enemies[target].hp_mesh.position = the_target.position
		enemies[target].hp_mesh.position.y += 1.0
		bar.value = enemies[target].hp
		bar.max_value = enemies[target].stats.hp
		var t := get_tree().create_tween()
		enemies[target].hp_bar_tween = t
		t.tween_interval(5)
		t.tween_callback(func (): 
			if is_inside_tree() and targeted_enemy == target and not indicator_light.visible and not enemies.is_empty():
				enemies[target].hp_mesh.visible = false
			)
	else:
		the_target = Globals.party.p[abs(target) - 1]["ingame_sprite"]
	wl.visible = true
	match type:
		0:
			wl.visible = false
		1:
			wl.text = "WEAKNESS!"
		2:
			wl.text = "RESIST!"
		3:
			wl.text = "MISS!"
	cl.visible = is_crit
	var dl := dmg_label.duplicate()
	dl.visible = true
	dl.text = "-%d" % dmg
	dl.position = the_target.position
	if dmg < 0:
		dl.modulate = Color.GREEN
		dl.text = "+%d" % dmg
	cl.position = the_target.position
	cl.position.y += 0.1
	wl.position = the_target.position
	wl.position.y += 0.2
	base_3d.add_child(dl)
	base_3d.add_child(wl)
	base_3d.add_child(cl)
	var dmg_t := get_tree().create_tween()
	dmg_t.tween_property(dl, "position:y", the_target.position.y + 1.0, 2.0)
	dmg_t.tween_callback(dl.queue_free)
	var weak_t := get_tree().create_tween()
	weak_t.tween_property(wl, "position:y", the_target.position.y + 1.2, 2.0)
	weak_t.tween_callback(wl.queue_free)
	var crit_t := get_tree().create_tween()
	crit_t.tween_property(cl, "position:y", the_target.position.y + 1.1, 2.0)
	crit_t.tween_callback(cl.queue_free)


func _on_basic_attack_button_pressed() -> void:
	disable_buttons()
	show_targeting()
	curr_ability = "punch"
	if enemies.size() == 1:
		_on_attack_button_pressed()


func show_targeting(is_attacking:=true):
	%TargetContainer.get_node("PanelContainer/GridContainer/AttackButton").visible = is_attacking
	%TargetContainer.get_node("PanelContainer/GridContainer/CancelTargetButton").visible = is_attacking
	%TargetContainer.visible = true
	indicator_light.visible = true
	update_selected_enemy()
	action_cam.make_current()

	
func hide_targeting():
	%TargetContainer.visible = false
	indicator_light.visible = false
	enemies[targeted_enemy].hp_mesh.visible = false
	if Globals.use_action_cam:
		idle_cam.make_current()
	else:
		side_cam.make_current()


func _on_target_left_button_pressed() -> void:
	enemies[targeted_enemy].hp_mesh.visible = false
	targeted_enemy = (targeted_enemy + 1) % enemies.size()
	update_selected_enemy()


func _on_target_right_button_pressed(is_targeting:=true) -> void:
	if enemies.is_empty():
		return
	if targeted_enemy < enemies.size():
		enemies[targeted_enemy].hp_mesh.visible = false
	targeted_enemy = (targeted_enemy - 1) % enemies.size()
	if targeted_enemy < 0:
		targeted_enemy = enemies.size() - 1
	if is_targeting:
		update_selected_enemy()
  

func update_selected_enemy():
	var e := enemies[targeted_enemy]
	indicator_light.position = e.position
	indicator_light.position.y += 1.0
	indicator_light.position.x -= 0.2
	var hp_mesh := e.hp_mesh
	hp_mesh.visible = true
	hp_mesh.position = e.position
	hp_mesh.position.y += 1.0
	e.hp_bar.value = e.hp
	e.hp_bar.max_value = e.stats.hp
	inspect_name_label.text = e.enemy_name.capitalize()
	inspect_desc_label.text = e.desc
	if Globals.party.fought_enemies.has(e.enemy_name):
		if e.stats.weaknesses.is_empty():
			inspect_weak_label.text = "Weak to nothing"
		else:
			inspect_weak_label.text = "Weak to %s" % e.stats.weaknesses
		if e.stats.resistances.is_empty():
			inspect_resist_label.text = "Resists nothing"
		else:
			inspect_resist_label.text = "Reists %s" % e.stats.resistances
	else:
		inspect_weak_label.text = "???"
		inspect_resist_label.text = "???"


func battle_won():
	#TODO show results screen
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
	#heal after battle
	for p in Globals.party.p:
		p["hp"] = p["stats"].hp
	#keep track of what enemies we've defeated so we can show full inspect info
	for en in enemy_names:
		if not Globals.party.fought_enemies.has(en):
			Globals.party.fought_enemies.append(en)
	# fade out
	%FadeRect.visible = true
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(%FadeRect, "modulate", Color.BLACK, 1)
	t.tween_callback(Events.battle_end.emit)
	
	
func battle_lost():
	#TODO death screen - text that tells you you turned into what defeated you
	#Globals.load_game()
	get_tree().change_scene_to_file("res://src/TitleScreen.tscn")


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
	#enable_buttons()
	
	
func _on_abilities_button_pressed() -> void:
	disable_buttons()
	for a in Globals.party.p[curr_party]["stats"].abilities:
		var b := Button.new()
		b.text = a.capitalize()
		b.pressed.connect(func ():
			curr_ability = a
			_on_cancel_button_pressed()
			disable_buttons()
			show_targeting()
			if enemies.size() == 1:
				_on_attack_button_pressed()
			)
		b.disabled = Globals.party.p[curr_party]["mp"] < Abilities.abilities[a]["mp"]
		b.add_to_group("ability_button")
		#add it before the cancel button
		ability_grid_container.get_child(3).add_sibling(b)
		
		var mplab := Label.new()
		mplab.text = "%d" % Abilities.abilities[a]["mp"]
		mplab.add_to_group("ability_button")
		mplab.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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
	#need to set deferred so it doesn't go off screen
	ability_container.set_deferred("visible", true)


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


func add_turn(num := 1, override_total := false):
	if override_total:
		turns += num
		total_turns += abs(num)
	else:
		#print_stack()
		if is_player_turn:
			#TODO allow adding a turn when killing an enemy with a weakness even if max turns hit
			if total_turns < enemies.size() * 2:
				turns += num
				total_turns += abs(num)
				#print("Added a turn - %d/%d" % [turns, total_turns])
		else:
			if total_turns < Globals.party.num_alive() * 2:
				turns += num
				total_turns += abs(num)
				#print("Added enemy turn - %d/%d" % [turns, total_turns])
	update_turns()


func update_turns():
	if enemies.size() == 0:
		return
	turns_label.text = "%d" % turns
	var whose_turn : String = Globals.party.p[curr_party]["name"]
	if not is_player_turn:
		whose_turn = enemies[curr_enemy].enemy_name.capitalize()
	char_turn_label.text = "%s's turn" % whose_turn


func _on_pass_turn_button_pressed() -> void:
	if total_turns >= enemies.size() * 2:
		show_enemy_attack("Can't pass turns, turn limit reached")
		return
	total_turns += 1
	curr_party = find_next_teammate()
	update_bars(curr_party)
	update_turns()
	

func animate_sprite(target:int):
	var the_target : Sprite3D
	var t := get_tree().create_tween()
	if target >= 0:
		the_target = enemies[target]["ingame_sprite"]
		enemies[target]["anim_tween"] = t
	else:
		the_target = Globals.party.p[abs(target) - 1]["ingame_sprite"]
	t.tween_property(the_target, "position:y", the_target.position.y + 0.25, 0.1)
	t.tween_property(the_target, "position:y", the_target.position.y, 0.1)
	t.tween_interval(0.5)


func _on_inspect_button_pressed() -> void:
	disable_buttons()
	show_targeting(false)
	inspect_container.visible = true


func _on_inspect_cancel_button_pressed() -> void:
	enable_buttons()
	hide_targeting()
	inspect_container.visible = false
