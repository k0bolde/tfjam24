extends Node2D
class_name Battle

@onready var cam3d : Camera3D = %IdleCamera

var enemies := []
var cam_tween : Tween
@onready var battle_center : Marker3D = %BattleCenter

func _ready() -> void:
	#TODO load enemies in
	#%SubViewport.size = %SubViewportContainer.size
	# fade in
	%FadeRect.visible = true
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(%FadeRect, "modulate", Color(0, 1, 0, 0), 1)
	
	# set up idle cam movement
	cam_tween = Globals.get_tween(cam_tween, self)
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.set_loops()
	var cam_start_pos := cam3d.position
	cam_tween.tween_property(cam3d, "position:x", cam_start_pos.x + 1, 5)
	cam_tween.tween_property(cam3d, "position:x", cam_start_pos.x, 0)
	cam_tween.tween_property(cam3d, "position:z", 0, 0)
	cam_tween.tween_property(cam3d, "position:y", cam_start_pos.y + 0.5, 5)
	cam_tween.tween_property(cam3d, "position:y", cam_start_pos.y, 0)
	cam_tween.tween_property(cam3d, "position:z", cam_start_pos.z, 0)


func _process(delta: float) -> void:
	cam3d.look_at(battle_center.position)

func _on_run_button_pressed() -> void:
	Events.battle_end.emit()
