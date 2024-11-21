extends Node
#TODO multitarget attacks
#TODO healing abilities
#TODO random target attacks
#for specific enemy flavor text, just add another entry with their specific text pointing to the same damage func
# effect: 0 = single target, 1 = target all, 2 = target ally, 3 = target all allies, 4 = two random targets, 5 = self target
# Holds the info on all abilities, player and enemy
# requires: mp, base_atk, type, effect, desc, enemy_flavor (if usable by enemies), callable
var abilities := {
	"punch": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "A basic punch",
		"enemy_flavor": "They punch CHAR! Ouch!",
		"callable": single_attack.bind("punch"),
	},
	"kick": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "What you learned in karate",
		"enemy_flavor": "They kick CHAR!! Oof!",
		"callable": single_attack.bind("kick"),
	},
	"sob": {
		"base_atk": 0.0,
		"type": "esoteric",
		"effect": 0,
		"mp": 0,
		"desc": ":')",
		"enemy_flavor": "They cry. You feel bad...",
		"callable": single_attack.bind("sob"),
	},
	"claw": {
		"base_atk": 1.0,
		"type": "rending",
		"effect": 0,
		"mp": 0,
		"desc": "Tear their flesh asunder!",
		"enemy_flavor": "They claw CHAR with their, uh, claws!",
		"callable": single_attack.bind("claw"),
	},
	"tail whip": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "A quick whip of the tail",
		"enemy_flavor": "They whip CHAR with their tail!",
		"callable": single_attack.bind("tail whip"),
	},
	"tentacle whip": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "A quick tentacle whip",
		"enemy_flavor": "They whip CHAR with their tentacle!",
		"callable": single_attack.bind("tentacle whip"),
	},
	"swipe": {
		"base_atk": 1.0,
		"type": "rending",
		"effect": 1,
		"mp": 25,
		"desc": "Hit all targets with a mighty swipe!",
		"enemy_flavor": "The man growls as he hits all of you with a swipe of his claws!",
		"callable": multi_attack.bind("swipe"),
	},
	"bite": {
		"base_atk": 2.0,
		"type": "piercing",
		"effect": 0,
		"mp": 25,
		"desc": "Take a bite out of 'em",
		"enemy_flavor": "They take a chunk out of you! Ouch!",
		"callable": single_attack.bind("bite"),
	},
	"spray": {
		"base_atk": 2.0,
		"type": "mutagenic",
		"effect": 1,
		"mp": 50,
		"desc": "",
		"enemy_flavor": "They spray you with mutagens! Gross!",
		"callable": multi_attack.bind("spray"),
	},
	"aid": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 2,
		"mp": 20,
		"desc": "Heal an ally a small amount",
		"enemy_flavor": "They wipe some gunk on their ally. It heals them!",
		#heal ally 25
		"callable": heal.bind("aid", 25),
	},
	"pistol shot": {
		"base_atk": 2.0,
		"type": "piercing",
		"effect": 0,
		"mp": 0,
		"desc": "Give them the gat",
		"enemy_flavor": "They quickly fire off two rounds of their pistol at you! Blam Blam!",
		"callable": single_attack.bind("pistol shot"),
	},
	"pistol whip": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "Hit them with your pistol!",
		"enemy_flavor": "They whip you with their pistol!",
		"callable": single_attack.bind("pistol whip"),
	},
	"shriek": {
		"base_atk": 1.0,
		"type": "eldritch",
		"effect": 1,
		"mp": 10,
		"desc": "A horrible wail that damages body and mind",
		"enemy_flavor": "It wails, causing your body to ache and your mind to quail!",
		#Hits ALL and drains 10 MP
		"callable": multi_attack.bind("shriek"),
	},
	"insane insight": {
		"base_atk": 2.0,
		"type": "eldritch",
		"effect": 0,
		"mp": 20,
		"desc": "Reveal something they are not meant to know",
		"enemy_flavor": "They reveal something to CHAR that CHAR cannot quite comprehend. CHAR reels as their head aches fiercely!",
		"callable": single_attack.bind("insane insight"),
	},
	"fire breath": {
		"base_atk": 2.0,
		"type": "fire",
		"effect": 0,
		"mp": 25,
		"desc": "Unleash your inner fire!",
		"enemy_flavor": "They breathe fire. CHAR is cooked!",
		"callable": single_attack.bind("fire breath"),
	},
	"tip the scales": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 0,
		"mp": 20,
		"desc": "Attack while temporarily increasing your defense!",
		"enemy_flavor": "They strike CHAR and their scales shine. They look momentarily tougher.",
		#x2 DEF 3 turns
		#"callable": single_attack.bind("tip the scales"),
		"callable": DONTUSEME
	},
	"recovery strike": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 10,
		"desc": "Hit them and heal some health",
		"enemy_flavor": "They strike CHAR and some of their wounds heal!",
		#20 HP recovery
		#"callable": single_attack.bind("recovery strike"),
		"callable": DONTUSEME
	},
	"wild wolf": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 4,
		"mp": 20,
		"desc": "Strike wildly and randomly at two targets",
		"enemy_flavor": "They attack wildly, hitting CHAR and CHAR!",
		#two random targets
		"callable": random_attack.bind("wild wolf", 2),
	},
	"potion throw": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 0,
		"mp": 0,
		"desc": "Toss a random potion!",
		"enemy_flavor": "They toss a potion at CHAR! It explodes into arcane energy!",
		"callable": single_attack.bind("potion throw")
	},
	"better aid": {
		"base_atk": 0.0,
		"type": "esoteric",
		"effect": 2,
		"mp": 30,
		"desc": "Heal an ally a better amount",
		"enemy_flavor": "They give their ally a huge. It heals them!",
		#heal ally 40
		"callable": heal.bind("better aid", 40)
	},
	"bad pun": {
		"base_atk": 2.0,
		"type": "eldritch",
		"effect": 0,
		"mp": 25,
		"desc": "Make a bad pun that makes the mind reel",
		"enemy_flavor": "They say a pun so bad CHAR’s head aches awfully!",
		"callable": single_attack.bind("bad pun")
	},
	"nervous stab": {
		"base_atk": 1.0,
		"type": "piercing",
		"effect": 0,
		"mp": 0,
		"desc": "Stab with no heart behind it",
		"enemy_flavor": "They stab CHAR nervously. It still hurts.",
		"callable": single_attack.bind("nervous stab")
	},
	"self repair": {
		"base_atk": 0,
		"type": "esoteric",
		"effect": 5,
		"mp": 0,
		"desc": "Heal thyself",
		"enemy_flavor": "It conducts self repair on itself!",
		#heal self 30
		"callable": heal.bind("self repair", 30)
	},
	"inspire": {
		"base_atk": 0,
		"type": "esoteric",
		"effect": 2,
		"mp": 20,
		"desc": "Inspire an ally to fight harder",
		"enemy_flavor": "It inspires its ally to fight harder!",
		#ally ATK x1.3 and Luck x1.5 3 turns
		"callable": DONTUSEME
	},
	"entice": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 0,
		"mp": 5,
		"desc": "A flirty slap that drains their will to fight you",
		"enemy_flavor": "They flirt and then slap CHAR. What a tease!",
		#-5 Evasion and -5 Luck 3 turns
		"callable": DONTUSEME
	},
	"confuse": {
		"base_atk": 0.5,
		"type": "esoteric",
		"effect": 0,
		"mp": 10,
		"desc": "Cause your enemy to lower their guard with your wiles",
		"enemy_flavor": "They perplex CHAR with a tricky strike! CHAR’s defense is down!",
		#-10 DEF and -10 Evasion 3 turns
		"callable": DONTUSEME
	},
	"cackle": {
		"base_atk": 0,
		"type": "piercing",
		"effect": 5,
		"mp": 10,
		"desc": "An evil laugh that draws inner strength",
		"enemy_flavor": "They cackle, putting them into a frenzy!",
		#ATK 1.3x and Evasion 1.3x 3 turns
		"callable": DONTUSEME
	},
	"syringe shot": {
		"base_atk": 1.0,
		"type": "mutagenic",
		"effect": 0,
		"mp": 0,
		"desc": "Fire a mutagenic syringe at your foe.",
		"enemy_flavor": "They fire a mutagenic syringe at CHAR! Ouch!",
		"callable": single_attack.bind("syringe shot")
	},
	"fortify": {
		"base_atk": 0,
		"type": "bludgeoning",
		"effect": 5,
		"mp": 10,
		"desc": "Increase your defenses temporarily",
		"enemy_flavor": "They square up and increase their defenses!",
		#DEF 2x 3 turns
		"callable": DONTUSEME
	},
	"stare": {
		"base_atk": 1.0,
		"type": "eldritch",
		"effect": 0,
		"mp": 0,
		"desc": "Give them the eldritch eye.",
		"enemy_flavor": "They give CHAR the eldritch eye. CHAR’s mind quakes!",
		#Drains 10 MP
		"callable": DONTUSEME
	}
}

