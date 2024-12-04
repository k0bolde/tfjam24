@tool
extends StaticBody2D
class_name NPC

## The image to show for the npc
@export var image : Texture2D
## The clyde dialogue file 
@export_file("*.clyde") var dialogue_file
@export var block := ""
@export var flip_h := false
@export var dont_repeat := false
var been_talked_to := false

@onready var talk_area : Area2D = $TalkArea
var enabled := true


func _ready() -> void:
	if image:
		$Sprite2D.texture = image
		if image.get_height() != 32:
			var scaled := 32.0 / image.get_height()
			$Sprite2D.scale = Vector2(scaled, scaled)
		$Sprite2D.flip_h = flip_h
		
	if not Engine.is_editor_hint():
		talk_area.body_entered.connect(_on_body_entered)
		talk_area.body_exited.connect(_on_body_exited)
	
	
func _on_body_entered(body):
	if dialogue_file and enabled:
		body.npc = self
		body.interact_container.visible = true
		body.interact_label.text = "Talk"
	
	
func _on_body_exited(body):
	if body.npc == self:
		body.npc = null
		body.interact_container.visible = false


func start_talk():
	if dont_repeat and been_talked_to:
		block = "repeat"
	Globals.main.end_battle()
	Globals.main.start_dialogue(dialogue_file, block)
	been_talked_to = true
	
	
	
	
	
	
	
