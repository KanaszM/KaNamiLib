class_name DebugTools extends Node

#region Public Variables
var instance_index: int = -1
var instance_socket: TCPServer 
#endregion

#region Private Variables
var _input_key_maps: Dictionary[Key, InputKeyMap]
#endregion

#region Virtual Methods
func _init() -> void:
	set_process_input(false)
	set_process_internal(false)
	set_physics_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		
		if key_event.pressed:
			if not key_event.keycode in _input_key_maps:
				return
			
			var input_key_map: InputKeyMap = _input_key_maps[key_event.keycode]
			
			input_key_map.execute()
#endregion

#region Public Methods
func bind_input_key(key: Key, callback: Callable, mode: bool = true, deferred: bool = false) -> void:
	if key == KEY_NONE or not callback.is_valid():
		return
	
	if mode:
		if key not in _input_key_maps:
			_input_key_maps[key] = InputKeyMap.new()
		
		_input_key_maps[key].add(callback, deferred)
	
	else:
		if key in _input_key_maps:
			_input_key_maps[key].remove(callback)
			
			if _input_key_maps[key].is_empty():
				_input_key_maps.erase(key)
	
	set_process_input(not _input_key_maps.is_empty())


func detect_instance_index() -> void:
	instance_socket = TCPServer.new()
	
	for index: int in 20:
		if instance_socket.listen(5000 + index) == OK:
			instance_index = index
			break


func update_instance_window_rect(window: Window, max_instances_count: int, title_bar_height: int = 30) -> void:
	if instance_index < 0:
		return
	
	var screen_rect: Rect2 = Rect2(DisplayServer.screen_get_usable_rect())
	
	var cols: int = ceili(sqrt(max_instances_count))
	var rows: int = ceili(float(max_instances_count) / cols)
	
	var width: float = screen_rect.size.x / cols
	var height: float = screen_rect.size.y / rows
	var origin: Vector2 = screen_rect.position + Vector2(
		(int(float(instance_index) / cols)) * width,
		(instance_index % cols) * height
		)
	
	window.size = Vector2(width, height - title_bar_height)
	window.position = origin + Vector2.DOWN * title_bar_height
#endregion

#region Static Methods
static func attach(origin: Node) -> DebugTools:
	var debug_tools: DebugTools = DebugTools.new()
	
	origin.add_child(debug_tools, false, Node.INTERNAL_MODE_BACK)
	
	return debug_tools


static func print_array(array: Array, indexed: bool = true) -> void:
	var max_index_length: int = str(array.size()).length()
	
	for entry_idx: int in array.size():
		var entry: Variant = array[entry_idx]
		
		print("%s%s" % [("[%s] " % str(entry_idx + 1).lpad(max_index_length)) if indexed else "", entry])
#endregion

#region SubClasses
class InputKeyMap:
	#region Private Variables
	var _map: Dictionary[Callable, bool]
	#endregion
	
	#region Public Methods
	func add(callback: Callable, deferred: bool) -> void:
		_map[callback] = deferred
	
	
	func remove(callback: Callable) -> void:
		_map.erase(callback)
	
	
	func is_empty() -> bool:
		return _map.is_empty()
	
	
	func execute() -> void:
		for callback: Callable in _map:
			if _map[callback]:
				callback.call_deferred()
			
			else:
				callback.call()
	#endregion
#endregion
