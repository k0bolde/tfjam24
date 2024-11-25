extends Control
#TODO update player reminder text based on story_flag
#TODO debug options: load specific dialogue, give items
@onready var settings_panel : PanelContainer = %SettingsPanel
@onready var fullscreen_checkbutton : CheckButton = %FullscreenCheckButton
@onready var menu_container : Container = %MenuContainer
@onready var debug_container : Container = %DebugContainer
@onready var debug_maps_container : Container = %DebugMapsContainer
@onready var flag_container : Container = %FlagContainer
@onready var inventory_container : Container = %InventoryContainer
@onready var item_grid_container : Container = %ItemGridContainer
var map_names := ["Apartment", "ApartmentCorridor", "Hub", "Map1", "QuarantineZone"]


func _ready() -> void:
	debug_container.visible = false
	settings_panel.visible = false
	%DebugButton.visible = OS.is_debug_build()
	menu_container.rotation_degrees = 90.0
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 0.0, 0.35)
	%CashLabel.text = "$%s" % Globals.cash
	if OS.is_debug_build():
		if not OS.has_feature("editor"):
			#diraccess doesn't work on exported games
			for m in map_names:
				var mb := Button.new()
				mb.text = m
				mb.pressed.connect(func (): Globals.main.load_map(m, 0))
				debug_maps_container.add_child(mb)
		else:
			var map_dir := DirAccess.open("res://src/maps")
			for m in map_dir.get_files():
				if m.ends_with(".tscn"):
					var mb := Button.new()
					var map_name := m.trim_suffix(".tscn")
					mb.text = map_name
					mb.pressed.connect(func (): Globals.main.load_map(map_name, 0))
					debug_maps_container.add_child(mb)
		for f in Globals.main.story_flags.keys():
			var l := Label.new()
			l.text = f
			flag_container.add_child(l)
			var s := SpinBox.new()
			s.update_on_text_changed = true
			s.value = Globals.main.story_flags[f]
			s.value_changed.connect(func (new_value): Globals.main.story_flags[f] = new_value)
			flag_container.add_child(s)
		for eb in get_tree().get_nodes_in_group("enemy_selector"):
			eb.add_item("")
		for en in Globals.enemies:
			for eb in get_tree().get_nodes_in_group("enemy_selector"):
				eb.add_item(en)
		%PartyNumBox.value = Globals.party.num
		%RandomEncountersButton.button_pressed = Globals.debug_disable_random_encounters
		%CashSpinBox.value = Globals.cash
		%LevelSpinbox.value = Globals.party.level
		%LevelSpinbox.value_changed.connect(_on_level_spinbox_value_changed)
	
	inventory_container.visible = false
	for item in Globals.inventory.inv.keys():
		if not Globals.inventory.items.has(item):
			continue
		var amt_label := Label.new()
		amt_label.text = "%d" % Globals.inventory.inv[item]
		var name_label := Label.new()
		name_label.text = item
		var desc_label := Label.new()
		desc_label.text = Globals.inventory.items[item]["desc"]
		item_grid_container.add_child(amt_label)
		item_grid_container.add_child(name_label)
		item_grid_container.add_child(desc_label)


func _on_close_button_pressed() -> void:
	var t : Tween = get_tree().create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(menu_container, "rotation_degrees", 90.0, 0.1)
	t.tween_callback(queue_free)


func _on_main_menu_button_pressed() -> void:
	var popup := PopupMenu.new()
	popup.add_item("Are you sure? You might want to save.")
	popup.set_item_disabled(0, true)
	popup.add_item("Yes")
	popup.index_pressed.connect(func (idx): 
		if idx == 1:
			get_tree().change_scene_to_file("res://src/TitleScreen.tscn")
		)
	%MainMenuButton.add_child(popup)
	popup.popup_centered(Vector2i(100, 30))


func disable_buttons():
	for butt in get_tree().get_nodes_in_group("disableable"):
		butt.disabled = true
	
	
func enable_buttons():
	for butt in get_tree().get_nodes_in_group("disableable"):
		butt.disabled = false


func _on_settings_button_pressed() -> void:
	if settings_panel.visible:
		enable_buttons()
		settings_panel.visible = false
	else:
		disable_buttons()
		%SettingsButton.disabled = false
		settings_panel.visible = true
		fullscreen_checkbutton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		%VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
		%ActionCamButton.button_pressed = Globals.use_action_cam


func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
		if toggled_on:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_slider_value_changed(value: float) -> void:
	#print("db was %s" % AudioServer.get_bus_volume_db(0))
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_save_button_pressed() -> void:
	var popup := PopupMenu.new()
	popup.add_item("Are you sure? This will overwrite your old save.")
	popup.set_item_disabled(0, true)
	popup.add_item("Yes")
	popup.index_pressed.connect(func (idx): 
		if idx == 1:
			Globals.save_game()
		)
	%SaveButton.add_child(popup)
	popup.popup_centered(Vector2i(100, 30))


func _on_load_button_pressed() -> void:
	var popup := PopupMenu.new()
	if FileAccess.file_exists("user://save.tres"):
		popup.add_item("Are you sure?")
		popup.set_item_disabled(0, true)
		popup.add_item("Yes")
		popup.index_pressed.connect(func (idx): 
			if idx == 1:
				Globals.load_game()
			)
	else:
		popup.add_item("No save file exists. Save first!")
	%LoadButton.add_child(popup)
	popup.popup_centered(Vector2i(100, 30))


func _on_debug_button_pressed() -> void:
	debug_container.visible = not debug_container.visible


func _on_action_cam_button_toggled(toggled_on: bool) -> void:
	Globals.use_action_cam = toggled_on


func _on_party_num_box_value_changed(value: float) -> void:
	Globals.party.num = value


func _on_start_battle_button_pressed() -> void:
	var ma := []
	for eb in get_tree().get_nodes_in_group("enemy_selector"):
		var i = eb.get_selected_id()
		if i >= 0:
			var m : String = eb.get_item_text(i)
			if m != "":
				ma.append(m)
	if not ma.is_empty():
		_on_close_button_pressed()
		Events.battle_start.emit(ma, true)


func _on_level_spinbox_value_changed(value: float) -> void:
	Globals.party.level = value
	Globals.party.level_up_stats(value)
	%LevelSpinbox.min_value = value


func _on_mp_button_pressed() -> void:
	for p in Globals.party.p:
		p["mp"] = p.stats.mp


func _on_items_button_pressed() -> void:
	disable_buttons()
	inventory_container.visible = true


func _on_close_inventory_button_pressed() -> void:
	enable_buttons()
	inventory_container.visible = false


func _on_random_encounters_button_toggled(toggled_on: bool) -> void:
	Globals.debug_disable_random_encounters = toggled_on


func _on_cash_spin_box_value_changed(value: float) -> void:
	Globals.cash = value


func _on_invincible_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_inf_mp_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
