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


func _ready() -> void:
	initialize_enemies()
	initialize_party()


func initialize_enemies():
	#Setup all the enemy data
	var e := Enemy.new()
	e.enemy_name = "rat"
	e.texture_path = "res://assets/tv_sprites/creatures/feral_male_werewolf_128x.png"
	e.xp_reward = 12
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "slime"
	e.texture_path = "res://assets/purple_critter.png"
	e.stats.weaknesses.push_back("fire")
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "some guy"
	e.texture_path = "res://assets/tv_sprites/player_chars/wolf_girl_128x.png"
	e.region_rect = Rect2(0, 0, 128, 128)
	e.stats.atk = 15
	e.stats.def = 0
	e.stats.eva = 0
	e.stats.lck = 0
	e.stats.abilities.append_array(["some guy punch", "some guy kick", "some guy sob"])
	e.cash_reward = 5
	e.xp_reward = 1
	e.flip_h = true
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "mutant man"
	e.texture_path = "res://assets/mutant-man.png"
	e.stats.atk = 20
	e.stats.def = 5
	e.stats.eva = 0
	e.stats.lck = 5
	e.stats.abilities.append_array(["man claw", "man tail whip", "man swipe"])
	e.cash_reward = 5
	e.xp_reward = 1
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "mutant woman"
	e.texture_path = "res://assets/mutant-woman-battle.png"
	e.stats.atk = 20
	e.stats.def = 5
	e.stats.eva = 0
	e.stats.lck = 5
	e.stats.abilities.append_array(["woman bite", "woman spray", "woman aid"])
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["dozeneggs"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "gat cat"
	e.texture_path = "res://assets/gat-cat.png"
	e.stats.atk = 20
	e.stats.def = 0
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances.push_front("rending")
	e.stats.weaknesses.push_front("fire")
	e.stats.abilities.append_array(["cat pistol shot", "cat pistol whip", "swipe"])
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["dozeneggs"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "lion mutant"
	e.texture_path = "res://assets/lion-mutant.png"
	e.stats.hp = 80
	e.stats.atk = 20
	e.stats.def = 10
	e.stats.eva = 0
	e.stats.lck = 5
	e.stats.resistances.push_front("bludgeoning")
	e.stats.weaknesses.push_front("rending")
	e.stats.abilities.append_array(["claw", "bite"])
	e.cash_reward = 5
	e.xp_reward = 1
	e.item_drops["ankrpwease"] = 1.0
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "eldritch being"
	#e.texture_path = "res://assets/new Boss Monsters & Minions Complete Spritesheet_x.png"
	e.stats.hp = 200
	e.stats.atk = 15
	e.stats.def = 10
	e.stats.eva = 10
	e.stats.lck = 10
	e.stats.resistances.append_array(["esoteric", "eldritch"])
	e.stats.weaknesses.append_array(["piercing", "fire"])
	e.stats.abilities.append_array(["tentacle whip", "shriek", "insane insight"])
	e.cash_reward = 25
	e.xp_reward = 5
	e.item_drops["dozeneggs"] = 1.0
	e.item_drops["lime time"] = 1.0
	e.flip_h = true
	enemies[e.enemy_name] = e


func initialize_party():	
	#set up starting stats for party
	Globals.party.p[0].stats.atk = 25
	Globals.party.p[0].stats.def = 0
	Globals.party.p[0].stats.eva = 5
	Globals.party.p[0].stats.lck = 5
	Globals.party.p[0].stats.resistances.push_front("fire")
	Globals.party.p[0].stats.abilities.append_array(["punch", "kick", "fire breath", "tip the scales"])
	
	Globals.party.p[1].stats.hp = 125
	Globals.party.p[1].stats.mp = 75
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


## helper method to let you safely reuse the same tween by ending anything it was doing before giving you a clean one
func get_tween(the_tween:Tween, node) -> Tween:
	if the_tween:
		the_tween.kill()
	return get_tree().create_tween().bind_node(node)


func save_game():
	save_data = Save.new()
	save_data.cash = cash
	save_data.location = player.position
	save_data.map = main.map_node.get_child(0).name
	save_data.day = main.day
	save_data.party = party
	save_data.inventory = inventory
	save_data.story_flags = main.story_flags
	ResourceSaver.save(save_data, "user://save.tres")


func load_game():
	save_data = ResourceLoader.load("user://save.tres", "Save", ResourceLoader.CACHE_MODE_IGNORE)
	get_tree().change_scene_to_file("res://src/Main.tscn")
	
	
# This 2 stage load is kinda nasty but not sure how to get around it
func load2():
	if save_data:
		cash = save_data.cash
		main.load_map(save_data.map)
		player.position = save_data.location
		party = save_data.party
		inventory = save_data.inventory
		main.story_flags = save_data.story_flags
		
		save_data = null
