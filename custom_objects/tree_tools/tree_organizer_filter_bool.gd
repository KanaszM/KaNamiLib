class_name TreeOrganizerBoolFilter extends TreeOrganizerFilter

#region Public Variables
var criteria: bool
var text_true: String = "true": set = _set_text_true
var text_false: String = "false": set = _set_text_false
#endregion

#region Constructor
func _init(column_index: int) -> void:
	super._init(Type.BOOL, column_index)
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
func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerBoolFilter", "=", get_text())
#endregion

#region Setter Methods
func _set_text_true(arg: String) -> void:
	text_true = arg.strip_edges().strip_escapes()


func _set_text_false(arg: String) -> void:
	text_false = arg.strip_edges().strip_escapes()
#endregion
