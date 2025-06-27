class_name SceneManager
extends RefCounted

#region Signals
signal setting_scene
signal previous_scene_freed
signal scene_set(state: bool)
#endregion

#region Private Variables
var _scene_container: Node
var _scenes_map: Dictionary[Variant, PackedScene]

var _current_scene_index: Variant
var _current_scene_node: Node

var _init_is_valid: bool
#endregion

#region Virtual Methods
func _init(scene_container: Node, scenes_map: Dictionary[Variant, PackedScene]) -> void:
	if scene_container == null:
		Logger.critical(_init, "The scene container cannot be null!")
		return
	
	if scenes_map.is_empty():
		Logger.critical(_init, "The scenes map cannot be empty!")
		return
	
	var scenes_map_are_valid: bool = true
	
	for scene_index: Variant in scenes_map:
		if scenes_map[scene_index] is not PackedScene:
			Logger.critical(_init, "The scene map value with index: [%s], is not a valid PackedScene!" % scene_index)
			scenes_map_are_valid = false
	
	if not scenes_map_are_valid:
		return
	
	_scene_container = scene_container
	_scenes_map = scenes_map
	_init_is_valid = true


func _to_string() -> String:
	return "SceneManager"
#endregion

#region Public Methods
func set_scene(scene_index: Variant, options: SceneManagerOptions = null) -> void:
	if not _init_is_valid:
		Logger.critical(set_scene, "The initialization phase failed!")
		return
	
	if options == null:
		options = SceneManagerOptions.new()
	
	setting_scene.emit()
	
	if is_same(_current_scene_index, scene_index) and not options.override_same_scene:
		Logger.warning(set_scene, "The scene with index: [%s], is already active." % _current_scene_index)
		scene_set.emit(false)
		return
	
	if _scenes_map.get(scene_index) == null:
		Logger.error(set_scene, "Packed scene with index: [%s] does not exist!" % scene_index)
		scene_set.emit(false)
		return
	
	if _current_scene_node != null:
		_current_scene_node.tree_exited.connect(previous_scene_freed.emit)
		_current_scene_node.queue_free()
	
	if options.wait_time > 0.0:
		await _scene_container.get_tree().create_timer(options.wait_time).timeout
	
	_current_scene_index = scene_index
	_current_scene_node = _scenes_map[scene_index].instantiate()
	
	for property: StringName in options.scene_arguments:
		if not property in _current_scene_node:
			Logger.error(set_scene, "Missing property: '%s' on scene with index: [%s]!" % [property, scene_index])
			continue
		
		_current_scene_node.set(property, options.scene_arguments[property])
	
	if options.log_success_messages:
		_current_scene_node.tree_entered.connect(
			Logger.success.bind(set_scene, "Scene with index: [%s], was successfully set." % scene_index)
			)
		_current_scene_node.ready.connect(
			Logger.info.bind(set_scene, "Scene with index: [%s], is now ready." % scene_index)
			)
	
	_scene_container.add_child(_current_scene_node)
	
	UtilsWindow.update_window(
		options.window_size,
		options.window_borderless,
		options.window_resizable,
		options.window_transparent,
		options.window_move_to_center,
		options.window_mode,
	)
	
	scene_set.emit(true)
#endregion
