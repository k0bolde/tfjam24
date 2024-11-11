extends Node2D
# Handles loading new maps, the player, loading/closing battles
#TODO tutorial scripting
#TODO battle

@onready var player = $Player
@onready var menu_node = $MenuNode
@onready var map_node = $MapNode
@onready var battle_node = $BattleNode
@onready var dialogue_node = $DialogueNode
@onready var music_player : AudioStreamPlayer = $MusicPlayer

var battle : Battle
var map : Map
var dialogue : Dialogue
var menu
var day := 1
var story_flags := {
	# 0 - new game
	# 1 - intro done
	# 2 - tutorial done
	"main" : 0,
	"jesse": 0,
	"sock": 0,
	"ceron": 0,
	
	"quarantine": 0,
	"factory": 0,
	"office": 0,
	"lab": 0
}


func _ready() -> void:
	Globals.player = player 
	Globals.main = self
	AudioServer.set_bus_volume_db(0, -30)
	#print("%f %f" % [db_to_linear(-80), db_to_linear(24)])
	
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
	
	
	Events.battle_start.connect(start_battle)
	Events.battle_end.connect(end_battle)
	Events.dialogue_start.connect(start_dialogue)
	
	load_map("Apartment")
	# hub uses big tilesets so it lags when loading, preload it
	#ResourceLoader.load_threaded_request("res://src/maps/Hub.tscn")
	Globals.load2()


func is_menu_up() -> bool:
	return menu_node.get_child_count() > 0
	
	
func is_battle_up() -> bool:
	return battle_node.get_child_count() > 0
	
	
func is_dialogue_up() -> bool:
	return dialogue_node.get_child_count() > 0
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if is_menu_up():
			menu._on_close_button_pressed()
			#menu_node.remove_child(menu)
			#menu.queue_free()
		elif not is_battle_up() and not is_dialogue_up():
			menu = preload("res://src/Menu.tscn").instantiate()
			menu_node.add_child(menu)


func load_map(map_name:String, entrance_num := -1):
	if map_node.get_child_count() > 0:
		var old_map : Map = map_node.get_child(0)
		map_node.remove_child(old_map)
		old_map.queue_free()
	var new_map : Map 
	#if map_name == "Hub":
		#new_map = ResourceLoader.load_threaded_get("res://src/maps/Hub.tscn").instantiate()
	#else:
	new_map = load("res://src/maps/" + map_name + ".tscn").instantiate()
	map_node.add_child(new_map)
	if entrance_num >= 0 and new_map.entrances.size() >= entrance_num + 1:
		player.position = new_map.entrances[entrance_num]
	else:
		player.position = new_map.start_location


func start_battle(monsters:Array, can_run:bool):
	Globals.player.cam.enabled = false
	Globals.player.is_battling = true
	battle = preload("res://src/Battle.tscn").instantiate()
	battle.enemy_names = monsters
	battle.can_run = can_run
	battle_node.add_child(battle)
	music_player.stream = preload("res://assets/audio/battle theme.mp3")
	music_player.play()
	
	
func end_battle():
	if is_battle_up():
		battle_node.remove_child(battle)
		battle.queue_free()
		music_player.stop()
		Globals.player.cam.enabled = true
		Globals.player.is_battling = false


func start_dialogue(clyde_file):
	dialogue = preload("res://src/Dialogue.tscn").instantiate()
	dialogue.dialogue_to_load = clyde_file
	dialogue_node.add_child(dialogue)
	player.is_talking = true
