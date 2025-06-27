class_name ResultVariant

#region Public Variables
var error_code: Error = ERR_UNCONFIGURED
var error_message: String = "This class serves as a base and should not be used on its own!"
var is_ok: bool: get = _get_is_ok
#endregion

#region Virtual Methods
func _to_string() -> String:
	return "<ResultVariant[%s][%s]>" % [is_ok, get(&"value")]
#endregion

#region Getter Methods
func _get_is_ok() -> bool:
	return error_code == OK
#endregion
