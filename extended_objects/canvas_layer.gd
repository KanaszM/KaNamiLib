"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

@tool
class_name ExtendedCanvasLayer
extends CanvasLayer

#region Signals
#endregion

#region Enums
#endregion

#region Constants
const MAX_LAYER: int = 128
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
func set_clamped_layer(new_layer_value: int, min_limit: int = 1) -> void:
	layer = clamp_layer(new_layer_value, min_limit)


func set_layer_at_max(negative_offset: int = 0) -> void:
	layer = clamp_layer(MAX_LAYER - negative_offset)


func clamp_layer(new_layer_value: int, min_limit: int = 1) -> int:
	return clampi(new_layer_value, min_limit, MAX_LAYER)
#endregion

#region Private Methods
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
