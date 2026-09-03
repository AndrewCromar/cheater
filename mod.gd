extends Node

var reference_player: Node = null
var mod_window: Window

func _ready():
	_grab_references()
	_build_mod_menu()
	call_deferred("_create_test_popup")

func _grab_references() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_SHIFT and event.location == KEY_LOCATION_RIGHT:
			_toggle_menu()

func _build_mod_menu() -> void:
	mod_window = Window.new()
	mod_window.title = "Andrew's Mod"
	mod_window.size = Vector2i(250, 150)
	mod_window.visible = false
	mod_window.close_requested.connect(_toggle_menu)
	add_child(mod_window)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	mod_window.add_child(margin)

	var label = Label.new()
	label.text = "Menu active."
	margin.add_child(label)

func _toggle_menu() -> void:
	mod_window.visible = !mod_window.visible
	if mod_window.visible:
		mod_window.popup_centered()

func _create_test_popup() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var dialog = AcceptDialog.new()
	dialog.title = "Mod Injection Success!"
	dialog.dialog_text = "Andrew's mod was successfully injected!\nPress right shift to toggle the mod menu."
	
	canvas_layer.add_child(dialog)
	dialog.popup_centered(Vector2i(350, 120))