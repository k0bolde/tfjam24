extends Area2D
class_name EncounterArea
## To add a new encounter group, add it to groups, then set it in an encountergroup object, then if you want add a line to battle_intros.clyde (if you do, add it to group_intros)
#While the player is walking through this area, random battles occur
#TODO change to weights so you don't have to math when setting up rates
#map of probabilities to monsters- EX: {"Rat" - 0.3, "Dragon" -  0.7} - MUST ADD UP TO 1.0 and be sorted low to high!!
@export var encounter_rates := {}
#whats the chance of a battle happening at all?
@export var total_encounter_rate := 7.0
var groups := {
	"qz-1-1": ["lvl 1 kobold", "lvl pun kobold"],
	"qz-1-2": ["mutant man", "glorp"],
	"qz-1-3": ["moth", "ant"],
	"qz-1-4": ["gallivanting goat", "twinned lizard lady"],
	"qz-1-5": ["haz", "haz", "haz"],
	"qz-1-6": ["glorp", "mutagenic mouse"],
	
	"qz-2-1": ["mutant man", "glorp"],
	"qz-2-2": ["moth", "ant"],
	"qz-2-3": ["gallivanting goat", "twinned lizard lady"],
	"qz-2-4": ["haz", "haz", "haz"],
	"qz-2-5": ["base sciraptor", "base sciraptor"],
	
	"qz-3-1": ["lvl 1 kobold", "lvl pun kobold"],
	"qz-3-2": ["cowbro", "cowbro"],
	"qz-3-3": ["wolf", "wolfess", "wolfess", "wolf"],
	"qz-3-4": ["glorp", "mutagenic mouse"],
	"qz-3-5": ["mutant man", "elite imp"],
	"qz-3-6": ["base sciraptor", "base sciraptor"],
	
	"qz-4-1": ["moth", "ant"],
	"qz-4-2": ["ant", "elite ant"],
	"qz-4-3": ["cowbro", "cowbro"],
	"qz-4-4": ["mutant man", "elite imp"],
	"qz-4-5": ["imp", "impess", "imp"],
	"qz-4-6": ["officer", "emt"],
	"qz-4-7": ["officer", "officer"],
	
	"qz-5-1": ["wolf", "wolfess", "wolfess", "wolf"],
	"qz-5-2": ["dragoness", "eye teeth"],
	"qz-5-3": ["twinned lizard lady", "confident lizard lady", "twinned lizard lady"],
	"qz-5-4": ["base sciraptor", "elite sciraptor"],
	"qz-5-5": ["officer", "emt"],
	"qz-5-6": ["officer", "officer"],
	"qz-5-7": ["imp", "impess", "imp"],
	
	"qz-6-1": ["ant", "elite ant"],
	"qz-6-2": ["dragoness", "eerie suit"],
	"qz-6-3": ["dragoness", "eye teeth"],
	"qz-6-4": ["twinned lizard lady", "confident lizard lady", "twinned lizard lady"],
	"qz-6-5": ["elite impess", "elite imp"],
	"qz-6-6": ["moth", "elite ant"],
	
	"qz-7-1": ["dragoness", "eerie suit"],
	"qz-7-2": ["dragoness", "eye teeth"],
	"qz-7-3": ["base sciraptor", "elite sciraptor"],
	"qz-7-4": ["elite impess", "elite imp"],
	"qz-7-5": ["moth", "elite ant"],
	
	
}
## be sure to use - instead of _ here!!
var group_intros := [
	"qz-1-1", "qz-1-2", "qz-1-3", "qz-1-4", "qz-1-5", "qz-1-6",
	"qz-2-1", "qz-2-2", "qz-2-3", "qz-2-4", "qz-2-5",
	"qz-3-1", "qz-3-2", "qz-3-3", "qz-3-4", "qz-3-5", "qz-3-6", 
	"qz-4-1", "qz-4-2", "qz-4-3", "qz-4-4", "qz-4-5", "qz-4-6", "qz-4-7", 
	"qz-5-1", "qz-5-2", "qz-5-3", "qz-5-4", "qz-5-5", "qz-5-6", "qz-5-7", 
	"qz-6-1", "qz-6-2", "qz-6-3", "qz-6-4", "qz-6-5", "qz-6-6", 
	"qz-7-1", "qz-7-2", "qz-7-3", "qz-7-4", "qz-7-5",
	]
var check_accum := 0.0
var encounter_pick := randf_range(0.1, 1.0)


func _ready() -> void:
	#check for data errors
	for g in groups:
		for e in groups[g]:
			if not Globals.enemies.has(e):
				printerr("group %s has non-existent enemy %s" % [g, e])
	if not encounter_rates.is_empty():
		var total := 0.0
		for e in encounter_rates:
			total += encounter_rates[e]
		if not is_equal_approx(total, 1.0):
			printerr("encounter rates don't add up to 1.0 in %s" % encounter_rates)
	

func _on_body_entered(body: Node2D) -> void:
	check_accum = 0
	encounter_pick = randf_range(0.1, 1.0)
	body.encounter_area = self


func _on_body_exited(body: Node2D) -> void:
	if body.encounter_area and body.encounter_area == self:
		body.encounter_area = null


func check_for_battle(delta):
	check_accum += delta
	var encounter_rate = check_accum / total_encounter_rate
	#print("encounter pick %s rate %s" % [encounter_pick, encounter_rate])
	if encounter_pick < encounter_rate:
		check_accum = 0.0
		var pick := randf()
		var accum := 0.0
		for monster in encounter_rates:
			accum += encounter_rates[monster]
			if pick < accum:
				encounter_pick = randf_range(0.1, 1.0)
				if groups.has(monster):
					Events.battle_start.emit(groups[monster], true)
					if group_intros.has(monster):
						Globals.main.start_dialogue("res://assets/dialogue/battle_intros.clyde", monster.replace("-", "_"))
				else:
					Events.battle_start.emit([monster], true)
				return monster
		printerr("Bad encounter probabilities!")
	
