class_name TreeOrganizerSorter extends TreeOrganizerElement

#region Enums
enum Type {ASC, DESC}
enum Mode {TEXT, NUMERIC}
#endregion

#region Public Variables
var type: Type = Type.ASC
var mode: Mode = Mode.TEXT
#endregion

#region Constructor
func _init(column_index: int) -> void:
	col_idx = column_index
#endregion

#region Public Methods
func is_asc() -> bool:
	return type == Type.ASC


func asc_text() -> TreeOrganizerSorter:
	type = Type.ASC
	mode = Mode.TEXT
	
	return self


func desc_text() -> TreeOrganizerSorter:
	type = Type.DESC
	mode = Mode.TEXT
	
	return self


func asc_numeric() -> TreeOrganizerSorter:
	type = Type.ASC
	mode = Mode.NUMERIC
	
	return self


func desc_numeric() -> TreeOrganizerSorter:
	type = Type.DESC
	mode = Mode.NUMERIC
	
	return self


func reverse_type() -> TreeOrganizerSorter:
	type = Type.DESC if type == Type.ASC else Type.ASC
	
	return self
#endregion
