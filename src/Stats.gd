extends Resource
class_name Stats

var hp := 100
# used to use abilities
var mp := 100
# damage added to your base attack
var atk := 10
# negate up to 50% damage as compared to attacker's atk, logarithmicly
var def := 10
# combination of your chance to dodge attacks and hit enemies
var eva := 10
# item/cash drop rate, critical hits
var lck := 10

var img : Texture2D
var character_name : String

var abilities := []
var level := 1
var xp := 0
var equipment := {"Head": "", "Body": "", "Ring": ""}
