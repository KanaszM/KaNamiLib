#@tool
class_name TreeOrganizerBoolFilter
extends TreeOrganizerFilter

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var criteria: bool
var text_true: String = "true": set = _set_text_true
var text_false: String = "false": set = _set_text_false
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(column_index: int) -> void:
	super._init(Type.BOOL, column_index)


func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerBoolFilter", "=", get_text())
#endregion

#region Public Methods
func update(criteria_value: bool) -> TreeOrganizerBoolFilter:
	criteria = criteria_value
	
	return self


func equals(criteria_value: bool) -> TreeOrganizerBoolFilter:
	return update(criteria_value)


func get_text() -> String:
	return text_true if criteria else text_false
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
func _set_text_true(arg: String) -> void:
	text_true = arg.strip_edges().strip_escapes()


func _set_text_false(arg: String) -> void:
	text_false = arg.strip_edges().strip_escapes()
#endregion

#region Getter Methods
#endregion
