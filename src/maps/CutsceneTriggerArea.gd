extends Area2D

@export_file("*.clyde") var dialogue : String
@export var flag_type := "main"
## the story_flag[flag_type] to activate this area
@export var story_flag := 0


func _ready() -> void:
	body_entered.connect(_body_entered)
	
	
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
