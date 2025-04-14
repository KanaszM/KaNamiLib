@tool
class_name ExtendedPanelContainer
extends PanelContainer

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
func get_style() -> StyleBox:
	return get_theme_stylebox(&"panel")


func set_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"panel", style)


func remove_style() -> void:
	remove_theme_stylebox_override(&"panel")
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
