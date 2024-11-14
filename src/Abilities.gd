extends Node
#TODO generic func for handling damage and weaknesses and limiting turns to double enemy count
#for specific enemy flavor text, just add another entry with their specific text pointing to the same damage func
# crits add 1.0 to base atk
# effect: 0 = single target, 1 = target all, 2 = target ally, 3 = target all allies, 4 = two random targets
# Holds the info on all abilities, player and enemy
# requires: mp, base_atk, desc, enemy_flavor (if usable by enemies), callable
var abilities := {
	"punch": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "A basic punch",
		"enemy_flavor": "They punch CHAR! Ouch!",
		"callable": basic_attack,
	},
	"kick": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "What you learned in karate",
		"enemy_flavor": "They kick CHAR!! Oof!",
	},
	"sob": {
		"base_atk": 0,
		"type": "esoteric",
		"effect": 0,
		"mp": 0,
		"desc": ":')",
		"enemy_flavor": "They cry. You feel bad...",
	},
	"claw": {
		"base_atk": 1.0,
		"type": "rending",
		"effect": 0,
		"mp": 0,
		"desc": "Tear their flesh asunder!",
		"enemy_flavor": "They claw CHAR with their, uh, claws!"
	},
	"tail whip": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "A quick whip of the tail",
		"enemy_flavor": "They whip CHAR with their tail!"
	},
	"tentacle whip": {
		"base_atk": 1.5,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 15,
		"desc": "A quick tentacle whip",
		"enemy_flavor": "They whip CHAR with their tentacle!"
	},
	"swipe": {
		"base_atk": 1.0,
		"type": "rending",
		"effect": 1,
		"mp": 25,
		"desc": "Hit all targets with a mighty swipe!",
		"enemy_flavor": "The man growls as he hits all of you with a swipe of his claws!"
	},
	"bite": {
		"base_atk": 2.0,
		"type": "piercing",
		"effect": 0,
		"mp": 25,
		"desc": "Take a bite out of 'em",
		"enemy_flavor": "They take a chunk out of you! Ouch!"
	},
	"spray": {
		"base_atk": 2.0,
		"type": "mutagenic",
		"effect": 1,
		"mp": 50,
		"desc": "",
		"enemy_flavor": "They spray you with mutagens! Gross!"
	},
	"aid": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 2,
		"mp": 20,
		"desc": "Heal an ally a small amount",
		"enemy_flavor": "They wipe some gunk on their ally. It heals them!"
	},
	"pistol shot": {
		"base_atk": 2.0,
		"type": "piercing",
		"effect": 0,
		"mp": 0,
		"desc": "Give them the gat",
		"enemy_flavor": "They quickly fire off two rounds of their pistol at you! Blam Blam!"
	},
	"pistol whip": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "Hit them with your pistol!",
		"enemy_flavor": "They whip you with their pistol!"
	},
	"shriek": {
		"base_atk": 1.0,
		"type": "eldritch",
		"effect": 1,
		"mp": 10,
		"desc": "A horrible wail that damages body and mind",
		"enemy_flavor": "It wails, causing your body to ache and your mind to quail!"
	},
	"insane insight": {
		"base_atk": 2.0,
		"type": "eldritch",
		"effect": 0,
		"mp": 20,
		"desc": "Reveal something they are not meant to know",
		"enemy_flavor": "They reveal something to CHAR that CHAR cannot quite comprehend. CHAR reels as their head aches fiercely!"
	},
	"fire breath": {
		"base_atk": 2.0,
		"type": "fire",
		"effect": 0,
		"mp": 25,
		"desc": "Unleash your inner fire!",
		"enemy_flavor": "They breathe fire. CHAR is cooked!"
	},
	"tip the scales": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 0,
		"mp": 20,
		"desc": "Attack while temporarily increasing your defense!",
		"enemy_flavor": "They strike CHAR and their scales shine. They look momentarily tougher."
	},
	"recovery strike": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 10,
		"desc": "Hit them and heal some health",
		"enemy_flavor": "They strike CHAR and some of their wounds heal!"
	},
	"wild wolf": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 4,
		"mp": 20,
		"desc": "Strike wildly and randomly at two targets",
		"enemy_flavor": "They attack wildly, hitting CHAR and CHAR!"
	},
	
}

func _ready() -> void:
	# check that all abilities have the required keys
	for a in abilities.values():
		if not a.has_all(["base_atk", "type", "effect", "mp", "desc", "enemy_flavor", "callable"]):
			printerr("entry: %s is missing a required key" % a)


func ability_callable(user, party:Array, enemies:Array, target:int, battle:Battle):
	# applies an ability/item to the battle, each invididual ability should have its own func like this that the battle calls when its used
	# target is pos int for enemy target, neg int for party target, null for self
	# should modify turns, send weakness/other animations
	pass
	
	
func basic_attack(user, party, enemies, target, battle):
	if target >= 0:
		enemies[target].hp -= 50
	else:
		Globals.party.p[abs(target) - 1]["hp"] -= 5
	
	
func fire_breath(user, party, enemies, target, battle):
	if enemies[target].stats.weaknesses.has("fire"):
		enemies[target].hp -= 20
	else:
		enemies[target].hp -= 10
	Globals.party.p[user]["mp"] -= abilities["fire breath"]["mp"]
