extends Area2D
class_name EncounterArea
#While the player is walking through this area, random battles occur
#map of probabilities to monsters- EX: {0.7 - "Rat", 0.3 - "Pidgeon"}
@export var encounter_rates := {}
#whats the chance of a battle happening at all?
@export var total_encounter_rate := 0.1


func _on_body_entered(body: Node2D) -> void:
	body.encounter_area = self


func _on_body_exited(body: Node2D) -> void:
	body.encounter_area = null


func check_for_battle():
	if randf() < total_encounter_rate:
		#TODO pick a monster and return it
		pass
		
	
