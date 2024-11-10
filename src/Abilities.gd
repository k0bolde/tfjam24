extends Node
#TODO generic func for handling damage and weaknesses and limiting turns to double enemy count
#for specific enemy flavor text, just add another entry with their specific text pointing to the same damage func
# Holds the info on all abilities, player and enemy
# requires: mp, desc, enemy_flavor (if usable by enemies), callable
var abilities := {
	"basic": {"mp": 0, "type": "slash", "desc": "A basic attack", "enemy_flavor": "They punch your kidney", "callable": basic_attack},
	"fire breath": {"mp": 4, "type": "fire", "desc": "Breath fire on enemy", "callable": fire_breath},
}


func ability_callable(user, party:Array, enemies:Array, target:int, battle:Battle):
	# applies an ability/item to the battle, each invididual ability should have its own func like this that the battle calls when its used
	# target is pos int for enemy target, neg int for party target, null for self
	# should modify turns, send weakness/other animations
	pass
	
	
func basic_attack(user, party, enemies, target, battle):
	if target >= 0:
		enemies[target].hp -= 5
	else:
		Globals.party.p[abs(target) - 1]["hp"] -= 5
	
	
func fire_breath(user, party, enemies, target, battle):
	if enemies[target].stats.weaknesses.has("fire"):
		enemies[target].hp -= 20
	else:
		enemies[target].hp -= 10
	Globals.party.p[user]["mp"] -= abilities["fire breath"]["mp"]
