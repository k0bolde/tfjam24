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
	#Setup all the enemy data
	var e := Enemy.new()
	e.enemy_name = "rat"
	e.texture_path = "res://assets/new Boss Monsters & Minions Complete Spritesheet_x.png"
	e.region_rect = Rect2(256, 512, 64, 64)
	enemies[e.enemy_name] = e
	
	e = Enemy.new()
	e.enemy_name = "slime"
	e.texture_path = "res://assets/new Boss Monsters & Minions Complete Spritesheet_x.png"
	e.region_rect = Rect2(256 + 64, 512, 64, 64)
	enemies[e.enemy_name] = e
	
	if OS.is_debug_build():
		party.p[0].stats.abilities.push_back("fire breath")


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
