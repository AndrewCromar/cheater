extends Node

var canvas_layer: CanvasLayer
var menu_panel: PanelContainer
var is_menu_visible: bool = false
var status_label: Label
var active_player: Node = null

var bounce_slider: HSlider
var bounce_value_label: Label

func _ready() -> void:
	_build_mod_menu()
	call_deferred("_create_test_popup")

func _process(_delta: float) -> void:
	_update_player_reference()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_SEMICOLON:
			_toggle_menu()

func _update_player_reference() -> void:
	if active_player and not is_instance_valid(active_player):
		active_player = null

	if not active_player:
		if has_node("/root/Map/Player_Singleplayer/Player"):
			active_player = get_node("/root/Map/Player_Singleplayer/Player")

	if not active_player:
		for p in get_tree().get_nodes_in_group("player"):
			if is_instance_valid(p) and (p is RigidBody3D or p is CharacterBody3D):
				active_player = p
				break

	var has_player = is_instance_valid(active_player)
	
	if status_label:
		status_label.text = "Has Player: " + ("True" if has_player else "False")

	if bounce_slider:
		bounce_slider.editable = has_player
		if has_player and not bounce_slider.has_focus() and "bounce_force" in active_player:
			bounce_slider.value = active_player.bounce_force
			bounce_value_label.text = "Bounce: " + str(snapped(active_player.bounce_force, 0.1))

func _on_bounce_slider_changed(value: float) -> void:
	if is_instance_valid(active_player) and "bounce_force" in active_player:
		active_player.bounce_force = value
		bounce_value_label.text = "Bounce: " + str(snapped(value, 0.1))

func _build_mod_menu() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 9999
	add_child(canvas_layer)

	menu_panel = PanelContainer.new()
	menu_panel.visible = false
	menu_panel.position = Vector2(50, 50)
	menu_panel.custom_minimum_size = Vector2(300, 120)
	canvas_layer.add_child(menu_panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	menu_panel.add_child(margin)

	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	margin.add_child(container)

	var title_label = Label.new()
	title_label.text = "Mod Controls"
	container.add_child(title_label)

	status_label = Label.new()
	status_label.text = "Has Player: False"
	container.add_child(status_label)

	var bounce_box = HBoxContainer.new()
	container.add_child(bounce_box)

	bounce_value_label = Label.new()
	bounce_value_label.text = "Bounce: 0.0"
	bounce_value_label.custom_minimum_size = Vector2(100, 0)
	bounce_box.add_child(bounce_value_label)

	bounce_slider = HSlider.new()
	bounce_slider.min_value = 0.0
	bounce_slider.max_value = 100.0
	bounce_slider.step = 0.5
	bounce_slider.editable = false
	bounce_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bounce_slider.value_changed.connect(_on_bounce_slider_changed)
	bounce_box.add_child(bounce_slider)

func _toggle_menu() -> void:
	is_menu_visible = !is_menu_visible
	menu_panel.visible = is_menu_visible

func _create_test_popup() -> void:
	var popup_layer = CanvasLayer.new()
	popup_layer.layer = 10000
	add_child(popup_layer)

	var dialog = AcceptDialog.new()
	dialog.title = "Mod Injected!"
	dialog.dialog_text = "Mod loaded!\nPress ';' to toggle menu."
	
	popup_layer.add_child(dialog)
	dialog.popup_centered(Vector2i(280, 100))