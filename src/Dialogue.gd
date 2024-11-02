extends Control
class_name Dialogue

var dialogue := ClydeDialogue.new()
#before adding this scene, set this to the clyde dialogue filepath
var dialogue_to_load : String
var _external_persistence := {}
@onready var speaker_label : Label = %SpeakerLabel
@onready var dialogue_label : Label = %DialogueLabel

func _ready() -> void:
	dialogue.load_dialogue(dialogue_to_load)

	dialogue.event_triggered.connect(_on_event_triggered)
	dialogue.variable_changed.connect(_on_variable_changed)

	dialogue.on_external_variable_fetch(_on_external_variable_fetch)
	dialogue.on_external_variable_update(_on_external_variable_update)
	
	call_deferred("_get_next_dialogue_line")
	#_get_next_dialogue_line()
	
	
func _get_next_dialogue_line():
	var content = dialogue.get_content()
	if content.type == "end":
		#TODO don't do a naughty global call
		Globals.player.is_talking = false
		queue_free()

	if content.type == 'line':
		_set_up_line(content)
		#_line_container.show()
		#_options_container.hide()
	#else:
		#_set_up_options(content)
		#_options_container.show()
		#_line_container.hide()


func _set_up_line(content):
	#TODO load the right character portrait
	speaker_label.text = content.get('speaker') if content.get('speaker') != null else ''
	dialogue_label.text = content.text

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
