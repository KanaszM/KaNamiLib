class_name BaseSceneManager

#region Signals
signal base_scene_changed
signal base_scene_removed
#endregion

#region Private Variables
var _container: Node
var _records: Dictionary[String, String]
var _current_scene: BaseScene
var _is_busy: bool
#endregion

#region Virtual Methods
func _init(base_scene_container: Node) -> void:
	_container = base_scene_container


func _to_string() -> String:
	return "<BaseSceneManager[%s]>" % ("None" if _current_scene == null else _current_scene.get_id())
#endregion

#region Public Methods
func register_base_scene(id: Variant, path: String) -> void:
	var id_str: String = str(id).strip_edges()
	
	if id_str.is_empty():
		Log.error("The ID cannot be empty!", register_base_scene)
		return
	
	path = path.strip_edges()
	
	if path.is_empty():
		Log.error("The path cannot be empty!", register_base_scene)
		return
	
	if id_str in _records:
		Log.warning("A record with ID: '%s', is already registered." % id_str, register_base_scene)
		
		return
	
	_records[id_str] = path


func change_base_scene(id: Variant) -> void:
	if _is_busy:
		Log.warning("Still processing the previous request...", change_base_scene)
		
		return
	
	if _container == null:
		Log.error("No base scene container node reference was provided!", change_base_scene)
		return
	
	var id_str: String = str(id).strip_edges()
	var id_is_empty: bool = id_str.is_empty()
	
	if not id_is_empty and not id_str in _records:
		Log.error("ID: '%s' is not registered!" % id_str)
		return
	
	_is_busy = true
	
	Log.info("Changing to base scene with ID: '%s'..." % id_str, change_base_scene)
	
	if _current_scene == null:
		_add_new_base_scene_on_change_request(id_str)
	
	else:
		if _current_scene.get_id() == id_str:
			Log.warning("The requested base scene is already set.", change_base_scene)
			_is_busy = false
			return
		
		_remove_previous_base_scene_on_change_request(id_str)


func get_current() -> BaseScene:
	if _is_busy:
		Log.warning("Still processing the previous request...", get_current)
		return null
	
	if _current_scene == null:
		Log.error("The current base scene reference if null!", get_current)
		return null
	
	return _current_scene


func remove_current() -> void:
	_remove_previous_base_scene_on_change_request(null)
#endregion

#region Private Methods
func _remove_previous_base_scene_on_change_request(id: Variant) -> void:
	if _current_scene == null:
		if id != null:
			Log.error("The current base scene reference if null!", _remove_previous_base_scene_on_change_request)
		
		_is_busy = false
		return
	
	var id_str: String = str(id).strip_edges()
	var func_on_teardown_completed: Callable = func() -> void:
		_current_scene.queue_free()
	
	var func_on_tree_exited: Callable = func() -> void:
		_current_scene = null
		
		Log.success(
			"The previous base scene was removed successfully", _remove_previous_base_scene_on_change_request
			)
		base_scene_removed.emit()
		
		if id == null:
			_is_busy = false
			return
		
		_add_new_base_scene_on_change_request(id_str)
	
	_current_scene.teardown_completed.connect(func_on_teardown_completed)
	_current_scene.tree_exited.connect(func_on_tree_exited)
	_current_scene.teardown()


func _add_new_base_scene_on_change_request(id: Variant) -> void:
	var id_str: String = str(id).strip_edges()
	
	if id_str.is_empty():
		_is_busy = false
		return
	
	var base_scene_pack := load(_records[id_str]) as PackedScene
	
	if base_scene_pack == null or not base_scene_pack.can_instantiate():
		Log.error("The requested base scene pack, cannot be instantiated!", _add_new_base_scene_on_change_request)
		_is_busy = false
		return
	
	var func_on_ready: Callable = func() -> void:
		Log.success("The requested base scene was changed successfully", _add_new_base_scene_on_change_request)
		
		_is_busy = false
		base_scene_changed.emit()
	
	_current_scene = base_scene_pack.instantiate() as BaseScene
	_current_scene.ready.connect(func_on_ready)
	_current_scene.set_id(id_str)
	_container.add_child(_current_scene)
#endregion
