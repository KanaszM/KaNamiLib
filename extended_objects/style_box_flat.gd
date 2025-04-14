@tool
class_name ExtendedStyleBoxFlat
extends StyleBoxFlat

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var invert_colors: bool: set = _set_invert_colors

@export var bg_color_type: Shade.Type = Shade.Type.GRAY: set = _set_bg_color_type
@export_range(0, 9, 1) var bg_color_idx: int: set = _set_bg_color_idx

@export var border_color_type: Shade.Type = Shade.Type.GRAY: set = _set_border_color_type
@export_range(0, 9, 1) var border_color_idx: int: set = _set_border_color_idx
#endregion

#region Public Variables
#endregion

#region Private Variables
var _block_updates: bool = true
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init() -> void:
	_set_bg_color_type(bg_color_type)
	_set_bg_color_idx(bg_color_idx)
	_set_border_color_type(border_color_type)
	_set_border_color_idx(border_color_idx)
	
	_block_updates = false
	update()
#endregion

#region Public Methods
func update() -> void:
	if _block_updates:
		return
	
	if invert_colors:
		bg_color = Shade.get_opposite_color(bg_color_type, bg_color_idx)
		border_color = Shade.get_opposite_color(border_color_type, border_color_idx)
	
	else:
		bg_color = Shade.get_color(bg_color_type, bg_color_idx)
		border_color = Shade.get_color(border_color_type, border_color_idx)
#endregion

#region Private Methods
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_invert_colors(arg: bool) -> void:
	invert_colors = arg
	changed.emit()
	update()


func _set_bg_color_type(arg: Shade.Type) -> void:
	bg_color_type = arg
	changed.emit()
	update()


func _set_bg_color_idx(arg: int) -> void:
	bg_color_idx = arg
	changed.emit()
	update()


func _set_border_color_type(arg: Shade.Type) -> void:
	border_color_type = arg
	changed.emit()
	update()


func _set_border_color_idx(arg: int) -> void:
	border_color_idx = arg
	changed.emit()
	update()
#endregion

#region Getter Methods
#endregion
