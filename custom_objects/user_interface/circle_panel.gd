@tool
class_name CirclePanel extends Control

#region Enums
enum Alignment {LEFT, CENTER, RIGHT}
#endregion

#region Constants
const DEFAULT_CORNER_DETAIL_BOUNDS: Vector2i = Vector2i(5, 12)
const DEFAULT_CORNER_DETAIL_THRESHOLD: int = 30
#endregion

#region Export Variables
@export var alignment: Alignment = Alignment.CENTER: set = _set_alignment
@export var style: StyleBoxFlat: set = _set_style
@export var corner_detail_override: int: set = _set_corner_detail_override
@export var corner_radius_offset: int = 2
#endregion

#region Private Variables
var _panel: Panel
var _style: StyleBoxFlat
var _aspect: AspectRatioContainer

var _updates_enabled: bool
#endregion

#region Virtual Methods
func _ready() -> void:
	_panel = Panel.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	_aspect = AspectRatioContainer.new()
	_aspect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	add_child(_aspect, false, Node.INTERNAL_MODE_BACK)
	_aspect.add_child(_panel, false, Node.INTERNAL_MODE_BACK)
	
	_set_alignment(alignment)
	_set_style(style)
	
	_updates_enabled = true
	_update()
	
	resized.connect(_update)
#endregion

#region Private Methods
func _update() -> void:
	if not _updates_enabled:
		return
	
	match alignment:
		Alignment.LEFT: _aspect.alignment_horizontal = AspectRatioContainer.ALIGNMENT_BEGIN
		Alignment.CENTER: _aspect.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
		Alignment.RIGHT: _aspect.alignment_horizontal = AspectRatioContainer.ALIGNMENT_END
	
	var corner_radius: int = int(size.x / 2.0) - corner_radius_offset
	var corner_detail_default: int = _get_default_corner_detail(corner_radius)
	
	_style.corner_detail = corner_detail_default if corner_detail_override == 0 else corner_detail_override
	_style.set_corner_radius_all(corner_radius)
	_panel.add_theme_stylebox_override(&"panel", _style)


func _get_default_corner_detail(corner_radius: int) -> int:
	return (
		DEFAULT_CORNER_DETAIL_BOUNDS.x
		if corner_radius < DEFAULT_CORNER_DETAIL_THRESHOLD
		else DEFAULT_CORNER_DETAIL_BOUNDS.y
		)
#endregion

#region Setter Methods
func _set_alignment(arg: Alignment) -> void:
	alignment = arg
	_update()


func _set_style(arg: StyleBoxFlat) -> void:
	style = arg
	_style = StyleBoxFlat.new() if style == null else style
	_update()


func _set_corner_detail_override(arg: int) -> void:
	corner_detail_override = maxi(0, arg)
	_update()
#endregion
