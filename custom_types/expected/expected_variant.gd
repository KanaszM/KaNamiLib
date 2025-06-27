abstract class_name ExpectedVariant

#region Private Variables
var _type: Variant.Type = TYPE_NIL
var _is_ok: bool = true
var _message: String
#endregion

#region Public Methods
func is_ok() -> bool:
	return _is_ok
#endregion

#region Abstract Methods
func get_value() -> Variant:
	return null


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedVariant:
	_message = message
	
	if not message.is_empty() and callback.is_valid():
		if Engine.is_editor_hint():
			push_warning("%s %s" % [UtilsCallback.to_str(callback), message])
			return self
		
		Log.warning(callback, message)
	
	return self


func is_error(message: String, callback: Callable = Callable()) -> ExpectedVariant:
	_is_ok = false
	_message = message
	
	if not message.is_empty() and callback.is_valid():
		if Engine.is_editor_hint():
			push_error("%s %s" % [UtilsCallback.to_str(callback), message])
			return self
		
		Log.error(callback, message)
	
	return self


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedVariant:
	_is_ok = false
	_message = message
	
	if not message.is_empty() and callback.is_valid():
		if Engine.is_editor_hint():
			push_error("%s %s" % [UtilsCallback.to_str(callback), message])
			return self
		
		Log.fatal(callback, message)
		UtilsEngine.get_tree().quit.call_deferred()
	
	return self


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedVariant:
	_is_ok = true
	_message = message
	
	if not message.is_empty() and callback.is_valid():
		if Engine.is_editor_hint():
			print("%s %s" % [UtilsCallback.to_str(callback), message])
			return self
		
		Log.success(callback, message)
	
	return self
#endregion

#region Private Methods
func _to_string() -> String:
	return "<Expected%s[%s]%s>" % [
		type_string(_type).capitalize(),
		get_value(),
		"" if _message.is_empty() else ("[%s]" % _message)
		]
#endregion
