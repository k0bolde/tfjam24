extends Node
#TODO multitarget attacks
#TODO healing abilities
#TODO random target attacks
#for specific enemy flavor text, just add another entry with their specific text pointing to the same damage func
# effect: 0 = single target, 1 = target all, 2 = target ally, 3 = target all allies, 4 = two random targets
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
		#"callable": single_attack.bind("swipe"),
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
		#"callable": single_attack.bind("spray"),
	},
	"aid": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 2,
		"mp": 20,
		"desc": "Heal an ally a small amount",
		"enemy_flavor": "They wipe some gunk on their ally. It heals them!",
		#"callable": single_attack.bind("aid"),
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
		#"callable": single_attack.bind("shriek"),
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
		#"callable": single_attack.bind("tip the scales"),
	},
	"recovery strike": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 10,
		"desc": "Hit them and heal some health",
		"enemy_flavor": "They strike CHAR and some of their wounds heal!",
		#"callable": single_attack.bind("recovery strike"),
	},
	"wild wolf": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 4,
		"mp": 20,
		"desc": "Strike wildly and randomly at two targets",
		"enemy_flavor": "They attack wildly, hitting CHAR and CHAR!",
		#"callable": single_attack.bind("wild wolf"),
	},
	
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
			printerr("%s is missing a required key" % a)


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
		the_user["mp"] -= the_attack["mp"]
		
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
	var dmg = (the_user["stats"].atk * mult) - (the_target["stats"].def / (the_target["stats"].def + 25))
	dmg = clampi(dmg, 0, 9999)
	the_target["hp"] -= dmg
	battle.animate_sprite(target)
	if target < 0:
		if the_target["hp"] <= 0:
			the_target["hp"] = 0
			battle.kill_party_member(abs(target) - 1)
	battle.show_dmg_label(dmg, target, dmg_type, is_crit)
	
	
