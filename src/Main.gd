extends Node2D
# Handles loading new maps, the player, loading/closing battles
#nov 1st TODOS
#TODO dialogue system
#TODO enter battles
#TODO basic battles, kill, die, end

@onready var player = $Player
@onready var menu_node = $MenuNode
@onready var map_node = $MapNode
@onready var battle_node = $BattleNode
@onready var dialogue_node = $DialogueNode
var battle : Battle
var map : Map
var dialogue : Dialogue
var menu
var day := 1


func _ready() -> void:
	Globals.player = player 
	Globals.main = self
	#map_node.add_child(preload("res://src/maps/Map1.tscn").instantiate())
	load_map("Map1")


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


func load_map(map_name:String):
	if map_node.get_child_count() > 0:
		var old_map : Map = map_node.get_child(0)
		map_node.remove_child(old_map)
		old_map.queue_free()
	var new_map : Map = load("res://src/maps/" + map_name + ".tscn").instantiate()
	map_node.add_child(new_map)
	player.position = new_map.start_location


func start_battle():
	battle = preload("res://src/Battle.tscn").instantiate()
	battle_node.add_child(battle)
	
	
func end_battle():
	if is_battle_up():
		battle_node.remove_child(battle)
		battle.queue_free()
