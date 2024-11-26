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


func level_up_stats(l:int) -> String:
	#TODO different stats for different party members
	match l:
		2:
			p[0].stats.hp += 10
			p[0].stats.mp += 10
			p[0].stats.atk += 2
		3:
			p[0].stats.hp += 10
			p[0].stats.mp += 10
			p[0].stats.atk += 3
		4:
			p[0].stats.hp += 15
			p[0].stats.mp += 15
			p[0].stats.atk += 5
		5:
			p[0].stats.def += 10
			p[0].stats.lck += 5
			p[0].stats.move_slots += 1
	return "TODO implement"
