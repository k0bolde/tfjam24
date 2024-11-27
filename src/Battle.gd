extends Node2D
class_name Battle
#major implementations
#TODO Item use
#TODO party targeting for buffs/heals

#tweaks
#TODO dmg label positioning - move down for party, move forward for all so there's no z-fighting
#TODO some ui to pop up to tell you who's turn it is
#TODO battle enter animation
#TODO battle exit animation

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
@onready var results_container : Container = %ResultsContainer
@onready var xp_gained_label : Label = %XPGainedLabel
@onready var total_xp_label : Label = %TotalXPLabel
@onready var xp_to_level_label : Label = %XPToLevelLabel
@onready var level_up_label : Label = %LevelUpLabel
@onready var cash_gained_label : Label = %CashGainedLabel
@onready var cash_total_level : Label = %CashTotalLabel
@onready var got_item_label : Label = %GotItemLabel

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
var is_enemy_attacking := false
var curr_ability : String
var action_cam_shaky_tween_v : Tween
var action_cam_shaky_tween_h : Tween
var side_cam_shaky_tween_v : Tween
var side_cam_shaky_tween_h : Tween
var attack_name_tween : Tween
var total_turns := 0


func _ready() -> void:
	results_container.visible = false
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
		if sprite.texture.get_height() != 128:
			var scaled := 128.0 / sprite.texture.get_height()
			sprite.scale = Vector3(scaled, scaled, scaled)
		if enemies[i].visual_scale != 1.0:
			sprite.scale = Vector3(enemies[i].visual_scale, enemies[i].visual_scale, enemies[i].visual_scale)
		sprite.offset = Vector2(0, (enemies[i].visual_scale * 128) / 2.0)
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
		enemies[i].hp_bar.value = enemies[i].stats.hp
		enemies[i].hp_bar.max_value = enemies[i].stats.hp
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
		if enemies[i].base_turns > 1:
			side_cam.fov = 90
		
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
	side_cam_shaky_tween_v.tween_property(side_cam, "rotation_degrees:x", side_cam_start_rot.x - 1, 5)
	side_cam_shaky_tween_v.tween_property(side_cam, "rotation_degrees:x", side_cam_start_rot.x + 1, 5)
	side_cam_shaky_tween_h = Globals.get_tween(side_cam_shaky_tween_h, self)
	side_cam_shaky_tween_h.set_trans(Tween.TRANS_SINE)
	side_cam_shaky_tween_h.set_loops()
	side_cam_shaky_tween_h.tween_property(side_cam, "rotation_degrees:y", side_cam_start_rot.y - 1, 11)
	side_cam_shaky_tween_h.tween_property(side_cam, "rotation_degrees:y", side_cam_start_rot.y + 1, 11)
	
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
		sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sp.position.z = party_node.position.z - i
		if sp.texture.get_height() != 128:
			var scaled := 128.0 / sp.texture.get_height()
			sp.scale = Vector3(scaled, scaled, scaled)
		if Globals.party.p[i].visual_scale != 1.0:
			sp.scale = Vector3(Globals.party.p[i].visual_scale, Globals.party.p[i].visual_scale, Globals.party.p[i].visual_scale)
		sp.offset = Vector2(0, (Globals.party.p[i].visual_scale * 128) / 2.0)
		Globals.party.p[i]["ingame_sprite"] = sp
		party_node.add_child(sp)
	#setup hp/mp/turns
	turns = Globals.party.num
	a_bars_container.visible = false
	update_bars(0)
	update_turns()
	

func _process(_delta: float) -> void:
	idle_cam.look_at(battle_center.position)
	if not is_player_turn and not is_enemy_attacking:
		enemy_attack()



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
	#TODO fix the flicker
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
			#n.call_deferred("reparent", party_bars_vbox_container.get_node("GridContainer"))
		bars.queue_free()
	
	
