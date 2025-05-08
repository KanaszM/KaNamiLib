#@tool
class_name Vector2iResult
extends VariantResult

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var value: Vector2i
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
func set_value(value_arg: Vector2i, logger_callback: Callable = Callable()) -> Vector2iResult:
	value = value_arg
	
	if logger_callback.is_valid():
		Logger.success(logger_callback, value)
	
	return self


func set_error(
	error_code_arg: Error, error_message_arg: String = "", logger_callback: Callable = Callable(),
	) -> Vector2iResult:
		error_code = error_code_arg
		error_message = error_message_arg
		
		if error_code != OK and not error_message.is_empty() and logger_callback.is_valid():
			Logger.error(logger_callback, "%s :: %s" % [error_string(error_code), error_message])
		
		return self
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
