@tool
class_name PropertyPanelOptions
extends Resource

#region Signals
#endregion

#region Enums
enum LabelDisplayMode {NONE, NAME, ADDRESS_LOWERED, ADDRESS_CAPITALIZED}
enum LabelPosition {LEFT, RIGHT, TOP, BOTTOM}
enum ContentsPosition {NONE, LEFT_OR_TOP, RIGHT_OR_BOTTOM, CENTER, FILLED}
#endregion

#region Constants
const DEFAULT_SPACING: int = 4
const DEFAULT_MIN_SIZE: float = 32.0
#endregion

#region Export Variables
@export_group("Label", "label_")
@export var label_display_mode: LabelDisplayMode = LabelDisplayMode.NAME: set = _set_label_display_mode
@export var label_position: LabelPosition = LabelPosition.LEFT: set = _set_label_position
@export var label_h_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT: set = _set_label_h_alignment
@export var label_v_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER: set = _set_label_v_alignment

@export_group("Contents", "contents_")
@export var contents_position: ContentsPosition = ContentsPosition.LEFT_OR_TOP: set = _set_contents_position

@export_group("Sizing", "sizing_")
@export var sizing_margins: Vector2i = Vector2i.ONE * DEFAULT_SPACING: set = _set_sizing_margins
@export var sizing_separation: int = DEFAULT_SPACING: set = _set_sizing_separation
@export var sizing_label_min_size: Vector2 = Vector2.ONE * DEFAULT_MIN_SIZE: set = _set_sizing_label_min_size
@export var sizing_contents_min_size: Vector2 = Vector2.ONE * DEFAULT_MIN_SIZE: set = _set_sizing_contents_min_size

@export_group("Theme", "theme_")
@export var theme_contents_panel_style_override: StyleBox: set = _set_theme_contents_panel_style_override

@export_group("Debugging", "debug_")
@export var debug_log_warnings: bool
#endregion

#region Public Variables
var label_position_is_horizontal: bool: get = _get_label_position_is_horizontal
var label_position_is_bottom_or_right: bool: get = _get_label_position_is_bottom_or_right
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _to_string() -> String:
	return "<PropertyPanelOptions#%d>" % get_instance_id()
#endregion

#region Public Methods
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
# Label
func _set_label_display_mode(arg: LabelDisplayMode) -> void:
	label_display_mode = arg
	emit_changed()


func _set_label_position(arg: LabelPosition) -> void:
	label_position = arg
	emit_changed()


func _set_label_h_alignment(arg: HorizontalAlignment) -> void:
	label_h_alignment = arg
	emit_changed()


func _set_label_v_alignment(arg: VerticalAlignment) -> void:
	label_v_alignment = arg
	emit_changed()

# Panel Input
func _set_contents_position(arg: ContentsPosition) -> void:
	contents_position = arg
	emit_changed()

# Sizing
func _set_sizing_margins(arg: Vector2i) -> void:
	sizing_margins = arg.max(Vector2i.ZERO)
	emit_changed()


func _set_sizing_separation(arg: int) -> void:
	sizing_separation = arg
	emit_changed()


func _set_sizing_label_min_size(arg: Vector2) -> void:
	sizing_label_min_size = arg.max(Vector2.ZERO)
	emit_changed()


func _set_sizing_contents_min_size(arg: Vector2) -> void:
	sizing_contents_min_size = arg.max(Vector2.ZERO)
	emit_changed()

# Theme
func _set_theme_contents_panel_style_override(arg: StyleBox) -> void:
	theme_contents_panel_style_override = arg
	emit_changed()
#endregion

#region Getter Methods
func _get_label_position_is_horizontal() -> bool:
	return label_position == LabelPosition.LEFT or label_position == LabelPosition.RIGHT


func _get_label_position_is_bottom_or_right() -> bool:
	return label_position == LabelPosition.BOTTOM or label_position == LabelPosition.RIGHT
#endregion
