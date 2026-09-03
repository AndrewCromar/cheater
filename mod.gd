extends Node

func _ready():
	print("[Mod] Loaded successfully!")
	call_deferred("_create_test_popup")

func _create_test_popup():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var dialog = AcceptDialog.new()
	dialog.title = "Mod Injection Success!"
	dialog.dialog_text = "mod.gd was successfully injected via AutoLoad!\nYour patch script works correctly."
	
	canvas_layer.add_child(dialog)
	
	dialog.popup_centered(Vector2i(350, 120))
