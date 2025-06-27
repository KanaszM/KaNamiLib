@tool
class_name ExtendedSplitContainer extends SplitContainer

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
