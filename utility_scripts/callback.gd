class_name UtilsCallback


static func call_safe(callback: Callable, deferred: bool = false) -> void:
	if callback.is_valid():
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
		
		return ("%s%s%s" % [object_str, separator, callback.get_method()])
