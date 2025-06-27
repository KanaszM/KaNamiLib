@tool
class_name ExtendedPanelContainer
extends PanelContainer

#region Theme Methods
func get_style() -> StyleBox:
	return get_theme_stylebox(&"panel")


func set_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"panel", style)


func set_empty_style() -> void:
	add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())


func remove_style() -> void:
	remove_theme_stylebox_override(&"panel")
#endregion
