extends Node2D
class_name Battle
#TODO basic battles - attack, select, kill, die, end
# Attack - apply atk to enemy def, eva miss/crit chance, update enemy hp, animations and waiting for them (tweens with unlock callbacks?). Ability select menu
# Enemy Attack - pick attack, apply atk to player def, eva miss/crit chance, update player hp
# Select - left/right buttons? mouse select (would need physics object picking on viewport), move light indicator
# Kill - when enemy hp 0 - remove sprite. When all enemies die, battle end. money and item drops - result screen?
# Die - when player hp 0 - death screen, kick to main menu?

@onready var idle_cam : Camera3D = %IdleCamera
@onready var action_cam : Camera3D = %ActionCamera
@onready var battle_center : Marker3D = %BattleCenter
@onready var enemies_node : Node3D = %Enemies
@onready var party_node : Node3D = %Party
@onready var indicator_light : SpotLight3D = %IndicatorLight
@onready var turns_label : Label = %TurnsLabel
@onready var hp_bar : ProgressBar = %HPBar
@onready var hp_label : Label = %HPLabel
@onready var mp_bar : ProgressBar = %MPBar
@onready var mp_label : Label = %MPLabel
@onready var enemy_hp_bar : ProgressBar = %EnemyHPBar
@onready var weakness_label : Label3D = %WeaknessLabel

var enemy_names := []
var enemies : Array[Enemy] = []
var cam_tween : Tween
var turns := 1


func _ready() -> void:
	if enemy_names.size() > 0:
		for en in enemy_names:
			enemies.push_back(Globals.enemies[en.to_lower()].duplicate())
	else:
		printerr("no enemy names, loading test enemies")
		enemies.push_back(Globals.enemies["slime"].duplicate())
		enemies.push_back(Globals.enemies["rat"].duplicate())
	for i in enemies.size():
		enemies[i].position = %EnemyPos1.position
		enemies[i].position.z -= i
		var sprite := Sprite3D.new()
		sprite.texture = load(enemies[i].texture_path)
		sprite.region_enabled = true
		sprite.region_rect = enemies[i].region_rect
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.shaded = true
		sprite.flip_h = true
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sprite.position = enemies[i].position
		enemies_node.add_child(sprite)
		
	# fade in
	%FadeRect.visible = true
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(%FadeRect, "modulate", Color(0, 1, 0, 0), 1)
	
	# set up idle cam movement
	cam_tween = Globals.get_tween(cam_tween, self)
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.set_loops()
	var cam_start_pos := idle_cam.position
	cam_tween.tween_property(idle_cam, "position:x", cam_start_pos.x + 2, 5)
	cam_tween.tween_property(idle_cam, "position:x", cam_start_pos.x, 0)
	cam_tween.tween_property(idle_cam, "position:z", 0, 0)
	cam_tween.tween_property(idle_cam, "position:y", cam_start_pos.y + 0.5, 5)
	cam_tween.tween_property(idle_cam, "position:y", cam_start_pos.y, 0)
	cam_tween.tween_property(idle_cam, "position:z", cam_start_pos.z, 0)
	
	#setup hp/mp/turns
	update_bars(Globals.party.hp1, Globals.party.stats1.hp, Globals.party.mp1, Globals.party.stats1.mp)
	

func _process(_delta: float) -> void:
	idle_cam.look_at(battle_center.position)


func update_bars(hp, hp_max, mp, mp_max):
	turns_label.text = "%d" % turns
	hp_label.text = "%d/%d" % [hp, hp_max]
	hp_bar.max_value = hp_max
	hp_bar.value = hp
	mp_label.text = "%d/%d" % [mp, mp_max]
	mp_bar.max_value = mp_max
	mp_bar.value = mp
	

func _on_run_button_pressed() -> void:
	Events.battle_end.emit()
	
	
func player_attack(which_attack:String):
	
	turns -= 1
	%TurnsLabel.text = "%d" % turns
	if turns <= 0:
		turns = enemies.size()
		enemy_attack(0)
	
	
func enemy_attack(which_enemy:int):
	
	turns -= 1
	%TurnsLabel.text = "%d" % turns
	if turns > 0:
		enemy_attack(which_enemy + 1)
		
	
func ability_callable(user, party:Array, enemies:Array, target:int, battle:Battle):
	# applies an ability/item to the battle, each invididual ability should have its own func like this that the battle calls when its used
	# target is pos int for enemy target, neg int for party target, null for self
	# should modify turns, send weakness/other animations
	pass


func _on_basic_attack_button_pressed() -> void:
	player_attack("basic")


func _on_target_left_button_pressed() -> void:
	pass # Replace with function body.


func _on_target_right_button_pressed() -> void:
	pass # Replace with function body.
