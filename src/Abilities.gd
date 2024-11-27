extends Node
#TODO healing abilities
#TODO stats buffs
#for specific enemy flavor text, just add another entry with their specific text pointing to the same damage func
# effect: 0 = single target, 1 = target all, 2 = target ally, 3 = target all allies, 4 = random targets, 5 = self target
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
		"mp": 10,
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
		"base_atk": .75,
		"type": "rending",
		"effect": 1,
		"mp": 25,
		"desc": "Hit all targets with a mighty swipe!",
		"enemy_flavor": "They growl as they hit all of you with a swipe of their claws!",
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
		"base_atk": 1.5,
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
		"callable":
func (user, party, enemies, target, battle): 
	multi_mp_drain(user, party, enemies, target, battle, 10) 
	multi_attack(user, party, enemies, target, battle, "shriek")
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
		"type": "piercing",
		"effect": 0,
		"mp": 20,
		"desc": "Attack while temporarily increasing your defense!",
		"enemy_flavor": "They strike CHAR and their scales shine. They look momentarily tougher.",
		#x2 DEF 3 turns
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, user, battle, "tip the scales", true, 0, 100, 0, 0)
	single_attack(user, party, enemies, target, battle, "tip the scales")
	},
	"recovery strike": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 10,
		"desc": "Hit them and heal some health",
		"enemy_flavor": "They strike CHAR and some of their wounds heal!",
		#20 HP recovery
		"callable": 
func (user, party, enemies, target, battle): 
	heal(user, party, enemies, user, battle, "recovery strike", 20)
	single_attack(user, party, enemies, target, battle, "recovery strike")
	},
	"wild wolf": {
		"base_atk": 1.5,
		"type": "rending",
		"effect": 4,
		"mp": 20,
		"desc": "Strike wildly and randomly at two targets",
		"enemy_flavor": "They attack wildly!",
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
		"enemy_flavor": "They give their ally a hug. It heals them!",
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
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "inspire", true, 30, 0, 0, 50)
	},
	"entice": {
		"base_atk": 1.0,
		"type": "esoteric",
		"effect": 0,
		"mp": 5,
		"desc": "A flirty slap that drains their will to fight you",
		"enemy_flavor": "They flirt and then slap CHAR. What a tease!",
		#-5 Evasion and -5 Luck 3 turns
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "entice", false, 0, 0, -5, -5)
	single_attack(user, party, enemies, target, battle, "entice")
	},
	"confuse": {
		"base_atk": 0.5,
		"type": "esoteric",
		"effect": 0,
		"mp": 10,
		"desc": "Cause your enemy to lower their guard with your wiles",
		"enemy_flavor": "They perplex CHAR with a tricky strike! CHAR’s defense is down!",
		#-10 DEF and -10 Evasion 3 turns
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "confuse", false, 0, -10, -10, 0)
	single_attack(user, party, enemies, target, battle, "confuse")
	},
	"cackle": {
		"base_atk": 0,
		"type": "piercing",
		"effect": 5,
		"mp": 10,
		"desc": "An evil laugh that draws inner strength",
		"enemy_flavor": "They cackle, putting them into a frenzy!",
		#ATK 1.3x and Evasion 1.3x 3 turns
		"callable": 
func (user, party, enemies, _target, battle): 
	stat_modify(user, party, enemies, user, battle, "cackle", true, 30, 0, 30, 0)
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
		"callable": 
func (user, party, enemies, _target, battle): 
	stat_modify(user, party, enemies, user, battle, "fortify", true, 0, 100, 0, 0)
	},
	"stare": {
		"base_atk": 1.0,
		"type": "eldritch",
		"effect": 0,
		"mp": 0,
		"desc": "Give them the eldritch eye.",
		"enemy_flavor": "They give CHAR the eldritch eye. CHAR’s mind quakes!",
		#Drains 10 MP
		"callable": 
func (user, party, enemies, target, battle):
	single_mp_drain(user, party, enemies, target, battle, 10)
	},
	"struggle": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "hit yourself in confusion",
		"enemy_flavor": "They thank CHAR for trying to free them!",
		#20 self damage
		"callable": 
