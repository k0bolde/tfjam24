extends Node2D
class_name Map
#Maps store the tilemap showing the maps visuals, but also encounter areas and npcs

@export var map_name : String
@export var start_location := Vector2(0, 0)
@export var entrances : Array[Vector2] = []

func _ready() -> void:
	#not sure why this is needed, but otherwise it shows above player
	$TileMapLayer.z_index = -1
