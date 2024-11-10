extends Resource
class_name Party
# Holds info about the party, like stats and current numbers

@export var num := 1
@export var p := [
	{"stats": Stats.new(), "hp": 100, "mp": 100},
	{"stats": Stats.new(), "hp": 100, "mp": 100},
	{"stats": Stats.new(), "hp": 100, "mp": 100},
	{"stats": Stats.new(), "hp": 100, "mp": 100},
]
@export var xp := 0
@export var level := 1
