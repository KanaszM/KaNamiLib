#@tool
class_name VariantResult
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var error_code: Error = ERR_UNCONFIGURED
var error_message: String = "This class serves as a base and should not be used on its own!"
var is_ok: bool: get = _get_is_ok
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _to_string() -> String:
	return "<VariantResult[%s][%s]>" % [is_ok, get(&"value")]
#endregion

#region Public Methods
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
func _get_is_ok() -> bool:
	return error_code == OK
#endregion
