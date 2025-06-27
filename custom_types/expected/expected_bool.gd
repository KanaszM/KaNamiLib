class_name ExpectedBool extends ExpectedVariant

#region Private Variables
var _value: bool
#endregion

#region Virtual Methods
func _init(value_arg: bool) -> void:
	_type = TYPE_BOOL
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> bool:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedBool:
	return super.is_error(message, callback) as ExpectedBool


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedBool:
	return super.is_warning(message, callback) as ExpectedBool


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedBool:
	return super.is_fatal(message, callback) as ExpectedBool


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedBool:
	return super.is_valid(message, callback) as ExpectedBool
#endregion
