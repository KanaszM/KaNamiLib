@tool
class_name ExtendedGridContainer
extends GridContainer

#region Constants
const AWAIT_INTERVALS: int = 2
#endregion

#region Export Variables
@export var squared: bool: set = _set_squared
@export var separation: Vector2i = Vector2i.ONE * 4: set = _set_separation
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

#region Signal Callbacks
func _on_child_order_changed() -> void:
	if not is_inside_tree():
		return
	
	var tree: SceneTree = get_tree()
	
	if tree == null:
		return
	
	for __: int in AWAIT_INTERVALS:
		await tree.process_frame
	
	columns = maxi(1, int(get_child_count() / 2.0))
#endregion

#region Setter Methods
func _set_squared(arg: bool) -> void:
	squared = arg
	UtilsSignal.connect_safe_if(child_order_changed, _on_child_order_changed, squared)


func _set_separation(arg: Vector2i) -> void:
	separation = arg
	set_vseparation(separation)
#endregion
