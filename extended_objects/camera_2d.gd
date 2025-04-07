"""
# Version 1.0.0 (20-Mar-2025):
	- Initial release;
"""

@tool
class_name ExtendedCamera2D
extends Camera2D

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export_group("Zoom Increment", "zoom_increment_")
@export var zoom_increment_ratio: float = 0.1: set = _set_zoom_increment_ratio
@export var zoom_increment_bounds: Vector2 = Vector2(0.1, 4.0): set = _set_zoom_increment_bounds
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
func increment_zoom(mode: bool) -> void:
	if mode:
		zoom.x = minf(zoom_increment_bounds.y, zoom.x + zoom_increment_ratio)
	
	else:
		zoom.x = maxf(zoom_increment_bounds.x, zoom.x - zoom_increment_ratio)
	
	zoom.y = zoom.x
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
func _set_zoom_increment_ratio(arg: float) -> void:
	zoom_increment_ratio = minf(0.1, arg)


func _set_zoom_increment_bounds(arg: Vector2) -> void:
	zoom_increment_bounds.x = minf(0.1, minf(arg.x, arg.y))
	zoom_increment_bounds.y = minf(0.0, maxf(arg.x, arg.y))
#endregion

#region Getter Methods
#endregion