func (user, party, enemies, _target, battle): 
	single_attack(user, party, enemies, user, battle, "struggle")
	},
	"thank": {
		"base_atk": 0,
		"type": "eldritch",
		"effect": 0,
		"mp": 0,
		"desc": "Thank your enemy!",
		"enemy_flavor": "They thank CHAR for trying to free them!",
		"callable": single_attack.bind("thank")
	},
	"fireball": {
		"base_atk": 1.0,
		"type": "fire",
		"effect": 0,
		"mp": 0,
		"desc": "Fling a fireball!",
		"enemy_flavor": "They toss a fireball at CHAR! Fwoosh!",
		"callable": single_attack.bind("fireball")
	},
	"metamorphic attempt": {
		"base_atk": 1.0,
		"type": "fire",
		"effect": 0,
		"mp": 0,
		"desc": "Attempt to change your enemy, leaving them woozy!",
		"enemy_flavor": "They attempt to transform CHAR. It doesn’t quite work, but leaves them  woozy!",
		#-5 Evasion and -5DEF for 3 turns
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "metamorphic attempt", false, 0, -5, -5, 0)
	single_attack(user, party, enemies, target, battle, "metamorphic attempt")
	},
	"greater inspire": {
		"base_atk": 0,
		"type": "esoteric",
		"effect": 3,
		"mp": 30,
		"desc": "Inspire all allies to fight harder",
		"enemy_flavor": "They inspire their allies to fight harder!",
		#all ally ATK x1.3 and Luck x1.5 3 turns
		"callable": 
func (user, party, enemies, target, battle): 
	multi_stat_modify(user, party, enemies, target, battle, "greater inspire", true, 30, 0, 0, 50)
	},
	"zap": {
		"base_atk": 1.0,
		"type": "fire",
		"effect": 0,
		"mp": 0,
		"desc": "Zap them with electric fire!",
		"enemy_flavor": "They zap CHAR with electric fire! Zowch!",
		"callable": single_attack.bind("zap")
	},
	"slap": {
		"base_atk": 1.0,
		"type": "bludgeoning",
		"effect": 0,
		"mp": 0,
		"desc": "Backhand them",
		"enemy_flavor": "They flail and slap CHAR with an appendage!",
		"callable": single_attack.bind("slap")
	},
	"zap slap": {
		"base_atk": 2.0,
		"type": "fire",
		"effect": 0,
		"mp": 20,
		"desc": "Zap ‘em and slap ‘em!",
		"enemy_flavor": "They zap and slap CHAR!",
		"callable": single_attack.bind("zap slap")
	},
	"drug deal": {
		"base_atk": 1.0,
		"type": "mutagenic",
		"effect": 0,
		"mp": 5,
		"desc": "Give ‘em drugs",
		#-5 luck for 3 turns
		"enemy_flavor": "They give CHAR the deal of their life - free drugs, injected now!",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "drug deal", false, 0, 0, 0, -5)
	single_attack(user, party, enemies, target, battle, "drug deal")
	},
	"yap": {
		"base_atk": .5,
		"type": "esoteric",
		"effect": 0,
		"mp": 10,
		"desc": "Talk the kobold way",
		#hits all, -5 Evasion and -5 Def for 3 turns
		"enemy_flavor": "They talk the k0bold way, confusing and confounding the party!",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "yap", false, 0, 0, -5, 0)
	multi_attack(user, party, enemies, target, battle, "yap")
	},
	"coffee": {
		"base_atk": 0,
		"type": "fire",
		"effect": 5,
		"mp": 15,
		"desc": "Drink some coffee and speed up!",
		#heal 30, +5 Evasion and +5 Luck for 3 turns
		"enemy_flavor": "They drink some coffee, restoring health and improving their speed!",
		"callable": 
func (user, party, enemies, _target, battle): 
	stat_modify(user, party, enemies, user, battle, "coffee", false, 0, 0, 5, 5)
	#single_attack(user, party, enemies, target, battle, "coffee")
	heal(user, party, enemies, user, battle, "coffee", 30)
	},
	"freezing breath": {
		"base_atk": 1.5,
		"type": "frigid",
		"effect": 0,
		"mp": 20,
		"desc": "Breath cold to chill your enemies",
		#-10 Evasion for 3 turns
		"enemy_flavor": "They breath cold, slowing CHAR down!",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "freezing breath", false, 0, 0, -10, 0)
	single_attack(user, party, enemies, target, battle, "freezing breath")
	},
	"egg lay": {
		"base_atk": 0.0,
		"type": "esoteric",
		"effect": 2,
		"mp": 35,
		"desc": "Offer an egg to yourself or a friend in these trying times",
		# heal yourself or ally 50
		"enemy_flavor": "They lay an egg. Ew!",
		"callable": heal.bind("egg lay", 50)
	},
	"Howl UwU": {
		"base_atk": 0.5,
		"type": "esoteric",
		"effect": 1,
		"mp": 25,
		"desc": "Howl like a real wolf uwu  dealing damage and lower your enemies’ evasion!",
		# -5 Evasion and -5 Luck for 3 turns
		"enemy_flavor": "They howl! Shocking.",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "Howl UwU", false, 0, 0, -5, -5)
	single_attack(user, party, enemies, target, battle, "Howl UwU")
	},
	"distract :3c": {
		"base_atk": 0.75,
		"type": "mutagenic",
		"effect": 0,
		"mp": 0,
		"desc": "Lean over and jiggle your chest, \n distracting your enemy before giving them a playful (and clawful) swipe!",
		# -5 Def and -5 Evasion for 3 turns
		"enemy_flavor": "They distract CHAR, allowing them to get a sneaky hit!",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "distract :3c", false, 0, -5, -5, 0)
	single_attack(user, party, enemies, target, battle, "distract :3c")
	},
	"shock": {
		"base_atk": 1.25,
		"type": "fire",
		"effect": 0,
		"mp": 10,
		"desc": "Give them a shock!",
		# -10 DEF and -10 Luck for 3 turns
		"enemy_flavor": "Zzap! They shock CHAR, disorienting them",
		"callable": 
func (user, party, enemies, target, battle): 
	stat_modify(user, party, enemies, target, battle, "shock", false, 0, -10, 0, -10)
	single_attack(user, party, enemies, target, battle, "shock")
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
			printerr("ability %s is missing a required key" % a)


#func ability_callable(user, party, enemies:Array, target:int, battle:Battle):
	## applies an ability/item to the battle, each invididual ability should have its own func like this that the battle calls when its used
	## target is pos int for enemy target, neg int for party target, null for self
	## should modify turns, send weakness/other animations
	#pass
	
	
func single_attack(user:int, party, enemies:Array, target:int, battle:Battle, attack_name:String):
	var the_target = get_user(target, party, enemies)
	var the_user = get_user(user, party, enemies)
	var the_attack = abilities[attack_name]
	var mult = the_attack["base_atk"]
	var dmg_type := 0
	var is_crit := false
	#check weakness
	if the_target["stats"]["weaknesses"].has(the_attack["type"]):
		mult += 0.5
		dmg_type = 1
	elif the_target["stats"]["resistances"].has(the_attack["type"]):
		mult -= 0.5
		if mult < 0: mult = 0
		dmg_type = 2
	if randf() < (the_target["stats"].get_lck() / 100.0):
		mult += 1.0
		is_crit = true
	if randf() < (the_target["stats"].get_eva() - the_user["stats"].get_eva()) / 100.0:
		battle.add_turn(-1)
		dmg_type = 3
		mult = 0
		is_crit = false
	if is_crit or dmg_type == 1:
		battle.add_turn(1)
		
	#calculate damage
	var dmg : int = ceili((the_user["stats"].get_atk() * mult) * ( 1 - (the_target["stats"].get_def() / (the_target["stats"].get_def() + 25.0))))
	dmg = clampi(dmg, 0, 9999)
	the_target["hp"] -= dmg
	battle.animate_sprite(target)
	battle.animate_sprite(user, false)
	battle.show_dmg_label(dmg, target, dmg_type, is_crit)
	if target < 0:
		if the_target["hp"] <= 0:
			the_target["hp"] = 0
			battle.kill_party_member(abs(target) - 1)
	else:
		if the_target["hp"] <= 0:
			battle.kill_enemy(target)

	
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
		if num_targets < Globals.party.num_alive():
			for i in num_targets:
				picks.append(randi_range(0, Globals.party.p.size() - 1))
				for j in i:
					while picks[i] == picks[j] or Globals.party.p[picks[i]]["hp"] <= 0:
						picks[i] = randi_range(0, Globals.party.p.size() - 1)
			for i in picks.size():
				picks[i] = -(picks[i] + 1)
			#reverse so we can kill enemies
			picks.sort()
			picks.reverse()
			for t in picks:
				single_attack(user, party, enemies, t, battle, attack_name)
		else:
			multi_attack(user, party, enemies, target, battle, attack_name)
		
		

## hits all opposing targets
func multi_attack(user:int, party, enemies:Array, _target:int, battle:Battle, attack_name:String):
	var targets := []
	if user >= 0:
		#enemy, targeting players
		for p in party.num:
			if party.p[p]["hp"] > 0:
				targets.append(-(p + 1))
	else:
		#player, targeting enemies
		for e in enemies.size():
			targets.append(e)
		#reverse so we can kill enemies
		targets.reverse()
	for t in targets:
		single_attack(user, party, enemies, t, battle, attack_name)
	
	
## heals the target
func heal(_user:int, party, enemies:Array, target:int, battle:Battle, _attack_name:String, amount:int):
	var the_target = get_user(target, party, enemies)
		
	the_target["hp"] += amount
	the_target["hp"] = clampi(the_target["hp"], 0, the_target["stats"].hp)
	battle.animate_sprite(target)
	battle.show_dmg_label(-amount, target)
	#TODO anim


func single_mp_drain(_user, party, enemies, target, battle, mp_drain_amt):
	#TODO test
	var the_target = get_user(target, party, enemies)
	battle.animate_sprite(target)
	if target < 0:
		the_target["mp"] -= mp_drain_amt
		the_target["mp"] = clampi(the_target["mp"], 0, 99999)
	#TODO anim
	

func multi_mp_drain(user:int, party, _enemies, _target, _battle, mp_drain_amt:int):
	if user >= 0:
		for i in Globals.party.num:
			if Globals.party.p[i]["hp"] >= 0:
				Globals.party.p[i]["mp"] -= mp_drain_amt
				Globals.party.p[i]["mp"] = clampi(Globals.party.p[i]["mp"], 0, 99999)
	#TODO anim


func stat_modify(user:int, party, enemies, target:int, _battle, attack_name:String, percent:bool, atk:int, def:int, eva:int, lck:int):
	#check if target has stats.temp_stats key attack_name+user name
	var the_user = get_user(user, party, enemies)
	var the_target = get_user(target, party, enemies)
	var the_key := "%s-%s" % [the_user["enemy_name"], attack_name]
	if the_target.stats.temp_stats.has(the_key):
		#if it does, update temp_stats["turns"] to 3
		the_target.stats.temp_stats[the_key]["turns"] = 3
	else:
		#if it doesn't, add key with given stats
		var s := Stats.new()
		if percent:
			s.atk = floori(the_target.stats["atk"] * (atk / 100.0))
			s.def = floori(the_target.stats["def"] * (def / 100.0))
			s.eva = floori(the_target.stats["eva"] * (eva / 100.0))
			s.lck = floori(the_target.stats["lck"] * (lck / 100.0))
		else:
			s.atk = atk
			s.def = def
			s.eva = eva
			s.lck = lck
		the_target.stats.temp_stats[the_key] = {"turns": 3, "stats": s}
	#TODO anim
	

func multi_stat_modify(user:int, party, enemies, target:int, battle, attack_name:String, percent:bool, atk:int, def:int, eva:int, lck:int):
	#TODO test
	var targets := []
	if (user >= 0 and target < 0):
		#targeting players
		for p in party.num:
			if party.p[p]["hp"] > 0:
				targets.append(-(p + 1))
	else:
		#targeting enemies
		for e in enemies.size():
			targets.append(e)
	for t in targets:
		stat_modify(user, party, enemies, t, battle, attack_name, percent, atk, def, eva, lck)
	

func DONTUSEME(_user:int, _party, _enemies:Array, _target:int, _battle:Battle):
	printerr("DONTUSEME")


func get_user(user:int, party, enemies):
	var the_user
	if user >= 0:
		if enemies.size() == 0:
			return
		the_user = enemies[user]
	else:
		the_user = party.p[abs(user) - 1]
	return the_user
