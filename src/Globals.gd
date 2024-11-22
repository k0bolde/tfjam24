extends Node
# Globals can be accessed from any script - like Globals.get_tween()
# Useful for functions that are used in multiple places

#kinda nasty way to get a reference to the player - is set on startup/load by main. Should be replaced by signals
var player : Player
var main 
var save_data
var party := Party.new()
var inventory
var cash := 0
var enemies := {}
var use_action_cam := false
var types := ["rending", "piercing", "bludgeoning", "fire", "ice", "mutagenic", "esoteric", "eldritch"]
var _external_persistence := {}

func _ready() -> void:
	initialize_enemies()
	initialize_party()
	Globals.party.fought_enemies.append("slime")
	
	#print("testing class member access\ndict access %s\nclass access %s" % [party.p[0]["stats"].hp, enemies["rat"]["stats"].hp])


func initialize_enemies():
	#Setup all the enemy data
	## To add a new enemy, need to setup its data here and add its specific abilities to Abilities.abilities
	var e := Enemy.new()
	e.enemy_name = "rat"
	e.desc = "A rat"
	e.texture_path = "res://assets/battle/ImpF.png"
	e.attack_probs["punch"] = 1.0
	e.xp_reward = 12
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "slime"
	e.desc = "ooey gooey slime"
	e.texture_path = "res://assets/battle/ImpM.png"
	e.attack_probs["punch"] = 1.0
	e.stats.weaknesses.push_back("fire")
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "some guy"
	e.desc = "Some guy. He doesn’t look like he’s in the proper state of mind."
	e.texture_path = "res://assets/tv_sprites/player_chars/wolf_girl_128x.png"
	e.region_rect = Rect2(0, 0, 128, 128)
	e.stats.atk = 15
	e.stats.def = 0
	e.stats.eva = 0
	e.stats.lck = 0
	e.attack_probs["some guy sob"] = 0.1
	e.attack_probs["some guy kick"] = 0.3
	e.attack_probs["some guy punch"] = 0.6
	e.cash_reward = 5
	e.xp_reward = 1
	e.flip_h = true
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "mutant man"
	e.desc = "He looks more octopus than human. He’s wearing a trash bag, \nzip lock bags for shoes, and wields an imposing fork."
	e.texture_path = "res://assets/battle/mutant-man.png"
	e.stats.atk = 20
	e.stats.def = 5
	e.stats.eva = 0
	e.stats.lck = 5
	e.attack_probs["man tail whip"] = 0.2
	e.attack_probs["man swipe"] = 0.2
	e.attack_probs["man claw"] = 0.6
	e.cash_reward = 5
	e.xp_reward = 1
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "mutant woman"
	e.desc = "She looks like she’s mutated into some sort of draconic creature.\nPart of her snout’s scales have peeled away to show only skull."
	e.texture_path = "res://assets/battle/mutant-woman-battle.png"
	e.stats.atk = 20
	e.stats.def = 5
	e.stats.eva = 0
	e.stats.lck = 5
	e.attack_probs["woman aid"] = 0.2
	e.attack_probs["woman spray"] = 0.2
	e.attack_probs["woman bite"] = 0.6
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["dozeneggs"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "gat cat"
	e.desc = "It’s a mutant cat with a gat! Is she covered in blood or ketchup!"
	e.texture_path = "res://assets/battle/gat-cat.png"
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances.push_front("rending")
	e.stats.weaknesses.push_front("fire")
	e.stats.abilities.append_array(["cat pistol shot", "cat pistol whip", "swipe"])
	e.attack_probs["cat pistol shot"] = 0.25
	e.attack_probs["swipe"] = 0.25
	e.attack_probs["cat pistol whip"] = 0.50
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["dozeneggs"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "lion mutant"
	e.desc = "It’s a mutant lion! He’s definitely covered in blood and wields a spear."
	e.texture_path = "res://assets/battle/lion-mutant.png"
	e.stats.hp = 80
	e.stats.atk = 20
	e.stats.def = 10
	e.stats.eva = 0
	e.stats.lck = 5
	e.stats.resistances.push_front("bludgeoning")
	e.stats.weaknesses.push_front("rending")
	e.attack_probs["claw"] = 0.5
	e.attack_probs["bite"] = 0.5
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["ankrpwease"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "eldritch being"
	e.desc = "What the hell is this? It looks like a suit containing writhing tentacles and quite a bust!"
	e.texture_path = "res://assets/battle/ceron1-battle.png"
	e.stats.hp = 200
	e.stats.atk = 15
	e.stats.def = 10
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances.append_array(["esoteric", "eldritch"])
	e.stats.weaknesses.append_array(["piercing", "fire"])
	e.attack_probs["tentacle whip"] = 0.6
	e.attack_probs["shriek"] = 0.2
	e.attack_probs["insane insight"] = 0.2
	e.cash_reward = 25
	e.xp_reward = 5
	e.base_turns = 2
	e.item_drops["dozeneggs"] = 1.0
	e.item_drops["lime time"] = 1.0
	e.flip_h = true
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "lvl 1 kobold"
	e.desc = "A kobold with a huge hat and a modicum of magical powers"
	e.texture_path = "res://assets/battle/mika.png"
	e.stats.hp = 125
	e.stats.atk = 15
	e.stats.def = 0
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances = ["esoteric"]
	e.stats.weaknesses = ["bludgeoning"]
	e.attack_probs["potion throw"] = 0.55
	e.attack_probs["better aid"] = 0.35
	e.attack_probs["sob"] = 0.1
	e.item_drops["ddew pamphlet"] = 0.5
	e.cash_reward = 5
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "lvl pun kobold"
	e.desc = "He keeps making puns! Kill him!"
	e.texture_path = "res://assets/battle/Omegatest.png"
	e.stats.hp = 125
	e.stats.atk = 20
	e.stats.def = 10
	e.stats.eva = 5
	e.stats.lck = 10
	e.stats.resistances = ["fire"]
	e.stats.weaknesses = ["rending"]
	e.attack_probs["potion throw"] = 0.5
	e.attack_probs["bad pun"] = 0.25
	e.attack_probs["nervous stab"] = 0.25
	e.item_drops["weird writings"] = 0.5
	e.cash_reward = 5
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "confident lizard lady"
	e.desc = "A lizard lady who is quite confident in her looks. It appears she can force other people to have them."
	e.texture_path = "res://assets/battle/confidntpurple.png"
	e.stats.hp = 150
	e.stats.atk = 25
	e.stats.def = 10
	e.stats.eva = 5
	e.stats.lck = 10
	e.attack_probs["entice"] = 0.5
	e.attack_probs["tail whip"] = 0.25
	e.attack_probs["confuse"] = 0.25
	e.item_drops["scale polish"] = 1.0
	e.cash_reward = 5
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "twinned lizard lady"
	e.desc = "Someone who has been transformed into a twin of the confident lizard lady. She seems nervous about her new curves…"
	e.texture_path = "res://assets/battle/shypurple.png"
	e.stats.hp = 150
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances = ["fire"]
	e.stats.weaknesses = ["rending"]
	e.attack_probs["claw"] = 0.5
	e.attack_probs["tail whip"] = 0.25
	e.attack_probs["better aid"] = 0.25
	e.item_drops["scale polish"] = 0.25
	e.cash_reward = 5
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "base sciraptor"
	e.desc = "A raptor-like drone creature"
	e.texture_path = "res://assets/battle/sciraptorgj.png"
	e.flip_h = true
	e.stats.hp = 150
	e.stats.atk = 25
	e.stats.def = 10
	e.stats.eva = 0
	e.stats.lck = 10
	e.stats.resistances = ["bludgeoning"]
	e.stats.weaknesses = ["piercing"]
	e.attack_probs["tail whip"] = 0.25
	e.attack_probs["claw"] = 0.5
	e.attack_probs["self repair"] = 0.25
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "elite sciraptor"
	e.desc = "A sciraptor that orders the others around. It’s mad!"
	e.texture_path = "res://assets/battle/sciraptorleadergj.png"
	e.flip_h = true
	e.stats.hp = 200
	e.stats.atk = 20
	e.stats.def = 10
	e.stats.eva = 0
	e.stats.lck = 10
	e.stats.resistances = ["bludgeoning"]
	e.stats.weaknesses = ["piercing"]
	e.attack_probs["tail whip"] = 0.33
	e.attack_probs["claw"] = 0.33
	e.attack_probs["inspire"] = 0.34
	e.xp_reward = 3
	enemies[e.enemy_name] = e
	
	#TODO is it ok to overwrite the tutorial one?
	e = Enemy.new()
	e.enemy_name = "mutant man"
	e.desc = "An awfully mutated man wearing a trashbag and ziplock shoes"
	e.texture_path = "res://assets/battle/mutant-man.png"
	e.stats.hp = 100
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 10
	e.stats.lck = 10
	e.attack_probs["punch"] = 0.6
	e.attack_probs["tentacle whip"] = 0.4
	e.xp_reward = 2
	e.item_drops["prop axe"] = 0.25
	e.cash_reward = 5
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "glorp"
	e.texture_path = "res://assets/battle/monster.png"
	e.stats.hp = 200
	e.stats.atk = 20
	e.stats.def = 20
	e.stats.eva = 0
	e.stats.lck = 5
	e.stats.resistances = ["bludgeoning", "rending"]
	e.stats.weaknesses = ["piercing", "fire"]
	e.attack_probs["stare"] = 0.25
	e.attack_probs["claw"] = 0.6
	e.attack_probs["spray"] = 0.15
	e.xp_reward = 5
	e.cash_reward = 7
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "moth"
	e.desc = "A moth woman wielding a mutagenic drug. She’s flighty but loyal to the hive."
	e.texture_path = "res://assets/battle/Moth.png"
	e.stats.hp = 120
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 30
	e.stats.lck = 15
	e.stats.resistances = ["mutagenic"]
	e.stats.weaknesses = ["fire"]
	e.attack_probs["syringe shot"] = 0.75
	e.attack_probs["confuse"] = 0.25
	e.xp_reward = 3
	e.cash_reward = 5
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "ant"
	e.desc = "An ant soldier wielding a syringe gun. She’s loyal to the hive."
	e.texture_path = "res://assets/battle/ANTnano.png"
	e.stats.hp = 150
	e.stats.atk = 30
	e.stats.def = 10
	e.stats.eva = 15
	e.stats.lck = 5
	e.stats.resistances = ["mutagenic"]
	e.stats.weaknesses = ["fire"]
	e.attack_probs["syringe shot"] = 0.75
	e.attack_probs["pistol whip"] = 0.25
	e.xp_reward = 3
	e.item_drops["empty rifle"] = 0.5
	e.cash_reward = 5
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "elite ant"
	e.desc = "An ant officer wielding a syringe gun. Her loyalty to the hive is unwavering."
	e.texture_path = "res://assets/battle/AntSyndi.png"
	e.stats.hp = 200
	e.stats.atk = 30
	e.stats.def = 15
	e.stats.eva = 20
	e.stats.lck = 10
	e.stats.resistances = ["mutagenic"]
	e.stats.weaknesses = ["fire"]
	e.attack_probs["syringe shot"] = 0.33
	e.attack_probs["spray"] = 0.25
	e.attack_probs["inspire"] = 0.42
	e.xp_reward = 5
	e.item_drops["ankrpwease"] = 0.25
	e.cash_reward = 7
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "mutagenic mouse"
	e.desc = "A large mouse wielding a large syringe"
	e.texture_path = "res://assets/battle/mutarat.png"
	e.stats.hp = 150
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 15
	e.stats.lck = 7
	e.attack_probs["swipe"] = 0.6
	e.attack_probs["spray"] = 0.2
	e.attack_probs["inspire"] = 0.2
	e.xp_reward = 3
	e.item_drops["spare syringe"] = 1.0
	e.cash_reward = 5
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "gallivanting goat"
	e.desc = "A goat who appears to be very happy with what she is and wants you to be like her too!"
	e.texture_path = "res://assets/battle/panflutesexual.png"
	e.stats.hp = 150
	e.stats.atk = 25
	e.stats.def = 10
	e.stats.eva = 15
	e.stats.lck = 10
	e.attack_probs["kick"] = 0.5
	e.attack_probs["entice"] = 0.25
	e.attack_probs["confuse"] = 0.25
	e.xp_reward = 3
	e.item_drops["dancing does"] = 0.5
	e.cash_reward = 5
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "haz"
	e.desc = "A man who is supposed to be keeping this area contained. It doesn’t seem like he’s doing a good job…"
	e.texture_path = "res://assets/battle/guard.png"
	e.stats.hp = 150
	e.stats.atk = 20
	e.stats.def = 10
	e.stats.eva = 5
	e.stats.lck = 10
	e.stats.weaknesses = ["mutagenic", "rending"]
	e.attack_probs["punch"] = 0.5
	e.attack_probs["kick"] = 0.25
	e.attack_probs["fortify"] = 0.25
	e.xp_reward = 3
	e.item_drops["clem's pills"] = 0.33
	e.cash_reward = 4
	enemies[e.enemy_name] = e
	
	

func verify_enemies():
	#TODO check that item drop exists
	for e in enemies.values():
		if e.desc == "Default Description":
			printerr("%s is missing desc" % e.enemy_name)
		if e.attack_probs.is_empty():
			printerr("%s is missing any attacks" % e.enemy_name)
		#check that every attack_probs is in Abilities.abilities
		var atk_accum := 0.0
		for attack in e.attack_probs:
			atk_accum += e.attack_probs[attack]
			if not Abilities.abilities.has(attack):
				printerr("Abilities.abilities missing %s" % attack)
		if not is_equal_approx(atk_accum, 1.0):
			printerr("%s attack probs don't add up to 1.0" % e.enemy_name)
		for type in e.stats.resistances:
			if not types.has(type):
				printerr("%s resistances has unknown type %s" % [e.enemy_name, type])
		for type in e.stats.weaknesses:
			if not types.has(type):
				printerr("%s weaknesses has unknown type %s" % [e.enemy_name, type])
		#I don't think order matters?
		#check that attack_probs adds up to 1.0 and is in ascending order
		#var last_prob := 0.0
		#for attack in e.attack_probs:
			#if e.attack_probs[attack] < last_prob:
				#printerr("attack probs in wrong order for %s" % e.enemy_name)
			#last_prob = e.attack_probs[attack]


func initialize_party():	
	#set up starting stats for party
	#Globals.party.p[0].stats.hp = 10
	Globals.party.p[0].stats.atk = 25
	Globals.party.p[0].stats.def = 0
	Globals.party.p[0].stats.eva = 5
	Globals.party.p[0].stats.lck = 5
	Globals.party.p[0].stats.resistances.push_front("fire")
	Globals.party.p[0].stats.abilities.append_array(["punch", "kick", "fire breath", "tip the scales"])
	
	Globals.party.p[1].stats.hp = 125
	Globals.party.p[1].stats.mp = 75
	Globals.party.p[1].mp = 75
	Globals.party.p[1].stats.atk = 35
	Globals.party.p[1].stats.def = 5
	Globals.party.p[1].stats.eva = 10
	Globals.party.p[1].stats.lck = 0
	Globals.party.p[1].stats.resistances.push_front("bludeoning")
	Globals.party.p[1].stats.abilities.append_array(["punch", "swipe", "recovery strike", "wild wolf"])


func _input(event):
	if event.is_action_pressed("quit") and OS.is_debug_build():
		get_tree().quit()
		
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if player:
		if event.is_action_pressed("sprint"):
			player.is_sprinting = true
		if event.is_action_released("sprint"):
			player.is_sprinting = false


## helper method to let you safely reuse the same tween by ending anything it was doing before giving you a clean one
func get_tween(the_tween:Tween, node) -> Tween:
	if the_tween:
		the_tween.kill()
	return get_tree().create_tween().bind_node(node)


#Windows: %APPDATA%\Godot\app_userdata\[project_name]
#macOS: ~/Library/Application Support/Godot/app_userdata/[project_name]
#Linux: ~/.local/share/godot/app_userdata/[project_name]
func save_game():
	save_data = Save.new()
	save_data.cash = cash
	save_data.location = player.position
	save_data.map = main.map_node.get_child(0).name
	save_data.day = main.day
	save_data.party = party
	save_data.inventory = inventory
	save_data.story_flags = main.story_flags
	save_data.use_action_cam = use_action_cam
	ResourceSaver.save(save_data, "user://save.tres")


func load_game():
	save_data = ResourceLoader.load("user://save.tres", "Save", ResourceLoader.CACHE_MODE_IGNORE)
	get_tree().change_scene_to_file("res://src/Main.tscn")
	
	
# This 2 stage load is kinda nasty but not sure how to get around it
func load2():
	if save_data:
		cash = save_data.cash
		party = save_data.party
		inventory = save_data.inventory
		use_action_cam = save_data.use_action_cam
		main.story_flags = save_data.story_flags
		main.load_map(save_data.map)
		player.position = save_data.location
		
		save_data = null
