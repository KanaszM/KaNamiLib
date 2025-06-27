class_name ExpectedVector2
extends ExpectedVariant

#region Private Variables
var _value: Vector2
#endregion

#region Virtual Methods
func _init(value_arg: Vector2) -> void:
	_type = TYPE_VECTOR2
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> Vector2:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedVector2:
	return super.is_error(message, callback) as ExpectedVector2


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedVector2:
	return super.is_warning(message, callback) as ExpectedVector2


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedVector2:
	return super.is_fatal(message, callback) as ExpectedVector2


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedVector2:
	return super.is_valid(message, callback) as ExpectedVector2
#endregion
