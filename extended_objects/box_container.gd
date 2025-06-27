@tool
class_name ExtendedBoxContainer extends BoxContainer

#region Theme Methods
func set_separation(value: int) -> void:
	add_theme_constant_override(&"separation", value)


func get_separation() -> int:
	return get_theme_constant(&"separation")
#endregion
