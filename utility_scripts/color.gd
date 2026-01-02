class_name UtilsColor


static func get_color_with_transparency(color: Color, transparency: float) -> Color:
	color.a = clampf(transparency, 0.0, 1.0)
	
	return color
