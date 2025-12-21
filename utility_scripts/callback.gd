class_name UtilsCallback


static func is_valid(callback: Callable) -> bool:
	return callback != null and not callback.is_null() and callback.is_valid()


static func call_safe(callback: Callable, deferred: bool = false) -> void:
	if is_valid(callback):
		if deferred:
			callback.call_deferred()
		
		else:
			callback.call()


static func call_safe_timed(interval: float, callback: Callable, deferred: bool = false) -> void:
	if interval > 0.0:
		await UtilsEngine.get_tree().create_timer(interval).timeout
	
	call_safe(callback, deferred)


static func to_str(
	callback: Callable, if_null: String = "null", separator: String = ".", object_in_brackets: bool = true
	) -> String:
		if not callback.is_valid():
			return if_null
		
		var object_str: String = "%s%s%s" % [
			"[" if object_in_brackets else "",
			callback.get_object().get(&"name"),
			"]" if object_in_brackets else "",
			]
		
		return "%s%s%s" % [object_str, separator, callback.get_method()]


static func get_callback_data(callback: Callable) -> CallbackData:
	if not callback.is_valid():
		Log.error("The provided callable is not valid!", get_callback_data)
		return null
	
	var object: Object = callback.get_object()
	
	if object == null:
		Log.error("The callable object could not be identified!", get_callback_data)
		return null
	
	if not object is Node:
		Log.error("The callable object must be a Node!", get_callback_data)
		return null
	
	var origin := object as Node
	var method: StringName = callback.get_method()
	
	if method.is_empty() or method == &"<anonymous lambda>":
		Log.error("Invalid method name: '%s' on callable: '%s'!" % [method, callback], get_callback_data)
		return null
	
	var callback_data: CallbackData = CallbackData.new()
	
	callback_data.origin = origin
	callback_data.method = method
	
	return callback_data


class CallbackData:
	var origin: Node
	var method: StringName
