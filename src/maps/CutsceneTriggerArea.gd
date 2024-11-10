extends Area2D

@export_file("*.clyde") var dialogue : String
## called when cutscene is finished
@export var end_callback : Callable
## the story_flag["main"] to activate this area
@export var main_story_flag := 0

func _ready() -> void:
	body_entered.connect(_body_entered)
	
	
func _body_entered(body):
	if dialogue and Globals.main.story_flags["main"] == main_story_flag:
		Globals.main.start_dialogue(dialogue)
		Globals.main.story_flags["main"] = main_story_flag + 1
		if end_callback:
			Events.dialogue_ended.connect(cutscene_ended)
	else:
		Globals.main.start_cutscene()
		
		
func cutscene_ended():
	end_callback.call()
	Events.dialogue_ended.disconnect(cutscene_ended)
