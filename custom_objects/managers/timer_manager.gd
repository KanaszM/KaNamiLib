class_name TimerManager

#region Private Static Variables
static var _cache: Dictionary[Callable, Timer]
#endregion

#region Public Static Methods
static func start(callback: Callable, wait_time: float = 1.0, options: Options = null) -> void:
	if options == null:
		options = Options.new()
	
	if callback in _cache:
		_cache[callback].timer.start(wait_time)
		return
	
	var callback_data: UtilsCallback.CallbackData = UtilsCallback.get_callback_data(callback)
	
	if callback_data == null:
		return
	
	var timer_name: StringName = &"%s%s" % [options.name_prefix, callback_data.method]
	var timer_path: NodePath = NodePath(timer_name)
	var timer := callback_data.origin.get_node_or_null(timer_path) as Timer
	
	if timer == null:
		var internal_mode: Node.InternalMode = (
			Node.INTERNAL_MODE_BACK if options.add_as_internal_node else Node.INTERNAL_MODE_DISABLED
			)
		
		timer = Timer.new()
		timer.name = timer_name
		timer.one_shot = options.one_shot
		timer.timeout.connect(callback)
		
		callback_data.origin.add_child(timer, false, internal_mode)
		_cache[callback] = timer
	
	timer.start(wait_time)


static func remove(callback: Callable) -> void:
	if callback in _cache:
		_cache[callback].queue_free()
		_cache.erase(callback)
#endregion

#region SubClasses
class Options:
	#region Public Variables
	var name_prefix: StringName = &"Timer"
	var one_shot: bool = true
	var add_as_internal_node: bool = true
	#endregion
#endregion