func _on_run_button_pressed() -> void:
	if can_run:
		#TODO add together enemies eva and living party's eva
		#if randf() < (enemies[0].stats.get_eva() - Globals.party.p[0]["stats"].get_eva()) / 100.0 + 50.0:
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
	var the_attack : Dictionary = Abilities.abilities[which_attack]
	if not Globals.debug_infinite_mp:
		Globals.party.p[curr_party]["mp"] -= the_attack["mp"]
	match the_attack["effect"]:
		0, 1, 4:
			the_attack["callable"].call(-(curr_party + 1), Globals.party, enemies, targeted_enemy, self)
		2, 3:
			#ally target
			#TODO implement
			pass
		5:
			#self target
			the_attack["callable"].call(-(curr_party + 1), Globals.party, enemies, -(curr_party + 1), self)
	
	update_bars(curr_party)
	curr_party = find_next_teammate()
	if turns <= 0:
		#remove a turn from temp_stats
		for i in Globals.party.num:
			for k in Globals.party.p[i].stats.temp_stats.keys():
				Globals.party.p[i].stats.temp_stats[k]["turns"] -= 1
				if Globals.party.p[i].stats.temp_stats[k]["turns"] <= 0:
					Globals.party.p[i].stats.temp_stats.erase(k)
		turns = 0
		for e in enemies:
			turns += e.base_turns
		is_player_turn = false
		total_turns = 0
		curr_enemy = 0
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
		if total_checked > Globals.party.num or Globals.party.num_alive() == 0:
			#if is_inside_tree():
				#battle_lost()
			#else:
			break
	return next_teammate
	
	
	
func enemy_attack():
	is_enemy_attacking = true
	turns -= 1
	#double check is nasty
	if not is_inside_tree() or enemies.is_empty():
		return
	await get_tree().create_timer(2).timeout
	if not is_inside_tree() or enemies.is_empty():
		return
	update_turns()
	var selected_attack : String = ""
	var pick := randf()
	var accum := 0.0
	for attack in enemies[curr_enemy].attack_probs:
		accum += enemies[curr_enemy].attack_probs[attack]
		if pick < accum:
			#print("pick %f accum %f picked %s" % [pick, accum, attack])
			selected_attack = attack
			break
	if selected_attack == "":
		printerr("oops %s couldn't pick an attack, picking random attack" % enemies[curr_enemy].enemy_name)
		selected_attack = enemies[curr_enemy].stats.abilities.pick_random()
	var the_attack : Dictionary = Abilities.abilities[selected_attack]
	match the_attack["effect"]:
		0, 1, 4:
			var target_party := randi_range(0, Globals.party.num - 1)
			while Globals.party.p[target_party]["hp"] <= 0:
				#bad code
				target_party = randi_range(0, Globals.party.num - 1)
			the_attack["callable"].call(curr_enemy, Globals.party, enemies, -(target_party + 1), self)
			show_enemy_attack(the_attack["enemy_flavor"].replace("CHAR", Globals.party.p[target_party]["name"]))
			if Globals.debug_invincible:
				Globals.party.p[target_party]["hp"] = Globals.party.p[target_party].stats.hp
			update_bars(curr_party)
		2, 3:
			#healing/buff ability, target an enemy not at max hp
			var target_enemy = enemies.pick_random()
			#only retarget once so we don't have to figure out more complicated logic
			if target_enemy["hp"] == target_enemy.stats.hp:
				target_enemy = enemies.pick_random()
			the_attack["callable"].call(curr_enemy, Globals.party, enemies, enemies.find(target_enemy), self)
			show_enemy_attack(the_attack["enemy_flavor"].replace("CHAR", target_enemy.enemy_name.capitalize()))
		5:
			the_attack["callable"].call(curr_enemy, Globals.party, enemies, curr_enemy, self)
			show_enemy_attack(the_attack["enemy_flavor"].replace("CHAR", enemies[curr_enemy].enemy_name.capitalize()))
		
	update_turns()
	if Globals.party.num_alive() <= 0:
		battle_lost()
	if turns > 0:
		var next_enemy := curr_enemy + 1
		if next_enemy >= enemies.size():
			next_enemy = 0
		curr_enemy = next_enemy
	else:
		#remove a turn from temp_stats
		for i in enemies.size():
			for k in enemies[i].stats.temp_stats.keys():
				enemies[i].stats.temp_stats[k]["turns"] -= 1
				if enemies[i].stats.temp_stats[k]["turns"] <= 0:
					enemies[i].stats.temp_stats.erase(k)
		if Globals.use_action_cam:
			idle_cam.make_current()
		else:
			side_cam.make_current()
		is_player_turn = true
		turns = Globals.party.num_alive()
		total_turns = 0
		if Globals.party.p[curr_party]["hp"] <= 0:
			curr_party = find_next_teammate()
		update_bars(curr_party)
		update_turns()
		enable_buttons()
	is_enemy_attacking = false


func kill_party_member(party_num:int):
	var sp : Sprite3D = Globals.party.p[party_num]["ingame_sprite"]
	sp.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sp.rotation_degrees.x = 90.0
	sp.rotation_degrees.y = -90.0
	#TODO lower player closer to the ground - the anim tween messes it up
	#get_tree().create_timer(1).timeout.connect(func (): sp.position.y = -0.45)
	sp.position.y = -0.45
	
	
