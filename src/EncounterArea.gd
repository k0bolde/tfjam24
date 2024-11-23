extends Area2D
class_name EncounterArea
#While the player is walking through this area, random battles occur
#TODO change to weights so you don't have to math when setting up rates
#map of probabilities to monsters- EX: {"Rat" - 0.3, "Dragon" -  0.7} - MUST ADD UP TO 1.0 and be sorted low to high!!
@export var encounter_rates := {}
#whats the chance of a battle happening at all?
@export var total_encounter_rate := 300.0
var groups := {
	"qz-1-1": ["lvl 1 kobold", "lvl pun kobold"],
	"qz-1-2": ["mutant man", "glorp"],
	"qz-1-3": ["moth", "ant"],
	"qz-1-4": ["gallivanting goat", "twinned lizard lady"],
	"qz-1-5": ["haz", "haz", "haz"],
	"qz-1-6": ["glorp", "mutagenic mouse"]
}
var group_intros := [
	"qz-1-1", "qz-1-2", "qz-1-3", "qz-1-4", "qz-1-5", "qz-1-6",
	]
var check_accum := 0.0

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
	body.encounter_area = self


func _on_body_exited(body: Node2D) -> void:
	if body.encounter_area and body.encounter_area == self:
		body.encounter_area = null


func check_for_battle(delta):
	check_accum += delta
	#TODO give a leeway of a bit between battles
	var encounter_rate = check_accum / total_encounter_rate
	print("encounter rate %s" % encounter_rate)
	if randf() < encounter_rate:
		check_accum = 0.0
		var pick := randf()
		var accum := 0.0
		for monster in encounter_rates:
			accum += encounter_rates[monster]
			if pick < accum:
				if groups.has(monster):
					Events.battle_start.emit(groups[monster], true)
					if group_intros.has(monster):
						Globals.main.start_dialogue("res://assets/dialogue/battle_intros.clyde", monster.replace("-", "_"))
				else:
					Events.battle_start.emit([monster], true)
				return monster
		printerr("Bad encounter probabilities!")
	
