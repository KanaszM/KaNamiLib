@tool
class_name ExtendedHFlowContainer extends HFlowContainer

#region Theme Methods
func set_separation(value: int) -> void:
	set_horizontal_separation(value)
	set_vertical_separation(value)


func set_vseparation(value: Vector2i) -> void:
	set_horizontal_separation(value.x)
	set_vertical_separation(value.y)


func set_horizontal_separation(value: int) -> void:
	add_theme_constant_override(&"h_separation", value)


func set_vertical_separation(value: int) -> void:
	add_theme_constant_override(&"v_separation", value)


func get_separation() -> Vector2i:
	return Vector2i(get_horizontal_separation(), get_vertical_separation())


func get_horizontal_separation() -> int:
	return get_theme_constant(&"h_separation")


func get_vertical_separation() -> int:
	return get_theme_constant(&"v_separation")
#endregion
