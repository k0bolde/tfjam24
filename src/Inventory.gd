extends Resource
class_name Inventory
# Keep track of what items and equipment the player has
# name, id, amount, description, mechanically how they're used
@export var inv := {}
var items := {
	"lime time": {
		"name": "Lime Time",
		"desc": "A CausDek branded energy drink that restores 50% of MP",
		"callable": mp_restore.bind(50, true)
	},
	"dozen eggs": {
		"name": "A dozen eggs",
		"desc": "All at once? Restores 50% HP",
		"callable": heal_single.bind(50, true)
	},
	"limon tiempo": {
		"name": "Limon Tiempo",
		"desc": "A CausDek branded energy drink that restores 75% of MP",
		"callable": mp_restore.bind(75, true)
	},
	"rose cookie": {
		"name": "Rose's Cookie",
		"desc": "A cookie baked with love. Restores 75% of HP",
		"callable": heal_single.bind(75, true)
	},
	"synth milk": {
		"name": "Synth Milk",
		"desc": "Synth Milk? Restores 75% of HP and MP",
		"callable": func (): printerr("unimplemented")
	},
	"snilk": {
		"name": "Snilk",
		"desc": "Snake Milk. Restores 75% of HP and MP",
		"callable": func (): printerr("unimplemented")
	},
	"goldern ankrowo": {
		"name": "Golden Ankrowo",
		"desc": "Full HP and MP restore to all party members",
		"callable": func (): printerr("unimplemented")
	},
	"ankrpwease": {
		"name": "Ankerpwease",
		"desc": "Revives teammate with 25% HP thanks to this synth's tears",
		"callable": func (): printerr("unimplemented")
	}
}


## heals a single target by some amount, either percentage or straight
func heal_single(amount:int, percentage:bool):
	pass
	
	
func mp_restore(amount:int, percentage:bool):
	pass
