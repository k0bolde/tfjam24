extends StaticBody2D
class_name NPC

## The image to show for the npc
@export var image : Texture2D
## The clyde dialogue file 
@export_file("*.clyde") var dialogue

@onready var talk_area : Area2D = $TalkArea


func _ready() -> void:
	if image:
		$Sprite2D.texture = image
	talk_area.body_entered.connect(_on_body_entered)
	talk_area.body_exited.connect(_on_body_exited)
	
	
func _on_body_entered(body):
	pass
	
	
func _on_body_exited(body):
	pass
