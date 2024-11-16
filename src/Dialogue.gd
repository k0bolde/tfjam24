extends Control
class_name Dialogue

@onready var speaker_label : Label = %SpeakerLabel
@onready var dialogue_label : RichTextLabel = %DialogueLabel
@onready var portrait_texture : TextureRect = %PortraitTexture
@onready var sting_player : AudioStreamPlayer = %StingPlayer
@onready var speaker_container : Container = %SpeakerContainer
@onready var option_container : Container = %OptionContainer
@onready var option_button_container : Container = %OptionButtonContainer

var dialogue := ClydeDialogue.new()
#before adding this scene, set this to the clyde dialogue filepath
var dialogue_to_load : String
var _external_persistence := {}
var fade_tween : Tween
var is_waiting_for_choice := false
var text_anim_tween : Tween
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
	"Jesse": "res://assets/portraits/jesse2.png",
	"Some Guy": "res://assets/portraits/jesse1.png",
	"Mark": "res://assets/portraits/mark-portrait.png",
	"Zal": "res://assets/portraits/zal.png",
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
		#TODO don't do a naughty global call
		Globals.player.is_talking = false
		var t := get_tree().create_tween()
		t.set_trans(Tween.TRANS_SINE)
		t.set_parallel()
		t.tween_property(%DialogueContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(speaker_container, "rotation_degrees", 90, 0.5)
		t.tween_property(%PortraitContainer, "rotation_degrees", 90, 0.5)
		t.tween_property(%FadeRect, "modulate", Color(0, 0, 0, 0), 0.5)
		t.set_parallel(false)
		t.tween_callback(Events.dialogue_ended.emit)
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
		speaker_label.text = speaker
		speaker_container.visible = true
		portrait_texture.visible = true
		if portraits.has(speaker):
			portrait_texture.texture = load(portraits[speaker])
		else:
			portrait_texture.visible = false
	else:
		speaker_container.visible = false
		portrait_texture.visible = false
	dialogue_label.visible_ratio = 0.0
	dialogue_label.text = content.text
	text_anim_tween = Globals.get_tween(text_anim_tween, self)
	text_anim_tween.tween_property(dialogue_label, "visible_ratio", 1.0, dialogue_label.text.length() / 80.0)
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
	if not is_waiting_for_choice and event.is_action_pressed("interact"):
		#TODO wait an extra click or a certain amount of time so the player could presumably read it. Pause blink timer until such a state
		if text_anim_tween.is_running():
			text_anim_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
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
