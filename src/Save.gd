extends Resource
class_name Save

# only things with @export are saved to file
@export var cash := 0
@export var story_flags := {}
@export var inventory : Resource
@export var party : Resource
@export var map := "map1"
@export var day := 0
@export var use_action_cam := false

@export var location := Vector2()