func _ready() -> void:
	#setup enemy specific moves
	abilities["some guy punch"] = abilities["punch"].duplicate()
	abilities["some guy punch"]["enemy_flavor"] = "Some guy punches you! Ouch!"
	abilities["some guy kick"] = abilities["kick"].duplicate()
	abilities["some guy kick"]["enemy_flavor"] = "Some guy kicks you! Oof!"
	abilities["some guy sob"] = abilities["sob"].duplicate()
	abilities["some guy sob"]["enemy_flavor"] = "Some guy cries. You feel bad…"
	abilities["man claw"] = abilities["claw"].duplicate()
	abilities["man claw"]["enemy_flavor"] = "The man claws you with his, uh, claws!"
	abilities["man tail whip"] = abilities["tail whip"].duplicate()
	abilities["man tail whip"]["enemy_flavor"] = "The man whips you with his tail!"
	abilities["man swipe"] = abilities["swipe"].duplicate()
	abilities["man swipe"]["enemy_flavor"] = "The man growls as he hits all of you with a swipe of his claws!"
	abilities["woman bite"] = abilities["bite"].duplicate()
	abilities["woman bite"]["enemy_flavor"] = "The woman takes a chunk out of you! Ouch!"
	abilities["woman spray"] = abilities["spray"].duplicate()
	abilities["woman spray"]["enemy_flavor"] = "The woman sprays some gunk from her mouth. Gross!"
	abilities["woman aid"] = abilities["aid"].duplicate()
	abilities["woman aid"]["enemy_flavor"] = "The woman wipes some gunk on the man. It heals him!"
	abilities["cat pistol shot"] = abilities["pistol shot"].duplicate()
	abilities["cat pistol shot"]["enemy_flavor"] = "The cat fires her pistol at you! Blam Blam!"
	abilities["cat pistol whip"] = abilities["pistol whip"].duplicate()
	abilities["cat pistol whip"]["enemy_flavor"] = "Her pistol jams! She hits CHAR with it instead!"
	
	
	# check that all abilities have the required keys
	for a in abilities:
		if not abilities[a].has_all(["base_atk", "type", "effect", "mp", "desc", "enemy_flavor", "callable"]):
			printerr("ability %s is missing a required key" % a)


