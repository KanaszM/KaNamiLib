class_name Result

#region Enums
enum Type {UNDEFINED, INFO, WARNING, ERROR, SUCCESS}
#endregion

#region Signals
signal changed(result: Result)
#endregion

#region Private Variables
var _type: Type = Type.UNDEFINED
var _message: String
var _callback: Callable = Callable()
#endregion

#region Public Methods
func get_type() -> Type:
	return _type


func get_message() -> String:
	return _message.strip_edges()


func get_callback() -> Callable:
	return _callback


func is_ok() -> bool:
	return _type in [Type.INFO, Type.SUCCESS]


func is_issue() -> bool:
	return _type in [Type.WARNING, Type.ERROR]


func clear() -> Result:
	_type = Type.UNDEFINED
	_message = ""
	_callback = Callable()
	
	changed.emit(self)
	
	return self


func set_as(type: Type, message: String, callback: Callable = Callable()) -> Result:
	_type = type
	_message = message
	_callback = callback
	
	changed.emit(self)
	
	return self


func info(message: String = "", callback: Callable = Callable()) -> Result:
	return set_as(Type.INFO, message, callback)


func warning(message: String = "", callback: Callable = Callable()) -> Result:
	return set_as(Type.WARNING, message, callback)


func error(message: String = "", callback: Callable = Callable()) -> Result:
	return set_as(Type.ERROR, message, callback)


func success(message: String = "", callback: Callable = Callable()) -> Result:
	return set_as(Type.SUCCESS, message, callback)
#endregion
