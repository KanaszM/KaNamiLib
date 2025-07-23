class_name ExpectedInt extends ExpectedVariant

#region Private Variables
var _value: int
#endregion

#region Constructor
func _init(value_arg: int) -> void:
	_type = TYPE_INT
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> int:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedInt:
	return super.is_error(message, callback) as ExpectedInt


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedInt:
	return super.is_warning(message, callback) as ExpectedInt


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedInt:
	return super.is_fatal(message, callback) as ExpectedInt


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedInt:
	return super.is_valid(message, callback) as ExpectedInt
#endregion
