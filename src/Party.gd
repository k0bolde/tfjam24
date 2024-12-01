extends Resource
class_name Party
# Holds info about the party, like stats and current numbers

@export var num := 2
@export var p := [
	{"stats": Stats.new(), 
		"hp": 100, "mp": 100, 
		"name": "Finley", "enemy_name": "Finley", 
		"ingame_sprite": null, 
		"image": "res://assets/battle/finley2.png", 
		"visual_scale": 1.0},
	{"stats": Stats.new(), 
		"hp": 100, "mp": 100, 
		"name": "Jesse", "enemy_name": "Jesse", 
		"ingame_sprite": null, 
		"image": "res://assets/tv_sprites/player_chars/jesse1.png", 
		"visual_scale": 1.0},
	{"stats": Stats.new(), 
		"hp": 100, "mp": 100, 
		"name": "Sock", "enemy_name": "Sock", 
		"ingame_sprite": null, 
		"image": "res://assets/tv_sprites/player_chars/sci_raptor_128x.png", 
		"visual_scale": 1.0},
	{"stats": Stats.new(), 
		"hp": 100, "mp": 100, 
		"name": "Ceron", "enemy_name": "Ceron", 
		"ingame_sprite": null, 
		"image": "", 
		"visual_scale": 1.0},
]
@export var xp := 0
@export var level := 1
@export var fought_enemies := []


func num_alive() -> int:
	var alive := 0
	for i in num:
		if p[i]["hp"] > 0:
			alive += 1
	return alive


func get_xp_required_for_next_level() -> int:
	match level:
		1:
			return 10
		2:
			return 50
		3:
			return 150
		4:
			return 300
	return 99999


func level_up_stats(l:int) -> String:
	var s := "\n"
	match l:
		2:
			p[0].stats.hp += 10
			p[0].stats.mp += 10
			p[0].stats.atk += 2
			s += "Finley: HP +10, MP +10, ATK +2\n"
			p[1].stats.hp += 10
			p[1].stats.mp += 10
			p[1].stats.atk += 5
			s += "Jesse: HP +10, MP +10, ATK +5\n"
		3:
			p[0].stats.hp += 10
			p[0].stats.mp += 10
			p[0].stats.atk += 3
			s += "Finley: HP +10, MP +10, ATK +3\n"
			
			p[1].stats.hp += 15
			p[1].stats.mp += 10
			p[1].stats.def += 5
			s += "Jesse: HP +15, MP +10, DEF +5\n"
		4:
			p[0].stats.hp += 15
			p[0].stats.mp += 15
			p[0].stats.atk += 5
			s += "Finley: HP +15, MP +15, ATK +5\n"
			
			p[1].stats.hp += 15
			p[1].stats.mp += 10
			p[1].stats.lck += 5
			s += "Jesse: HP +15, MP +10, LCK +5\n"
		5:
			p[0].stats.eva += 10
			p[0].stats.lck += 5
			p[0].stats.move_slots += 1
			s += "Finley: EVA +10, LCK +5, Move Slots +1\n"
			
			p[1].stats.eva += 5
			p[1].stats.lck += 5
			p[1].stats.move_slots += 1
			s += "Jesse: EVA +5, LCK +5, Move Slots +1\n"
	return s.trim_suffix("\n")
