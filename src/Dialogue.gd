extends Control
class_name Dialogue
#TODO don't repeat intros for some characters
#TODO glenys
#TODO half hp dialogue
#TODO fight won dialogue

@onready var speaker_label : Label = %SpeakerLabel
@onready var dialogue_label : RichTextLabel = %DialogueLabel
@onready var portrait_texture : TextureRect = %PortraitTexture
@onready var sting_player : AudioStreamPlayer = %StingPlayer
@onready var speaker_container : Container = %SpeakerContainer
@onready var option_container : Container = %OptionContainer
@onready var option_button_container : Container = %OptionButtonContainer
@onready var blink_timer : Timer = %BlinkTimer
@onready var dialogue_container : MarginContainer = %DialogueContainer

var dialogue := ClydeDialogue.new()
#before adding this scene, set this to the clyde dialogue filepath
var dialogue_to_load : String
var block := ""
var fade_tween : Tween
var is_waiting_for_choice := false
var text_anim_tween : Tween
# the dupes aren't dupes, they have a zero-width space after their name. Used for changing portraits in cutscenes
var portraits := {
	"Sock": "res://assets/portraits/SockFullDefault1.png",
	"Clem": "res://assets/portraits/clem-portrait.png",
	"???": "res://assets/portraits/clem-portrait.png",
	"Rene": "res://assets/portraits/Barista_Snake_small.png",
	"Tutorial Pean": "res://assets/portraits/pean2.png",
	"Pean": "res://assets/portraits/pean1.png",
	"Byrne": "res://assets/portraits/byrne-portrait.png",
	"Morgan": "res://assets/portraits/morgan.png",
	"Bubbles": "res://assets/portraits/Bubbles.png",
	"Finley": "res://assets/portraits/finley2.png",
	#evil zero-width space
	"Jesse​": "res://assets/portraits/jesse1.png",
	"Jesse": "res://assets/portraits/jesse2.png",
	"Some Guy": "res://assets/portraits/jesse1.png",
	"Mark": "res://assets/portraits/mark-portrait.png",
	"Zal": "res://assets/portraits/zal.png",
	"Ulla Tor": "res://assets/portraits/UllaPortraitsHuman.png",
	"Security Guard": "res://assets/portraits/security.png",
	"Dark Clem": "res://assets/portraits/clem-dark.png",
	"Rend": "res://assets/portraits/rendm.png",
	"Rist": "res://assets/portraits/rist.png",
	"Rust": "res://assets/portraits/rust.png",
}


func _ready() -> void:
	dialogue.load_dialogue(dialogue_to_load, block)

	dialogue.event_triggered.connect(_on_event_triggered)
	dialogue.variable_changed.connect(_on_variable_changed)

	dialogue.on_external_variable_fetch(_on_external_variable_fetch)
	dialogue.on_external_variable_update(_on_external_variable_update)
	
	_get_next_dialogue_line()
	
	%DialogueContainer.rotation_degrees = 90
	%PortraitContainer.rotation_degrees = 90
	speaker_container.rotation_degrees = 90
	%FadeRect.modulate = Color(0, 0, 0, 0)
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_parallel()
	t.tween_property(%DialogueContainer, "rotation_degrees", 0, 0.5)
	t.tween_property(%PortraitContainer, "rotation_degrees", 0, 0.5)
	t.tween_property(speaker_container, "rotation_degrees", 0, 0.5)
	t.tween_property(%FadeRect, "modulate", Color8(0, 0, 0, 100), 0.5)
	
	
