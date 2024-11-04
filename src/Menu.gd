extends Control
@onready var settings_panel : PanelContainer = %SettingsPanel
@onready var fullscreen_checkbutton : CheckButton = %FullscreenCheckButton
@onready var menu_container : Container = %MenuContainer


func _ready() -> void:
	if OS.is_debug_build():
		%DebugButton.visible = true
	menu_container.rotation_degrees = 90.0
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 0.0, 0.35)
	%CashLabel.text = "$%s" % Globals.cash


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