func kill_enemy(target):
	enemies[target].anim_tween.kill()
	#why is this not killing the tween?
	enemies[target].hp_bar_tween.stop()
	enemies[target].hp_bar_tween.kill()
	enemies[target].hp_mesh.visible = false
	enemies[target].ingame_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	enemies[target].ingame_sprite.rotation_degrees.x = 90.0
	enemies[target].ingame_sprite.rotation_degrees.y = 90.0
	enemies[target].ingame_sprite.position.y = -0.45
	defeated_enemies.push_back(enemies[target])
	enemies.remove_at(target)
	if enemies.size() > 0:
		_on_target_right_button_pressed(false)
	else:
		battle_won()


# type 0 = normal, 1 = weakness, 2 = resist, 3 = miss
func show_dmg_label(dmg:int, target:int, type:=0, is_crit:=false):
	if not is_inside_tree():
		return
	var wl := weakness_label.duplicate()
	var cl := crit_label.duplicate()
	var the_target : Node3D
	if target >= 0:
		var the_enemy := enemies[target]
		the_target = the_enemy.ingame_sprite
		var bar := the_enemy.hp_bar
		the_enemy.hp_mesh.visible = true
		the_enemy.hp_mesh.position = the_target.position
		the_enemy.hp_mesh.position.y += 1.65
		the_enemy.hp_mesh.position.z += 0.05
		bar.value = the_enemy.hp
		bar.max_value = the_enemy.stats.hp
		var t := get_tree().create_tween()
		if the_enemy.hp_bar_tween:
			the_enemy.hp_bar_tween.kill()
		the_enemy.hp_bar_tween = t
		t.tween_interval(5)
		#FIXME last enemy's hp bar not disappearing on multi targets, sometimes?
		t.tween_callback(func (): 
			if is_inside_tree() and not indicator_light.visible and not enemies.is_empty() and the_target.is_inside_tree(): #and targeted_enemy == target
				the_enemy.hp_mesh.visible = false
			)
	else:
		the_target = Globals.party.p[abs(target) - 1]["ingame_sprite"]
	wl.visible = true
	match type:
		0:
			wl.visible = false
			audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
			audio_stream_player.play()
		1:
			wl.text = "WEAKNESS!"
			audio_stream_player.stream = load("res://assets/audio/critical attack hit.mp3")
			audio_stream_player.play()
		2:
			wl.text = "RESIST!"
			audio_stream_player.stream = load("res://assets/audio/normal attack hit.mp3")
			audio_stream_player.play()
		3:
			wl.text = "MISS!"
	if is_crit:
		audio_stream_player.stream = load("res://assets/audio/critical attack hit.mp3")
		audio_stream_player.play()
	cl.visible = is_crit
	var dl := dmg_label.duplicate()
	dl.visible = true
	dl.text = "-%d" % dmg
	dl.position = the_target.position
	dl.position.y += 1.0
	dl.position.z += 0.06
	if dmg < 0:
		dl.modulate = Color.GREEN
		dl.text = "+%d" % abs(dmg)
	cl.position = the_target.position
	cl.position.y += 1.1
	cl.position.z += 0.06
	wl.position = the_target.position
	wl.position.y += 1.2
	wl.position.z += 0.06
	if target < 0:
		dl.position.y -= 0.5
		cl.position.y -= 0.5
		wl.position.y -= 0.5
	base_3d.add_child(dl)
	base_3d.add_child(wl)
	base_3d.add_child(cl)
	var dmg_t := get_tree().create_tween()
	dmg_t.tween_property(dl, "position:y", dl.position.y + 1.0, 2.0)
	dmg_t.tween_callback(dl.queue_free)
	var weak_t := get_tree().create_tween()
	weak_t.tween_property(wl, "position:y", wl.position.y + 1.2, 2.0)
	weak_t.tween_callback(wl.queue_free)
	var crit_t := get_tree().create_tween()
	crit_t.tween_property(cl, "position:y", cl.position.y + 1.1, 2.0)
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
	hp_mesh.position.y += 1.65
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
	disable_buttons()
	results_container.visible = true
	var earned_cash := 0
	var earned_xp := 0
	for e in defeated_enemies:
		earned_cash += e.cash_reward
		earned_xp += e.xp_reward
	Globals.cash += earned_cash
	Globals.party.xp += earned_xp
	xp_gained_label.text = "XP gained: %d" % earned_xp
	total_xp_label.text = "Total XP: %d" % Globals.party.xp
	cash_gained_label.text = "Found $%d" % earned_cash
	cash_total_level.text = "Total of $%d" % Globals.cash 
	var required_to_level := Globals.party.get_xp_required_for_next_level()
	#for i in Globals.party.level + 1:
		#required_to_level += i * 10
	xp_to_level_label.text = "XP required to level up: %d" % required_to_level
	level_up_label.visible = false
	if Globals.party.xp >= required_to_level:
		#level up
		#print("level up %d! %d/%d required" % [Globals.party.level + 1, Globals.party.xp, required_to_level])
		Globals.party.level += 1
		var stat_gain_str := Globals.party.level_up_stats(Globals.party.level)
		level_up_label.visible = true
		level_up_label.text = "Level up! Level %d! Stats gained: %s" % [Globals.party.level, stat_gain_str]
	#heal after battle
	for p in Globals.party.p:
		p["hp"] = p["stats"].hp
		#restore half mp after battles for now?
		p["mp"] = clampi(p["mp"] + p["stats"].mp / 2, 0, p["stats"].mp)
	#keep track of what enemies we've defeated so we can show full inspect info/learn their abilities
	for en in enemy_names:
		if not Globals.party.fought_enemies.has(en):
			Globals.party.fought_enemies.append(en)
	#check item drops
	var found_items := []
	for de in defeated_enemies:
		for i in de.item_pulls:
			var pick := randf()
			var accum := 0.0
			for ip in de.item_drops.keys():
				accum += de.item_drops[ip]
				if pick <= accum:
					found_items.append(ip)
					break
	got_item_label.text = "Got item(s): "
	for fi in found_items:
		got_item_label.text += "%s, " % fi
		got_item_label.text = got_item_label.text.trim_suffix(", ")
		if Globals.inventory.inv.has(fi):
			Globals.inventory.inv[fi] += 1
		else:
			Globals.inventory.inv[fi] = 1
	Globals.bad_end_dialogue = null
	Globals.bad_end_block = null
	
	
