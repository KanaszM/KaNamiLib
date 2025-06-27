@tool
class_name ExtendedColorRect extends ColorRect

#region Public Methods
func set_random_shade_color(shade_color_index: int = 6, color_alpha: float = 1.0) -> void:
	color = Shade.get_random_color_by_idx(shade_color_index)
	color.a = color_alpha
#endregion
