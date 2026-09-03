extends Node

var reference_player: Node = null
var player_status_label: Label
var canvas_layer: CanvasLayer
var menu_panel: PanelContainer
var is_menu_visible: bool = false

func _ready() -> void:
	_build_mod_menu()
	call_deferred("_create_test_popup")

func _process(_delta: float) -> void:
	if not is_instance_valid(reference_player):
		reference_player = _find_player_node(get_tree().root)
	
	_update_ui_display()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_SHIFT and event.location == KEY_LOCATION_RIGHT:
			_toggle_menu()

func _find_player_node(current_node: Node) -> Node:
	if not is_instance_valid(current_node):
		return null

	# 1. Match by attached script filename (e.g. Player.gd, player.gd)
	var script_obj = current_node.get_script()
	if script_obj != null and script_obj is Script:
		var res_path = script_obj.resource_path
		if res_path and res_path.get_file().to_lower().begins_with("player"):
			return current_node

	# 2. Match by Node name in tree
	if current_node.name.to_lower().contains("player"):
		return current_node

	# Recursively check children
	for child in current_node.get_children():
		var found = _find_player_node(child)
		if found:
			return found

	return null

func _update_ui_display() -> void:
	if not player_status_label:
		return

	if is_instance_valid(reference_player):
		var pos = reference_player.global_position if "global_position" in reference_player else reference_player.position
		player_status_label.text = "Player: FOUND (" + reference_player.name + ")\nPosition: " + str(pos)
		player_status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		player_status_label.text = "Player: SEARCHING..."
		player_status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

func _build_mod_menu() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128
	add_child(canvas_layer)

	menu_panel = PanelContainer.new()
	menu_panel.visible = false
	menu_panel.custom_minimum_size = Vector2(300, 200)
	menu_panel.position = Vector2(50, 50)
	canvas_layer.add_child(menu_panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	menu_panel.add_child(main_vbox)

	var title_label = Label.new()
	title_label.text = "Andrew's Mod"
	title_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	main_vbox.add_child(title_label)

	player_status_label = Label.new()
	main_vbox.add_child(player_status_label)

func _toggle_menu() -> void:
	is_menu_visible = !is_menu_visible
	menu_panel.visible = is_menu_visible

func _create_test_popup() -> void:
	var popup_layer = CanvasLayer.new()
	popup_layer.layer = 129
	add_child(popup_layer)

	var dialog = AcceptDialog.new()
	dialog.title = "Mod Injection Success!"
	dialog.dialog_text = "Andrew's mod was successfully injected!\nPress RIGHT SHIFT to toggle the mod menu."
	
	popup_layer.add_child(dialog)
	dialog.popup_centered(Vector2i(360, 130))