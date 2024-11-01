extends Control
@onready var settings_panel : Panel = %SettingsPanel
@onready var fullscreen_checkbutton : CheckButton = %FullscreenCheckButton

func _ready() -> void:
	pass


func _on_close_button_pressed() -> void:
	queue_free()


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
