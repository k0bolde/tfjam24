extends Control

@onready var bg : ColorRect = %BG
@onready var gameover_label : Label = %GameOverLabel
@onready var load_button : Button = %LoadButton

func _ready() -> void:
	#fade in bg
	var bgt := get_tree().create_tween()
	bgt.tween_property(bg, "modulate", Color.BLACK, 5)
	#scale up label.theme_override.font_size
	var lt := get_tree().create_tween()
	lt.set_trans(Tween.TRANS_SINE)
	lt.tween_method(func (s): gameover_label.add_theme_font_size_override("font_size", s), 1, 180, 5)
	load_button.disabled = not FileAccess.file_exists("user://save.tres")


func _on_load_button_pressed() -> void:
	Globals.load_game()


func _on_title_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/TitleScreen.tscn")