func battle_lost():
	if Globals.bad_end_dialogue:
		Globals.main.start_dialogue(Globals.bad_end_dialogue, Globals.bad_end_block)
		Globals.bad_end_dialogue = null
		Globals.bad_end_block = null
		Events.battle_end.emit(false)
	else:
		get_tree().change_scene_to_file("res://src/gameover.tscn")


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
		if a == "punch":
			continue
		var b := Button.new()
		b.text = a.capitalize()
		b.pressed.connect(func ():
			curr_ability = a
			_on_cancel_button_pressed()
			disable_buttons()
			#TODO for party targets, target party instead. New cam position, new target code
			show_targeting()
			if enemies.size() == 1 or Abilities.abilities[curr_ability]["effect"] == 1 or Abilities.abilities[curr_ability]["effect"] == 4:
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
			if total_turns < enemies.size():
				turns += num
				total_turns += abs(num)
				#print("Added a turn - %d/%d" % [turns, total_turns])
		else:
			if total_turns < Globals.party.num_alive():
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
	

func animate_sprite(target:int, is_hit:=true):
	var the_target : Sprite3D
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	if target >= 0:
		the_target = enemies[target]["ingame_sprite"]
		enemies[target]["anim_tween"] = t
	else:
		the_target = Globals.party.p[abs(target) - 1]["ingame_sprite"]
	if is_hit:
		t.tween_property(the_target, "position:y", the_target.position.y + 0.25, 0.1)
		t.tween_property(the_target, "position:y", the_target.position.y, 0.1)
	else:
		if target >= 0:
			t.tween_property(the_target, "position:x", the_target.position.x - 0.25, 0.1)
		else:
			t.tween_property(the_target, "position:x", the_target.position.x + 0.25, 0.1)
		t.tween_property(the_target, "position:x", the_target.position.x, 0.1)
			

func _on_inspect_button_pressed() -> void:
	#TODO allow inspection of party
	disable_buttons()
	show_targeting(false)
	inspect_container.visible = true


func _on_inspect_cancel_button_pressed() -> void:
	enable_buttons()
	hide_targeting()
	inspect_container.visible = false


func _on_end_battle_button_pressed() -> void:
	# fade out
	%FadeRect.visible = true
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(%FadeRect, "modulate", Color.BLACK, 2)
	t.tween_callback(Events.battle_end.emit)
