extends MarginContainer
#TODO use inventory items in field - mp restore, escape item
#TODO inventory paging or just scroll?

@onready var item_grid_container : Container = %ItemGridContainer
var is_battle := false

func _ready() -> void:
	var items := Globals.inventory.inv.keys()
	items.sort()
	for item in items:
		if not Globals.inventory.items.has(item):
			printerr("non-existant item %s in inventory" % item)
			continue
		var amt_label := Label.new()
		amt_label.text = "x%d" % Globals.inventory.inv[item]
		amt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var name_label := Label.new()
		name_label.text = item.capitalize()
		var desc_label := Label.new()
		desc_label.text = Globals.inventory.items[item]["desc"]
		var icon_rect := TextureRect.new()
		icon_rect.texture = load(Globals.inventory.items[item]["icon"])
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		var use_butt := Button.new()
		use_butt.text = "Use"
		if is_battle:
			use_butt.disabled = not Globals.inventory.items[item]["is_battle_usable"]
		else:
			use_butt.disabled = not Globals.inventory.items[item]["is_field_usable"]
		item_grid_container.add_child(amt_label)
		item_grid_container.add_child(use_butt)
		item_grid_container.add_child(icon_rect)
		item_grid_container.add_child(name_label)
		item_grid_container.add_child(desc_label)


func _on_close_inventory_button_pressed() -> void:
	queue_free()
