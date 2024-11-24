extends Resource
class_name Stats

@export var hp := 100
# used to use abilities
@export var mp := 100
# damage added to your base attack
@export var atk := 10
# negate up to 50% damage as compared to attacker's atk, logarithmicly
@export var def := 10
# combination of your chance to dodge attacks and hit enemies
@export var eva := 10
# item/cash drop rate, critical hits
@export var lck := 10

@export var img : Texture2D
@export var character_name : String

@export var abilities := []
#@export var level := 1
#@export var xp := 0
@export var equipment := {"Head": "", "Body": "", "Ring": ""}
# punch/claw/metal/esoteric/mutagenic/fire/bite
@export var weaknesses := []
@export var resistances := []
@export var move_slots := 2

# ability name & user -> the stats & turns left
var temp_stats := {}

func get_atk() -> int:
	var a := 0
	for d in temp_stats.values():
		a += d["stats"].atk
	return a + atk
	
func get_def() -> int:
	var a := 0
	for d in temp_stats.values():
		a += d["stats"].def
	return a + def
	
func get_eva() -> int:
	var a := 0
	for d in temp_stats.values():
		a += d["stats"].eva
	return a + eva
	
func get_lck() -> int:
	var a := 0
	for d in temp_stats.values():
		a += d["stats"].lck
	return a + lck
