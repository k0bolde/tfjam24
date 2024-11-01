extends Control
@onready var settings_panel : Panel = %SettingsPanel
@onready var fullscreen_checkbutton : CheckButton = %FullscreenCheckButton
@onready var menu_container : Container = %MenuContainer

func _ready() -> void:
	if OS.is_debug_build():
		%DebugButton.visible = true
	menu_container.rotation_degrees = 90.0
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 0.0, 0.35)


func _on_close_button_pressed() -> void:
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 90.0, 0.1)
	t.tween_callback(queue_free)
	#queue_free()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/TitleScreen.tscn")


func _on_settings_button_pressed() -> void:
	settings_panel.visible = true
	fullscreen_checkbutton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
		if toggled_on:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
