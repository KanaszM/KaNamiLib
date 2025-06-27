class_name TreeOrganizerElement

#region Public Variables
var col_idx: int = -1: set = set_col_idx
#endregion

#region Setter Methods
func set_col_idx(arg: int = col_idx) -> TreeOrganizerElement:
	if arg < 0:
		arg = 0
	
	col_idx = arg
	
	return self
#endregion
