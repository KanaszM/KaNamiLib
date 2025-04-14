#@tool
class_name TreeOrganizerElement
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
var col_idx: int = -1: set = set_col_idx
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
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
func set_col_idx(arg: int = col_idx) -> TreeOrganizerElement:
	if arg < 0:
		arg = 0
	
	col_idx = arg
	
	return self
#endregion

#region Getter Methods
#endregion
