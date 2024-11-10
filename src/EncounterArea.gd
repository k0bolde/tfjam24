extends Area2D
class_name EncounterArea
#While the player is walking through this area, random battles occur
#TODO change to weights so you don't have to math when setting up rates
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
		var pick := randf()
		#print("picked %f" % pick)
		var accum := 0.0
		for monster in encounter_rates:
			accum += encounter_rates[monster]
			#print("monster has %f rate, accum is now %f" % [encounter_rates[monster], accum])
			if pick < accum:
				var a := [monster]
				Events.battle_start.emit(a, true)
				#TODO enemy groups - take the assigned rates and map to a predefined monster array
				return monster
		printerr("Bad encounter probabilities!")
	
