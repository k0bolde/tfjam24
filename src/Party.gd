extends Resource
class_name Party
# Holds info about the party, like stats and current numbers

@export var num := 3
@export var p := [
	{"stats": Stats.new(), "hp": 100, "mp": 100, "name": "Finley", "ingame_sprite": null, "image": "res://assets/tv_sprites/player_chars/dragon_128x.png"},
	{"stats": Stats.new(), "hp": 100, "mp": 100, "name": "Jesse", "ingame_sprite": null, "image": "res://assets/tv_sprites/player_chars/jesse1.png"},
	{"stats": Stats.new(), "hp": 100, "mp": 100, "name": "Sock", "ingame_sprite": null, "image": "res://assets/tv_sprites/player_chars/sci_raptor_128x.png"},
	{"stats": Stats.new(), "hp": 100, "mp": 100, "name": "Ceron", "ingame_sprite": null, "image": ""},
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