#func ability_callable(user, party, enemies:Array, target:int, battle:Battle):
	## applies an ability/item to the battle, each invididual ability should have its own func like this that the battle calls when its used
	## target is pos int for enemy target, neg int for party target, null for self
	## should modify turns, send weakness/other animations
	#pass
	
	
func single_attack(user:int, party, enemies:Array, target:int, battle:Battle, attack_name:String):
	var the_target
	var the_user
	var the_attack = abilities[attack_name]
	if target >= 0:
		the_target = enemies[target]
	else:
		the_target = party.p[abs(target) - 1]
	if user >= 0:
		if enemies.size() == 0:
			return
		the_user = enemies[user]
	else:
		the_user = party.p[abs(user) - 1]
		#the_user["mp"] -= the_attack["mp"]
		
	var mult = the_attack["base_atk"]
	var dmg_type := 0
	var is_crit := false
	#check weakness
	if the_target["stats"]["weaknesses"].has(the_attack["type"]):
		#TODO sound
		mult += 0.5
		dmg_type = 1
	elif the_target["stats"]["resistances"].has(the_attack["type"]):
		#TODO sound
		mult -= 0.5
		if mult < 0: mult = 0
		dmg_type = 2
	if randf() < (the_target["stats"].lck / 100.0):
		#TODO sound
		mult += 1.0
		is_crit = true
	if randf() < (the_target["stats"].eva - the_user["stats"].eva) / 100.0:
		#TODO sound
		battle.add_turn(-1)
		dmg_type = 3
		mult = 0
		is_crit = false
	if is_crit or dmg_type == 1:
		battle.add_turn(1)
		
	#calculate damage
	var dmg : int = ceili((the_user["stats"].atk * mult) - (the_target["stats"].def / (the_target["stats"].def + 25.0)))
	dmg = clampi(dmg, 0, 9999)
	the_target["hp"] -= dmg
	battle.animate_sprite(target)
	if target < 0:
		if the_target["hp"] <= 0:
			the_target["hp"] = 0
			battle.kill_party_member(abs(target) - 1)
	battle.show_dmg_label(dmg, target, dmg_type, is_crit)

	
## hits a random amount of targets
func random_attack(user:int, party, enemies:Array, target:int, battle:Battle, attack_name:String, num_targets:int):
	var picks := []
	if user < 0:
		if num_targets < enemies.size():
			for i in num_targets:
				picks.append(randi_range(0, enemies.size() - 1))
				for j in i:
					while picks[i] == picks[j]:
						picks[i] = randi_range(0, enemies.size() - 1)
			for t in picks:
				single_attack(user, party, enemies, t, battle, attack_name)
		else:
			multi_attack(user, party, enemies, target, battle, attack_name)
	else:
		#TODO test this
		if num_targets < Globals.party.num_alive():
			for i in num_targets:
				picks.append(randi_range(0, Globals.party.p.size() - 1))
				for j in i:
					while picks[i] == picks[j] or Globals.party.p[picks[i]]["hp"] <= 0:
						picks[i] = randi_range(0, Globals.party.p.size() - 1)
			for i in picks.size():
				picks[i] = -(picks[i] + 1)
			for t in picks:
				single_attack(user, party, enemies, t, battle, attack_name)
		else:
			multi_attack(user, party, enemies, target, battle, attack_name)
		
		

## hits all opposing targets
func multi_attack(user:int, party, enemies:Array, target:int, battle:Battle, attack_name:String):
	var targets := []
	if user >= 0:
		#enemy, targeting players
		for p in party.size():
			if party[p]["hp"] > 0:
				targets.append(-(p + 1))
	else:
		#player, targeting enemies
		for e in enemies.size():
			targets.append(e)
	for t in targets:
		single_attack(user, party, enemies, t, battle, attack_name)
	
	
## heals the target
func heal(user:int, party, enemies:Array, target:int, battle:Battle, attack_name:String, amount:int):
	pass


func DONTUSEME(user:int, party, enemies:Array, target:int, battle:Battle):
	printerr("DONTUSEME")
