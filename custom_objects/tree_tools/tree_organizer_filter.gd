class_name TreeOrganizerFilter extends TreeOrganizerElement

#region Enums
enum Type {TEXT, NUMERIC, BOOL, LENGTH, LIST}
#endregion

#region Public Variables
var type: Type = Type.TEXT
var negative: bool
#endregion

#region Constructor
func _init(filter_type: Type, column_index: int) -> void:
	type = filter_type
	col_idx = column_index
#endregion

#region Public Methods
func set_negative(state: bool = true) -> TreeOrganizerFilter:
	negative = state
	
	return self
#endregion

#region Private Methods
func _to_string_formatter(sub_class_name: String, mode: String, criteria: Variant) -> String:
	return "%s[%d] %s%s '%s'>" % [sub_class_name, col_idx, "not " if negative else "", mode, criteria]
#endregion
