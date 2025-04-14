class_name UtilsEngine


static func is_editor() -> bool:
	return OS.has_feature("editor")


static func get_tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


static func get_current_scene() -> Node:
	return get_tree().current_scene
