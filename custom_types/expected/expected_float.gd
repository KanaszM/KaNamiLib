class_name ExpectedFloat
extends ExpectedVariant

#region Private Variables
var _value: float
#endregion

#region Virtual Methods
func _init(value_arg: float) -> void:
	_type = TYPE_FLOAT
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> float:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedFloat:
	return super.is_error(message, callback) as ExpectedFloat


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedFloat:
	return super.is_warning(message, callback) as ExpectedFloat


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedFloat:
	return super.is_fatal(message, callback) as ExpectedFloat
#endregion
