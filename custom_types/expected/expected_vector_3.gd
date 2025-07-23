class_name ExpectedVector3 extends ExpectedVariant

#region Private Variables
var _value: Vector3
#endregion

#region Constructor
func _init(value_arg: Vector3) -> void:
	_type = TYPE_VECTOR3
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> Vector3:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedVector3:
	return super.is_error(message, callback) as ExpectedVector3


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedVector3:
	return super.is_warning(message, callback) as ExpectedVector3


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedVector3:
	return super.is_fatal(message, callback) as ExpectedVector3


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedVector3:
	return super.is_valid(message, callback) as ExpectedVector3
#endregion
