extends Node
class_name Inventory
# Keep track of what items and equipment the player has
# name, id, amount, description, mechanically how they're used
var inv := {}
var items := {}

func _init() -> void:
	var i := Item.new()
	i.item_name = "lime time"
	i.desc = "A CausDek branded energy drink that restores 50 MP"
	i.is_field_usable = true
	i.callable = mp_restore.bind(50, false)
	i.price = 20
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "a dozen eggs"
	i.desc = "All at once? Restores 50 HP"
	i.price = 15
	i.callable = heal_single.bind(50, false)
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "coffee"
	i.desc = "Gets the magic working in the morning. Restores 25 MP"
	i.is_field_usable = true
	i.price = 5
	i.callable = mp_restore.bind(25, false)
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "pizza"
	i.desc = "A slice of NY Pizza, hot and fresh. Restores 25 HP"
	i.price = 5
	i.callable = heal_single.bind(25, false)
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "clem's pills"
	i.desc = "A handful of pills. Should do something, right? Restores 10-25 HP and 10-25 MP"
	i.price = 15
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "golden ankrowo"
	i.price = 250
	i.desc = "Full HP and MP restore to all party members. Exceedingly rare. Only 1 in 1 million Ankrs are golden."
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "ankrpwease"
	i.desc = "Your teammate is revived to 50 HP and MP thanks to this synth’s tears."
	i.price = 100
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "scale polish"
	i.desc = "Makes you feel smooth and strong! Provides +10 DEF for 3 turns"
	i.price = 50
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "rend roid"
	i.desc = "Harness the strength of a dragon! Provides +50% ATK for 3 turns"
	i.price = 50
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "dancing doe"
	i.desc = "Make you feel frisky and faster! Provides +20 Luck and Evasion for 3 turns"
	i.price = 50
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "sealed soul"
	i.desc = "Makes you feel numb… Removes all weakness and makes you resistant to everything for 3 turns!"
	i.price = 100
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "distilled synth snilk"
	i.desc = "Milk that comes from a synth snake! Restores 20 HP and MP for 3 turns"
	i.price = 35
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "ariadne's thread"
	i.desc = "Returns you to the start of the dungeon"
	i.price = 50
	i.is_battle_usable = false
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "prop axe"
	i.desc = "A single use axe good for doing Rending damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "twig spear"
	i.desc = "A brittle twig you can use a single time to do Piercing damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "empty rifle"
	i.desc = "A rifle without bullets you can use to do Bludgeoning damage before the stock shatters (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "arda's flame"
	i.desc = "A pyro dragoness’s flame stored in glass that can be shattered to do Fiery damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "nid's captured cold"
	i.desc = "A frost dragoness’s preternatural chill stored in glass to do Frigid damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "spare syringe"
	i.desc = "A syringe filled with who knows what to do Mutagenic damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "ddew pamphlet"
	i.desc = "A pamphlet espousing Dark, Dark Evil Ways. Read to do Esoteric damage once as the pamphlet burns away (ATK 1.5)"
	i.price = 30
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "weird writings"
	i.desc = "Incomprehensible words that can only be read once before they are erased from the page to do Eldritch damage (ATK 1.5)"
	i.price = 15
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "soap"
	i.desc = "Simple soap that removes 99.7% of debuffs from your party. Handy!"
	i.price = 20
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "foghorn"
	i.desc = "Demoralizes all enemies, removing all buffs."
	i.price = 20
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "blue sigil"
	i.desc = "A mysterious rune that restores 100 MP"
	i.price = 50
	i.is_field_usable = true
	i.callable = mp_restore.bind(100, false)
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "rose's cookie"
	i.price = 20
	i.desc = "A cookie based with love. Restores 75 HP"
	i.callable = heal_single.bind(75, false)
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "synth milk"
	i.price = 30
	i.desc = "Synth Milk? Restores 50 HP and MP"
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "snilk"
	i.desc = "Snake Milk. Restores 75 HP and MP"
	i.price = 60
	i.is_field_usable = true
	i.callable = DONTUSE
	items[i.item_name] = i
	
	i = Item.new()
	i.item_name = "citra suprise"
	i.desc = "A delicious drink that grants you an extra turn."
	i.price = 100
	i.callable = DONTUSE
	items[i.item_name] = i
	
	#i = Item.new()
	#items[i.item_name] = i
	
	verify()
	
	
func verify():
	for item in items:
		if item != items[item].item_name:
			printerr("item name mismatch - key: %s item_name %s" % [item, items[item].item_name])
		var i : Item = items[item]
		if i.item_name == "DefaultName":
			printerr("default item name")
		if i.desc == "DefaultDesc":
			printerr("default desc for item %s" % item)
		if i.price == 0:
			printerr("no price for item %s" % item)
		if i.callable == null or i.callable.is_null() or not i.callable.is_valid():
			printerr("bad callable for item %s" % item)
	
	
func DONTUSE():
	printerr("unimplemented")


## heals a single target by some amount, either percentage or straight
func heal_single(amount:int, percentage:bool):
	pass
	
	
func mp_restore(amount:int, percentage:bool):
	pass
