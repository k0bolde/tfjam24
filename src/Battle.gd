extends Node2D
class_name Battle

var enemies := []

func _ready() -> void:
	#TODO load enemies in
	pass


func _on_run_button_pressed() -> void:
	Events.battle_end.emit()
