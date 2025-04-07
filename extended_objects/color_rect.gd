"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

@tool
class_name ExtendedColorRect
extends ColorRect

#region Signals
#endregion

#region Enums
#endregion

#region Constants
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
func set_random_shade_color(shade_color_index: int = 6, color_alpha: float = 1.0) -> void:
	color = Shade.get_random_color_by_idx(shade_color_index)
	color.a = color_alpha
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
