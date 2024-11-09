extends Area2D
@export var map_name := "DefaultMap"
@export var entrance_num := 0

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	

func _body_entered(body):
	body.interact_label.text = "Exit"
	body.interact_container.visible = true
	body.interact_callback = Globals.main.load_map.bind(map_name, entrance_num)
	
	
func _body_exited(body):
	body.interact_label.text = ""
	body.interact_container.visible = false
	body.interact_callback = null
