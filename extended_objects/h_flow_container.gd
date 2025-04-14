@tool
class_name ExtendedHFlowContainer
extends HFlowContainer

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
#endregion

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
