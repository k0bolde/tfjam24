extends Control
class_name Dialogue

@onready var speaker_label : Label = %SpeakerLabel
@onready var dialogue_label : Label = %DialogueLabel
@onready var portrait_texture : TextureRect = %PortraitTexture
@onready var sting_player : AudioStreamPlayer = %StingPlayer

var dialogue := ClydeDialogue.new()
#before adding this scene, set this to the clyde dialogue filepath
var dialogue_to_load : String
var _external_persistence := {}
var fade_tween : Tween
var portraits := {
	"finley": "res://assets/portraits/finley1.png",
	"sock": "res://assets/portraits/SockFullDefault1.png",
}

func _ready() -> void:
	dialogue.load_dialogue(dialogue_to_load)

	dialogue.event_triggered.connect(_on_event_triggered)
	dialogue.variable_changed.connect(_on_variable_changed)

	dialogue.on_external_variable_fetch(_on_external_variable_fetch)
	dialogue.on_external_variable_update(_on_external_variable_update)
	
	_get_next_dialogue_line()
	
	%DialogueContainer.rotation_degrees = 90
	%PortraitContainer.rotation_degrees = 90
	%FadeRect.modulate = Color(0, 0, 0, 0)
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_parallel()
	t.tween_property(%DialogueContainer, "rotation_degrees", 0, 0.5)
	t.tween_property(%PortraitContainer, "rotation_degrees", 0, 0.5)
	t.tween_property(%FadeRect, "modulate", Color8(0, 0, 0, 100), 0.5)
	
	
func _get_next_dialogue_line():
	var content = dialogue.get_content()
	if content.type == "end":
		#TODO don't do a naughty global call
		Globals.player.is_talking = false
		var t := get_tree().create_tween()
		t.set_trans(Tween.TRANS_SINE)
		t.set_parallel()
		t.tween_property(%DialogueContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(%PortraitContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(%FadeRect, "modulate", Color(0, 0, 0, 0), 0.5)
		t.set_parallel(false)
		t.tween_callback(Events.dialogue_ended.emit)
		t.tween_callback(queue_free)

	if content.type == 'line':
		_set_up_line(content)
		#_line_container.show()
		#_options_container.hide()
	#else:
		#_set_up_options(content)
		#_options_container.show()
		#_line_container.hide()


func _set_up_line(content):
	var speaker = content.get('speaker')
	if speaker:
		speaker_label.text = speaker
		speaker_label.visible = true
		portrait_texture.visible = true
		if portraits.has(speaker):
			portrait_texture.texture = load(portraits[speaker])
	else:
		speaker_label.visible = false
		portrait_texture.visible = false
	dialogue_label.text = content.text
	if content.tags.has("fade_to_black"):
		fade_tween = Globals.get_tween(fade_tween, self)
		fade_tween.tween_property(%FadeRect, "modulate", Color.BLACK, 5)
	if content.tags.has("sad"):
		sting_player.stream = load("res://assets/audio/sad sting.mp3")
		sting_player.play()


#TODO implement choices
#func _set_up_options(options):
	#for c in _options_container.get_node("items").get_children():
		#c.queue_free()
#
	#_options_container.get_node("name").text = options.get('name') if options.get('name') != null else ''
	#_options_container.get_node("speaker").text = options.get('speaker') if options.get('speaker') != null else ''
	#_options_container.get_node("speaker").visible = _options_container.get_node("speaker").text != ""
#
	#var index = 0
	#for option in options.options:
		#var btn = Button.new()
		#btn.text = option.label
		#btn.connect("button_down",Callable(self,"_on_option_selected").bind(index))
		#_options_container.get_node("items").add_child(btn)
		#index += 1


func _on_option_selected(index):
	dialogue.choose(index)
	_get_next_dialogue_line()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		#TODO wait an extra click or a certain amount of time so the player could presumably read it. Pause blink timer until such a state
		_get_next_dialogue_line()
	
	
func _on_event_triggered(event_name):
	print("Event received: %s" % event_name)


func _on_variable_changed(variable_name, new_value, previous_value):
	print("variable changed: %s old %s new %s" % [variable_name, previous_value, new_value])
	
	
# if it tried to access { @health }, this method would be called and return the value from
# _external_persistence["health"]
func _on_external_variable_fetch(variable_name: String):
	return _external_persistence[variable_name]


# This method is called when the dialogue tries to set an external variable. i.e { set @health = 10 }
func _on_external_variable_update(variable_name: String, value: Variant):
	_external_persistence[variable_name] = value


func _on_blink_timer_timeout() -> void:
	%NextIndicator.visible = not %NextIndicator.visible
