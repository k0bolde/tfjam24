extends Control
@onready var settings_panel : PanelContainer = %SettingsPanel
@onready var fullscreen_checkbutton : CheckButton = %FullscreenCheckButton
@onready var menu_container : Container = %MenuContainer
@onready var debug_container : Container = %DebugContainer
@onready var debug_maps_container : Container = %DebugMapsContainer
@onready var flag_container : Container = %FlagContainer


func _ready() -> void:
	%DebugButton.visible = OS.is_debug_build()
	menu_container.rotation_degrees = 90.0
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 0.0, 0.35)
	%CashLabel.text = "$%s" % Globals.cash
	var map_dir := DirAccess.open("res://src/maps")
	for m in map_dir.get_files():
		if m.ends_with(".tscn"):
			var mb := Button.new()
			var map_name := m.trim_suffix(".tscn")
			mb.text = map_name
			mb.pressed.connect(func (): Globals.main.load_map(map_name))
			debug_maps_container.add_child(mb)
	for f in Globals.main.story_flags.keys():
		var l := Label.new()
		l.text = f
		flag_container.add_child(l)
		var s := SpinBox.new()
		s.update_on_text_changed = true
		s.value = Globals.main.story_flags[f]
		s.value_changed.connect(func (new_value): Globals.main.story_flags[f] = new_value)
		flag_container.add_child(s)


func _on_close_button_pressed() -> void:
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 90.0, 0.1)
	t.tween_callback(queue_free)


func _on_main_menu_button_pressed() -> void:
	#TODO warning for not saving
	get_tree().change_scene_to_file("res://src/TitleScreen.tscn")


func disable_buttons():
	for butt in get_tree().get_nodes_in_group("disableable"):
		butt.disabled = true
	
	
func enable_buttons():
	for butt in get_tree().get_nodes_in_group("disableable"):
		butt.disabled = false


func _on_settings_button_pressed() -> void:
	if settings_panel.visible:
		enable_buttons()
		settings_panel.visible = false
	else:
		disable_buttons()
		%SettingsButton.disabled = false
		settings_panel.visible = true
		fullscreen_checkbutton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		%VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))


func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
		if toggled_on:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_slider_value_changed(value: float) -> void:
	#print("db was %s" % AudioServer.get_bus_volume_db(0))
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_save_button_pressed() -> void:
	#TODO warning for overwriting save
	Globals.save_game()


func _on_load_button_pressed() -> void:
	Globals.load_game()


func _on_debug_button_pressed() -> void:
	debug_container.visible = not debug_container.visible
