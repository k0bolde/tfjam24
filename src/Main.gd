extends Node2D
# Handles loading new maps, the player, loading/closing battles

@onready var player = $Player


func _ready() -> void:
	Globals.player = player 
