extends Node

func _ready():
	call_deferred("_create_test_popup")

func _create_test_popup():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var dialog = AcceptDialog.new()
	dialog.title = "Mod Injection Success!"
	dialog.dialog_text = "Andrew's mod was successfully injected!\nPress right shift to toggle the mod menu."
	
	canvas_layer.add_child(dialog)
	
	dialog.popup_centered(Vector2i(350, 120))
