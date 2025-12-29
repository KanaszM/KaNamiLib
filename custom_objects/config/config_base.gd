class_name ConfigBase

#region Signals
@warning_ignore("unused_signal") signal saved
@warning_ignore("unused_signal") signal loaded
@warning_ignore("unused_signal") signal updated
#endregion

#region Private Methods
func _to_string() -> String:
	return "<Config>"
#endregion
