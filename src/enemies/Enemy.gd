extends Node

@export var hp := 10
var attack_probabilities := {}
@export var cash_reward := 100
@export var xp_reward := 100
@export var level := 1
var item_drops := {}

var stats := Stats.new()
