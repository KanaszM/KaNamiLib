class_name TreeOrganizerTextFilter
extends TreeOrganizerFilter

#region Enums
enum Mode {EQUALS, CONTAINS, BEGINS_WITH, ENDS_WITH}
#endregion

#region Public Variables
var mode: Mode = Mode.EQUALS
var criteria: String
var case_sensitive: bool
#endregion

#region Virtual Methods
func _init(column_index: int) -> void:
	super._init(Type.TEXT, column_index)


func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerTextFilter", UtilsDictionary.enum_to_str(Mode, mode, true), criteria)
#endregion

#region Public Methods
func update(
	new_mode: Mode, criteria_value: String, is_negative: bool, is_case_sensitive: bool
	) -> TreeOrganizerTextFilter:
		mode = new_mode
		criteria = criteria_value
		negative = is_negative
		case_sensitive = is_case_sensitive
		
		if not is_case_sensitive:
			criteria = criteria.to_lower()
		
		return self


func equals(
	criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
	) -> TreeOrganizerTextFilter:
		return update(Mode.EQUALS, criteria_value, is_negative, is_case_sensitive)


func contains(
	criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
	) -> TreeOrganizerTextFilter:
		return update(Mode.CONTAINS, criteria_value, is_negative, is_case_sensitive)


func begins_with(
	criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
	) -> TreeOrganizerTextFilter:
		return update(Mode.BEGINS_WITH, criteria_value, is_negative, is_case_sensitive)


func ends_with(
	criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
	) -> TreeOrganizerTextFilter:
		return update(Mode.ENDS_WITH, criteria_value, is_negative, is_case_sensitive)


func set_case_sensitive(state: bool = true) -> TreeOrganizerTextFilter:
	case_sensitive = state
	return self
#endregion
