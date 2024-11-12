extends Area2D
# if it has a child node named "Remove" it removes it after the flag is set

@export_file("*.clyde") var dialogue : String
@export var flag_type := "main"
## the story_flag[flag_type] to activate this area
@export var story_flag := 0


func _ready() -> void:
	body_entered.connect(_body_entered)
	
	if Globals.main.story_flags[flag_type] > story_flag and has_node("Remove"):
		get_node("Remove").queue_free()
	
	
func _body_entered(body):
	if dialogue and Globals.main.story_flags[flag_type] == story_flag:
		Events.dialogue_ended.connect(_dialogue_ended)
		Globals.main.start_dialogue(dialogue)
		
		
func _dialogue_ended():
	Events.dialogue_ended.disconnect(_dialogue_ended)
	Globals.main.story_flags[flag_type] = story_flag + 1
	# what to do when the dialogue ends - based on the story flag
	match story_flag:
		2:
			#start tutorial battle against some guy
			Events.battle_start.emit(["some guy"], false)
			Globals.main.start_dialogue("res://assets/dialogue/t_3.clyde")
		4:
			Events.battle_start.emit(["mutant man", "mutant woman"], false)
			Globals.main.start_dialogue("res://assets/dialogue/t_6.clyde")
		5:
			Events.battle_start.emit(["gat cat", "lion man"], false)
			Globals.main.start_dialogue("res://assets/dialogue/t_8.clyde")
		6:
			Events.battle_start.emit(["ceron1"], false)
			Globals.main.start_dialogue("res://assets/dialogue/t_10.clyde")
			
	
	if has_node("Remove"):
		get_node("Remove").queue_free()
