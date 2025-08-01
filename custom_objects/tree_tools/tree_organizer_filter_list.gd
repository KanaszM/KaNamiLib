class_name TreeOrganizerListFilter extends TreeOrganizerFilter

#region Public Variables
var criteria: Array
var case_sensitive: bool
#endregion

#region Constructor
func _init(column_index: int) -> void:
	super._init(Type.LENGTH, column_index)
#endregion

#region Public Methods
func update(criteria_value: Array, is_negative: bool, is_case_sensitive: bool) -> TreeOrganizerListFilter:
	criteria = criteria_value.map(
		func(entry: Variant) -> String: return str(entry) if is_case_sensitive else str(entry).to_lower()
		)
	
	negative = is_negative
	case_sensitive = is_case_sensitive
	
	return self


func is_one_of(
	criteria_value: Array, is_negative: bool = false, is_case_sensitive: bool = false
	) -> TreeOrganizerListFilter:
		return update(criteria_value, is_negative, is_case_sensitive)


func set_case_sensitive(state: bool = true) -> TreeOrganizerListFilter:
	case_sensitive = state
	
	return self
#endregion

#region Private Methods
func _to_string() -> String:
	return _to_string_formatter("TreeOrganizerListFilter", "=", criteria)
#endregion
