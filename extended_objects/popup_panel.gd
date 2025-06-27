@tool
class_name ExtendedPopupPanel
extends PopupPanel

#region Export Variables
@export var one_shot: bool: set = _set_one_shot
#endregion

#region Public Methods
func popup_at_mouse_position(position_offset: Vector2 = Vector2.ZERO, popup_size: Vector2 = Vector2.ONE) -> void:
	popup(Rect2(get_window().get_mouse_position() + position_offset, popup_size))
#endregion

#region Setter Methods
func _set_one_shot(arg: bool) -> void:
	one_shot = arg
	
	UtilsSignal.connect_safe_if(popup_hide, queue_free, one_shot)
#endregion
