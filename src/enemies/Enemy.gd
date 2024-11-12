extends Resource
class_name Enemy

@export var enemy_name := "DefaultName"
@export var texture_path : String
@export var region_rect : Rect2
@export var flip_h := false
@export var hp := 10
@export var attack_probabilities := {"basic": 1.0}
@export var cash_reward := 100
@export var xp_reward := 100
@export var level := 1
@export var item_drops := {"hp1": 1.0}

@export var stats := Stats.new()
var position := Vector3()
var ingame_sprite : Sprite3D
