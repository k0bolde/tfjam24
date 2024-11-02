extends Control
@onready var credits_panel : Panel = $CreditsPanel

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_quit_credits_button_pressed() -> void:
	credits_panel.visible = false


func _on_credits_button_pressed() -> void:
	credits_panel.visible = true
