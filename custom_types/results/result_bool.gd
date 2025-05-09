#@tool
class_name ResultBool
extends ResultVariant

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var value: bool
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
func set_value(
	value_arg: bool, success_message_arg: String = "", logger_callback: Callable = Callable(),
	) -> ResultBool:
		value = value_arg
		
		if not success_message_arg.is_empty() and logger_callback.is_valid():
			Logger.success(logger_callback, success_message_arg)
		
		return self


func set_error(
	error_code_arg: Error, error_message_arg: String = "", logger_callback: Callable = Callable(),
	) -> ResultBool:
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
