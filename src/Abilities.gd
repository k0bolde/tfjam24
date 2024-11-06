extends Node
# Holds the callables of all abilities
var abilities := {
	"basic": {"mp": 0, "type": "slash", "callable": basic_attack},
	"fire breath": {"mp": 4, "type": "fire", "callable": fire_breath},
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
	enemies[target].hp -= 10
