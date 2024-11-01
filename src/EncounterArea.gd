extends Area2D
class_name EncounterArea
#While the player is walking through this area, random battles occur
#map of probabilities to monsters- EX: {"Rat" - 0.3, "Dragon" -  0.7} - MUST ADD UP TO 1.0 and be sorted low to high!!
@export var encounter_rates := {}
#whats the chance of a battle happening at all?
@export var total_encounter_rate := 0.008


func _on_body_entered(body: Node2D) -> void:
	body.encounter_area = self


func _on_body_exited(body: Node2D) -> void:
	body.encounter_area = null


func check_for_battle():
	if randf() < total_encounter_rate:
		#TODO pick a monster and return it
		#calculate probabilities based on weights
		var pick := randf()
		var accum := 0.0
		for monster in encounter_rates:
			accum += encounter_rates[monster]
			if pick < accum:
				print("fight!")
				return monster
		printerr("Bad encounter probabilities!")
	
