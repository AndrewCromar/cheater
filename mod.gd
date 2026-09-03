extends Node

var canvas_layer: CanvasLayer
var menu_panel: PanelContainer
var hint_label: Label
var is_menu_visible: bool = false
var active_player: Node = null

var bounce_box: HBoxContainer
var bounce_slider: HSlider
var bounce_value_label: Label

func _ready() -> void:
	_build_mod_menu()

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
	
	if bounce_box:
		bounce_box.visible = has_player

	if bounce_slider and has_player:
		if not bounce_slider.has_focus() and "bounce_force" in active_player:
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

	hint_label = Label.new()
	hint_label.text = "Press ';' to open mod menu"
	hint_label.position = Vector2(10, 10)
	hint_label.add_theme_font_size_override("font_size", 12)
	canvas_layer.add_child(hint_label)

	menu_panel = PanelContainer.new()
	menu_panel.visible = false
	menu_panel.position = Vector2(20, 20)
	menu_panel.custom_minimum_size = Vector2(220, 50)
	canvas_layer.add_child(menu_panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	menu_panel.add_child(margin)

	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)
	margin.add_child(container)

	var title_label = Label.new()
	title_label.text = "Mod Controls"
	container.add_child(title_label)

	bounce_box = HBoxContainer.new()
	bounce_box.visible = false
	container.add_child(bounce_box)

	bounce_value_label = Label.new()
	bounce_value_label.text = "Bounce: 0.0"
	bounce_value_label.custom_minimum_size = Vector2(80, 0)
	bounce_box.add_child(bounce_value_label)

	bounce_slider = HSlider.new()
	bounce_slider.min_value = 0.0
	bounce_slider.max_value = 200.0
	bounce_slider.step = 1
	bounce_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bounce_slider.value_changed.connect(_on_bounce_slider_changed)
	bounce_box.add_child(bounce_slider)

func _toggle_menu() -> void:
	is_menu_visible = !is_menu_visible
	menu_panel.visible = is_menu_visible
	hint_label.visible = !is_menu_visible
	
	if is_menu_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED