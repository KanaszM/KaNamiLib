class_name ExpectedString
extends ExpectedVariant

#region Private Variables
var _value: String
#endregion

#region Virtual Methods
func _init(value_arg: String) -> void:
	_type = TYPE_STRING
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> String:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedString:
	return super.is_error(message, callback) as ExpectedString


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedString:
	return super.is_warning(message, callback) as ExpectedString


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedString:
	return super.is_fatal(message, callback) as ExpectedString
#endregion