func _get_next_dialogue_line():
	var content = dialogue.get_content()
	if content.type == "end":
		var t := get_tree().create_tween()
		t.set_trans(Tween.TRANS_SINE)
		t.set_parallel()
		t.tween_property(%DialogueContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(speaker_container, "rotation_degrees", 90, 0.5)
		t.tween_property(%PortraitContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(%FadeRect, "modulate", Color(0, 0, 0, 0), 0.5)
		t.set_parallel(false)
		t.tween_callback(Events.dialogue_ended.emit)
		t.tween_property(Globals.player, "is_talking", false, 0)
		t.tween_callback(queue_free)
	elif content.type == 'line':
		_set_up_line(content)
	else:
		_set_up_options(content)
		# call_deferred because of strange bug that clicked on a different button than the user clicked sometimes
		option_container.set_deferred("visible", true)


func _set_up_line(content):
	var speaker = content.get('speaker')
	if speaker:
		dialogue_container.add_theme_constant_override("margin_left", 200)
		speaker_label.text = speaker
		speaker_container.visible = true
		portrait_texture.visible = true
		if portraits.has(speaker):
			portrait_texture.texture = load(get_portrait(speaker))
		else:
			portrait_texture.visible = false
	else:
		dialogue_container.add_theme_constant_override("margin_left", 100)
		speaker_container.visible = false
		portrait_texture.visible = false
	dialogue_label.visible_ratio = 0.0
	dialogue_label.text = content.text
	blink_timer.stop()
	%NextIndicator.visible = false
	text_anim_tween = Globals.get_tween(text_anim_tween, self)
	text_anim_tween.tween_property(dialogue_label, "visible_ratio", 1.0, dialogue_label.text.length() / 80.0)
	text_anim_tween.tween_callback(func (): blink_timer.start())
	if content.tags.has("fade_to_black"):
		fade_tween = Globals.get_tween(fade_tween, self)
		fade_tween.tween_property(%FadeRect, "modulate", Color.BLACK, 5)
	if content.tags.has("sad"):
		sting_player.stream = load("res://assets/audio/sad sting.mp3")
		sting_player.play()


func _set_up_options(options):
	is_waiting_for_choice = true

	#_options_container.get_node("name").text = options.get('name') if options.get('name') != null else ''
	#_options_container.get_node("speaker").text = options.get('speaker') if options.get('speaker') != null else ''
	#_options_container.get_node("speaker").visible = _options_container.get_node("speaker").text != ""

	var index = 0
	for option in options.options:
		var btn = Button.new()
		btn.text = option.label
		btn.pressed.connect(_on_option_selected.bind(index))
		option_button_container.add_child(btn)
		index += 1


func _on_option_selected(index):
	is_waiting_for_choice = false
	for c in option_button_container.get_children():
		c.queue_free()
	#print("sent option %d" % index)
	dialogue.choose(index)
	option_container.visible = false
	_get_next_dialogue_line()


func _input(event: InputEvent) -> void:
	if not is_waiting_for_choice \
		and event.is_action_pressed("interact") \
		and (not fade_tween.is_running() if fade_tween else true):
		if text_anim_tween.is_running():
			text_anim_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
			_get_next_dialogue_line()
	
	
func get_portrait(npc_name:String) -> String:
	match npc_name:
		"Jesse":
			if Globals.main.story_flags["main"] < 7:
				#still uses a zero-width space in the tf cutscene to change
				return portraits["Some Guy"]
			elif Globals.main.story_flags["main"] > 13:
				return "res://assets/portraits/jesse3.png"
		"Finley":
			#FIXME not working?
			if Globals.main.story_flags["main"] > 10:
				return "res://assets/portraits/finley3.png"
		"Ulla Tor":
			#TODO replace with actual flag number
			if Globals.main.story_flags["ulla"] < 16:
				return portraits["Ulla Tor"]
			#TODO replace with actual flag number
			elif Globals.main.story_flags["ulla"] < 24:
				return "res://assets/portraits/UllaPortraitsScaled.png"
			#TODO replace with actual flag number
			elif Globals.main.story_flags["ulla"] < 30:
				return "res://assets/portraits/UllaPortraitsRaptor.png"
			else:
				return "res://assets/portraits/SockFullDefault1.png"
		"Rend":
			if Globals.main.story_flags["main"] > 11:
				return "res://assets/portraits/rendf.png"
			else:
				return portraits["Rend"]
	return portraits[npc_name]
	
	
func _on_event_triggered(event_name):
	print("Event received: %s" % event_name)
	match event_name:
		"celon_fight":
			Events.battle_start.emit(["eldritch being"], false)
			Globals.main.start_dialogue("res://assets/dialogue/t_10.clyde")
		"sparkle_bad_end":
			Globals.main.start_dialogue("res://assets/dialogue/t_sparkle.clyde")
		"game_over":
			get_tree().change_scene_to_file("res://src/gameover.tscn")
		"security_fight":
			Events.battle_start.emit(["haz"], false)
			Globals.main.story_flags["main"] = 9
		"security_tf":
			#TODO change to lizard lady
			Globals.main.story_flags["main"] = 9
		"rendm_fight":
			Events.battle_start.emit(["rend"], false)
			Globals.main.start_dialogue("res://assets/dialogue/qz_rend1.clyde", "fight_start")
			#TODO fight won dialogue
		"rendf_fight":
			Events.battle_start.emit(["rend (female)"], false)
			Globals.main.start_dialogue("res://assets/dialogue/qz_rend2.clyde", "fight_start")
			#TODO fight won dialogue
		"ceron2_fight":
			Events.battle_start.emit(["eldritch being"], false)
			#TODO fight won dialogue
		"tentacle_bad_end":
			Globals.main.start_dialogue("res://assets/dialogue/qz_ceron.clyde", "bad_end")
		"jesse_bond_up":
			Globals.main.story_flags["jesse"] += 1
		"ulla_bond_up":
			Globals.main.story_flags["ulla"] += 1
		"hydra_fight":
			Events.battle_start.emit(["rust & rist hydra"], false)
		"hydra_bad_end":
			Globals.main.start_dialogue("res://assets/dialogue/qz_rustrydra.clyde", "bad_end")
		"savak_battle":
			Events.battle_start.emit(["savak"], false)
			Globals.main.start_dialogue("res://assets/dialogue/qz_savak1.clyde", "fight_start")
			#TODO fight mid/won dialogue
		"qz_shortcut_open":
			Globals.main.story_flags["qz"] = 1
		_:
			printerr("unhandled dialogue event %s" % event_name)
			
			


func _on_variable_changed(variable_name, new_value, previous_value):
	print("variable changed: %s old %s new %s" % [variable_name, previous_value, new_value])
	
	
# if it tried to access { @health }, this method would be called and return the value from
# _external_persistence["health"]
func _on_external_variable_fetch(variable_name: String):
	print("variable %s read" % variable_name)
	return Globals._external_persistence[variable_name]


# This method is called when the dialogue tries to set an external variable. i.e { set @health = 10 }
func _on_external_variable_update(variable_name: String, value: Variant):
	print("variable %s updated to value %s" % [variable_name, value])
	Globals._external_persistence[variable_name] = value


func _on_blink_timer_timeout() -> void:
	%NextIndicator.visible = not %NextIndicator.visible
