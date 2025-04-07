"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

@tool
class_name ExtendedSplitContainer
extends SplitContainer

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
func set_offset_at_half(reversed: bool = true) -> void:
	var parent: Node = get_parent()
	var total_size: Vector2 = Vector2.ZERO
	
	if parent is Control:
		total_size = (parent as Control).size
	
	else:
		total_size = get_viewport_rect().size
	
	if total_size > Vector2.ZERO:
		var half_total_height: float = total_size.y / 2.0
		
		split_offset = int((-half_total_height) if reversed else half_total_height)


func get_dragger() -> Control:
	for child: Node in get_children(true):
		if child.get_class() == "SplitContainerDragger":
			return child as Control
	
	return null
#endregion

#region Theme Methods
func get_style() -> StyleBox:
	return get_theme_stylebox(&"split_bar_background")


func set_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"split_bar_background", style)
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
