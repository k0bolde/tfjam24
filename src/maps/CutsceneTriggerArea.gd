extends Area2D
# if it has a child node named "Remove" it removes it after the flag is set

@export_file("*.clyde") var dialogue : String
@export var flag_type := "main"
## the story_flag[flag_type] to activate this area
@export var story_flag := 0
## set to true to always trigger this cutscene
@export var always_trigger := false
@export var trigger_once_per_load := false
var triggered := false


func _ready() -> void:
	body_entered.connect(_body_entered)
	
	if Globals.main.story_flags[flag_type] > story_flag and has_node("Remove"):
		get_node("Remove").queue_free()
	if has_node("Add"):
		var enabled : bool = Globals.main.story_flags[flag_type] > story_flag
		get_node("Add").visible = enabled
		for c in get_node("Add").get_children():
			if c is NPC:
				c.enabled = enabled
				if enabled:
					c.process_mode = Node.PROCESS_MODE_INHERIT
				else:
					c.process_mode = Node.PROCESS_MODE_DISABLED
	if has_node("Equal"):
		var enabled : bool = Globals.main.story_flags[flag_type] == story_flag
		get_node("Equal").visible = enabled
		for c in get_node("Equal").get_children():
			if c is NPC:
				c.enabled = enabled
				if enabled:
					c.process_mode = Node.PROCESS_MODE_INHERIT
				else:
					c.process_mode = Node.PROCESS_MODE_DISABLED
		
		
	
func _body_entered(_body):
	if dialogue and (Globals.main.story_flags[flag_type] == story_flag or always_trigger or (trigger_once_per_load and not triggered)):
		Events.dialogue_ended.connect(_dialogue_ended)
		Globals.main.start_dialogue(dialogue)
		triggered = true
		
		
func _dialogue_ended():
	Events.dialogue_ended.disconnect(_dialogue_ended)
	if not always_trigger and not trigger_once_per_load:
		Globals.main.story_flags[flag_type] = story_flag + 1
	# what to do when the dialogue ends - based on the story flag
	if flag_type == "main":
		match story_flag:
			0:
				Globals.main.player.player_sprite.texture = load("res://assets/overworld/finley2-ow.png")
			2:
				#start tutorial battle against some guy
				Events.battle_start.emit(["some guy"], false)
				Globals.main.start_dialogue("res://assets/dialogue/t_3.clyde")
			3:
				Globals.party.num = 2
			4:
				Events.battle_start.emit(["mutant man", "mutant woman"], false)
				Globals.main.start_dialogue("res://assets/dialogue/t_6.clyde")
			5:
				Events.battle_start.emit(["gat cat", "lion mutant"], false)
				Globals.main.start_dialogue("res://assets/dialogue/t_8.clyde")
			7:
				#fill mp after tutorial
				Globals.party.p[0]["mp"] = Globals.party.p[0].stats.mp
				Globals.party.p[1]["mp"] = Globals.party.p[1].stats.mp
				Globals.party.p[1]["image"] = "res://assets/battle/jesse2.png"
			10:
				#finley tf
				Globals.party.p[0]["image"] = "res://assets/battle/finley3.png"
				Globals.main.player.player_sprite.texture = load("res://assets/overworld/finley3-ow.png")
				Globals.party.p[0].stats.abilities.append("freezing breath")
				Globals.party.p[0].stats.abilities.append("egg lay")
			13:
				#jesse tf
				Globals.party.p[1]["image"] = "res://assets/tv_sprites/player_chars/jesse3.png"
				Globals.party.p[1].stats.abilities.append("Howl UwU")
				Globals.party.p[1].stats.abilities.append("distract :3c")
	
	if has_node("Remove"):
		get_node("Remove").queue_free()


func _on_remove_timer_timeout() -> void:
	if Globals.main.story_flags[flag_type] > story_flag and has_node("Remove"):
		get_node("Remove").queue_free()
	if has_node("Add"):
		var enabled : bool = Globals.main.story_flags[flag_type] > story_flag
		get_node("Add").visible = enabled
		for c in get_node("Add").get_children():
			if c is NPC:
				c.enabled = enabled
				if enabled:
					c.process_mode = Node.PROCESS_MODE_INHERIT
				else:
					c.process_mode = Node.PROCESS_MODE_DISABLED
	if has_node("Equal"):
		var enabled : bool = Globals.main.story_flags[flag_type] == story_flag
		get_node("Equal").visible = enabled
		for c in get_node("Equal").get_children():
			if c is NPC:
				c.enabled = enabled
				if enabled:
					c.process_mode = Node.PROCESS_MODE_INHERIT
				else:
					c.process_mode = Node.PROCESS_MODE_DISABLED
		
