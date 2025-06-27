class_name ExpectedStringName extends ExpectedVariant

#region Private Variables
var _value: StringName
#endregion

#region Virtual Methods
func _init(value_arg: StringName) -> void:
	_type = TYPE_STRING_NAME
	_value = value_arg
#endregion

#region Public Methods
func get_value() -> StringName:
	return _value


func is_error(message: String, callback: Callable = Callable()) -> ExpectedStringName:
	return super.is_error(message, callback) as ExpectedStringName


func is_warning(message: String, callback: Callable = Callable()) -> ExpectedStringName:
	return super.is_warning(message, callback) as ExpectedStringName


func is_fatal(message: String, callback: Callable = Callable()) -> ExpectedStringName:
	return super.is_fatal(message, callback) as ExpectedStringName


func is_valid(message: String, callback: Callable = Callable()) -> ExpectedStringName:
	return super.is_valid(message, callback) as ExpectedStringName
#endregion
