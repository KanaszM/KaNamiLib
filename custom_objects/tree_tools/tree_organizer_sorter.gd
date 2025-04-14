#@tool
class_name TreeOrganizerSorter
extends TreeOrganizerElement

#region Signals
#endregion

#region Enums
enum Type {ASC, DESC}
enum Mode {TEXT, NUMERIC}
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var type: Type = Type.ASC
var mode: Mode = Mode.TEXT
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
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

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
