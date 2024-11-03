extends Node
# Globals can be accessed from any script - like Globals.get_tween()
# Useful for functions that are used in multiple places

#kinda nasty way to get a reference to the player - is set on startup/load by main. Should be replaced by signals
var player : Player
var main 
var save_data
var party
var inventory


func _input(event):
	if event.is_action_pressed("quit") and OS.is_debug_build():
		get_tree().quit()
		
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func get_tween(the_tween:Tween, node) -> Tween:
	if the_tween:
		the_tween.kill()
	return get_tree().create_tween().bind_node(node)


func save_game():
	save_data = Save.new()
	save_data.cash = player.cash
	save_data.location = player.global_location
	save_data.map = "main"
	save_data.day = main.day
	save_data.party = party
	save_data.inventory = inventory
	ResourceSaver.save(save_data, "user://save.tres")


func load_game():
	save_data = ResourceLoader.load("user://save.tres", "Save", ResourceLoader.CACHE_MODE_IGNORE)
	get_tree().change_scene_to_file("res://src/Main.tscn")
	
	
# This 2 stage load is kinda nasty but not sure how to get around it
func load2():
	if save_data:
		player.cash = save_data.cash
		main.load_map(save_data.map)
		player.position = save_data.location
		party = save_data.party
		inventory = save_data.inventory
		
		save_data = null
