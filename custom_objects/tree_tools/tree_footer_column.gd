class_name TreeFooterFooterColumn

#region Public Variables
var idx: int = -1
var is_numeric: bool
var alignment: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
#endregion

#region Constructor
func _init(
	idx_value: int,
	is_numeric_state: bool = false,
	alignment_value: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	) -> void:
		idx_value = maxi(0, idx_value)
		
		idx = idx_value
		is_numeric = is_numeric_state
		alignment = alignment_value
#endregion
