	if not Engine.is_editor_hint():
		var _mod_path = "res://mod.gd"
		if ResourceLoader.exists(_mod_path):
			var _root = Engine.get_main_loop().root
			if not _root.has_node("CheaterModNode"):
				var _mod_script = load(_mod_path)
				if _mod_script:
					var _mod_instance = Node.new()
					_mod_instance.name = "CheaterModNode"
					_mod_instance.set_script(_mod_script)
					_root.call_deferred("add_child", _mod_instance)