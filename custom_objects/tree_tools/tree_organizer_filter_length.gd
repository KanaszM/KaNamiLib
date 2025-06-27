class_name TreeOrganizerLengthFilter
extends TreeOrganizerFilter

#region Public Variables
var criteria: int
#endregion

#region Virtual Methods
func _init(column_index: int) -> void:
	super._init(Type.LENGTH, column_index)


func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerLengthFilter", "=", criteria)
#endregion

#region Public Methods
func update(criteria_value: int, is_negative: bool) -> TreeOrganizerLengthFilter:
	criteria = criteria_value
	negative = is_negative
	
	return self


func equals(criteria_value: int, is_negative: bool = false) -> TreeOrganizerLengthFilter:
	return update(criteria_value, is_negative)
#endregion
