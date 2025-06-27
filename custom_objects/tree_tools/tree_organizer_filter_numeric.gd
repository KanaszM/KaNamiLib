class_name TreeOrganizerNumericFilter extends TreeOrganizerFilter

#region Enums
enum Mode {EQUALS, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO, LOWER_THAN, LOWER_THAN_OR_EQUAL_TO}
#endregion

#region Public Variables
var mode: Mode = Mode.EQUALS
var criteria: float
#endregion

#region Virtual Methods
func _init(column_index: int) -> void:
	super._init(Type.NUMERIC, column_index)


func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerNumericFilter", UtilsDictionary.enum_to_str(Mode, mode, true), criteria)
#endregion

#region Public Methods
func update(new_mode: Mode, criteria_value: float, is_negative: bool) -> TreeOrganizerNumericFilter:
	mode = new_mode
	criteria = criteria_value
	negative = is_negative
	
	return self


func equals(criteria_value: float, is_negative: bool = false) -> TreeOrganizerNumericFilter:
	return update(Mode.EQUALS, criteria_value, is_negative)


func greater_than(criteria_value: float, is_negative: bool = false) -> TreeOrganizerNumericFilter:
	return update(Mode.GREATER_THAN, criteria_value, is_negative)


func greater_than_or_equals_to(criteria_value: float, is_negative: bool = false) -> TreeOrganizerNumericFilter:
	return update(Mode.GREATER_THAN_OR_EQUAL_TO, criteria_value, is_negative)


func lower_than(criteria_value: float, is_negative: bool = false) -> TreeOrganizerNumericFilter:
	return update(Mode.LOWER_THAN, criteria_value, is_negative)


func lower_than_or_equals_to(criteria_value: float, is_negative: bool = false) -> TreeOrganizerNumericFilter:
	return update(Mode.LOWER_THAN_OR_EQUAL_TO, criteria_value, is_negative)
#endregion
