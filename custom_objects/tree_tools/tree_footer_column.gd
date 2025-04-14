#@tool
class_name TreeFooterFooterColumn
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var idx: int = -1
var is_numeric: bool
var alignment: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(
	idx_value: int,
	is_numeric_state: bool = false,
	alignment_value: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	) -> void:
		if idx_value < 0:
			Logger.error(_init, "The index value cannot be lower than 0!")
			return
		
		idx = idx_value
		is_numeric = is_numeric_state
		alignment = alignment_value
#endregion

#region Public Methods
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
