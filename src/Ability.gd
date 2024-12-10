extends Resource
class_name Ability

@export var ability_name := "DefaultName"
@export var desc := "DefaultDesc"
@export var enemy_flavor := "DefaultEnemyFlavor"
@export var base_atk := 1.0
@export var type : String
@export var effect := 0
@export var mp := 0
var callable : Callable
@export var can_player_use := true
@export var specific_party_members := []
