"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

@tool
class_name ExtendedPopupPanel
extends PopupPanel

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var one_shot: bool: set = _set_one_shot
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
func popup_at_mouse_position(position_offset: Vector2 = Vector2.ZERO, popup_size: Vector2 = Vector2.ONE) -> void:
	popup(Rect2(get_window().get_mouse_position() + position_offset, popup_size))
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
func _set_one_shot(arg: bool) -> void:
	one_shot = arg
	
	UtilsSignal.connect_safe_if(popup_hide, queue_free, one_shot)
#endregion

#region Getter Methods
#endregion
