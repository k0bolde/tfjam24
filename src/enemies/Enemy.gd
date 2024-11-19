extends Resource
class_name Enemy

@export var enemy_name := "DefaultName"
@export var desc := "Default Description"
@export var texture_path : String
@export var region_rect : Rect2
@export var flip_h := false
@export var hp := 100
@export var attack_probabilities := {"basic": 1.0}
@export var cash_reward := 10
@export var xp_reward := 1
@export var level := 1
@export var item_drops := {"hp1": 1.0}
@export var base_turns := 1

@export var stats := Stats.new()
@export var visual_scale := 1.0
var position := Vector3()
var ingame_sprite : Sprite3D
var hp_mesh : MeshInstance3D
var hp_bar : ProgressBar
var name_label : Label3D
