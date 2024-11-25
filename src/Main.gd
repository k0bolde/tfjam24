extends Node2D
# Handles loading new maps, the player, loading/closing battles
#TODO how to regen mp? after fights? reset when moved back to hub? sleep on couch?
#TODO don't repeat start of hub dialogues while on same map
#TODO change party abilities in lab
#TODO save slots
#TODO qz shortcut - use cutscene triggers to load different npcs
#TODO items
#	use in battle
#	stores
#TODO party follows in dungeon

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
	"main" : 0,
	"jesse": 0,
	"ulla": 0,
	#"ceron": 0,
	
	"qz": 0,
	"qz_security_lizard": 0,
	#"factory": 0,
	#"office": 0,
	#"lab": 0
}
var hub
var quarantine_zone
var after_battle_dialogue
var after_battle_block := ""


func _ready() -> void:
	Globals.player = player 
	Globals.main = self
	Globals.party.num = 1
	AudioServer.set_bus_volume_db(0, -30)
	#print("%f %f" % [db_to_linear(-80), db_to_linear(24)])

	Events.battle_start.connect(start_battle)
	Events.battle_end.connect(end_battle)
	Events.dialogue_start.connect(start_dialogue)
	
	load_map("Apartment")
	# hub uses big tilesets so it lags when loading, preload it
	ResourceLoader.load_threaded_request("res://src/maps/Hub.tscn")
	ResourceLoader.load_threaded_request("res://src/maps/QuarantineZone.tscn")
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
		elif not is_battle_up() and not is_dialogue_up():
			menu = preload("res://src/Menu.tscn").instantiate()
			menu_node.add_child(menu)


func load_map(map_name:String, entrance_num := -1):
	if map_node.get_child_count() > 0:
		var old_map : Map = map_node.get_child(0)
		map_node.remove_child(old_map)
		old_map.queue_free()
	var new_map : Map 
	if map_name == "Hub":
		if not hub:
			# can only get this once, so save it for later for when we reuse it
			hub = ResourceLoader.load_threaded_get("res://src/maps/Hub.tscn")
		new_map = hub.instantiate()
	elif map_name == "QuarantineZone":
		if not quarantine_zone:
			quarantine_zone = ResourceLoader.load_threaded_get("res://src/maps/QuarantineZone.tscn")
		new_map = quarantine_zone.instantiate()
	else:
		new_map = load("res://src/maps/" + map_name + ".tscn").instantiate()
	map_node.add_child(new_map)
	if entrance_num >= 0 and new_map.entrances.size() >= entrance_num + 1:
		player.position = new_map.entrances[entrance_num]
	else:
		player.position = new_map.start_location
	map = new_map
	
	#handle overworld sprite changes
	if story_flags["main"] < 1:
		player.player_sprite.texture = load("res://assets/overworld/finley1-ow.png")
	elif story_flags["main"] >= 1 and story_flags["main"] < 11:
		player.player_sprite.texture = load("res://assets/overworld/finley2-ow.png")
	else:
		player.player_sprite.texture = load("res://assets/overworld/finley3-ow.png")
		
	play_music()
		

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
		play_music()
		if after_battle_dialogue:
			start_dialogue(after_battle_dialogue, after_battle_block)
			after_battle_dialogue = null
			after_battle_block = ""


func start_dialogue(clyde_file, block:=""):
	dialogue = preload("res://src/Dialogue.tscn").instantiate()
	dialogue.dialogue_to_load = clyde_file
	dialogue.block = block
	dialogue_node.add_child(dialogue)
	player.is_talking = true


func play_music():
	match map.map_name:
		"Quarantine Zone":
			music_player.stream = load("res://assets/audio/spooky music.mp3")
		_:
			music_player.stream = load("res://assets/audio/slow tempo synth thing.mp3")
	music_player.play()
	
