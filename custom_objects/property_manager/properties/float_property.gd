@tool
class_name FloatProperty
extends Property

#region Signals
#endregion

#region Enums
enum InputEditMode {TYPING, PERCENTAGE_MENU}
enum StepButtonsType {NONE, SIDE, BETWEEN}
#endregion

#region Constants
#endregion

#region Export Variables
@export var value: float: set = _set_value
@export var value_bounds: Vector2 = Vector2(UtilsNumeric.FLOAT16_MIN, UtilsNumeric.FLOAT16_MAX): set = _set_value_bounds

@export_group("Line Edit", "input_")
@export var input_edit_mode: InputEditMode = InputEditMode.TYPING: set = _set_input_edit_mode
@export var input_clear_button_enabled: bool = true: set = _set_input_clear_button_enabled
@export var input_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER: set = _set_input_alignment
@export var input_max_length: int: set = _set_input_max_length
@export var input_font_size: int = 16: set = _set_input_font_size

@export_group("Percentage Menu", "percentage_menu_")
@export var percentage_menu_button_index: MouseButton = MOUSE_BUTTON_LEFT: set = _set_percentage_menu_button_index
@export var percentage_menu_bounds: Vector2i = Vector2i(0, 100): set = _set_percentage_menu_bounds
@export var percentage_menu_step: int = 10: set = _set_percentage_menu_step

@export_group("Step Buttons", "step_buttons_")
@export var step_buttons_type: StepButtonsType = StepButtonsType.SIDE: set = _set_step_buttons_type
@export var step_buttons_min_size: Vector2: set = _set_step_buttons_min_size
@export var step_buttons_font_size: int = 10: set = _set_step_buttons_font_size
@export var step_buttons_separation: int = 4: set = _set_step_buttons_side_separation
@export_subgroup("Increment", "step_buttons_increment_")
@export var step_buttons_increment_text: String = "+": set = _set_step_buttons_increment_text
@export var step_buttons_increment_icon: CompressedTexture2D: set = _set_step_buttons_increment_icon
@export_subgroup("Increment", "step_buttons_decrement_")
@export var step_buttons_decrement_text: String = "-": set = _set_step_buttons_decrement_text
@export var step_buttons_decrement_icon: CompressedTexture2D: set = _set_step_buttons_decrement_icon
@export_subgroup("Side Type", "step_buttons_side_")
@export var step_buttons_side_spacing: int: set = _set_step_buttons_side_spacing

@export_group("Step Multipliers", "step_")
@export var step_value: float = 0.1: set = _set_step_value
@export_subgroup("Level 1", "step_1_")
@export var step_1_multiply: float = 10.0: set = _set_step_1_multiply
@export var step_1_key: Key = Key.KEY_SHIFT: set = _set_step_1_key
@export_subgroup("Level 2", "step_2_")
@export var step_2_multiply: float = 100.0: set = _set_step_2_multiply
@export var step_2_key: Key = Key.KEY_CTRL: set = _set_step_2_key
@export_subgroup("Level 3", "step_3_")
@export var step_3_multiply: float = 1000.0: set = _set_step_3_multiply
@export var step_3_key: Key = Key.KEY_ALT: set = _set_step_3_key
#endregion

#region Public Variables
var default_value: float
var previous_value: float
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(name_arg: String = "", default_value_arg: float = 0.0) -> void:
	super._init(Type.FLOAT, name_arg)
	
	value = default_value_arg


func _to_string() -> String:
	return "%s[%s]>" % [super._to_string().trim_suffix(">"), value]
#endregion

#region Public Methods
func is_valid() -> bool:
	if not super.is_valid():
		return false
	
	return true


func reset() -> void:
	value = default_value


func is_changed() -> float:
	return previous_value != value
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
func _set_value(arg: float) -> void:
	previous_value = value
	value = arg
	
	if not _default_value_set:
		default_value = value
	
	emit_changed()


func _set_value_bounds(arg: Vector2) -> void:
	value_bounds = arg
	emit_changed()

# Input
func _set_input_edit_mode(arg: InputEditMode) -> void:
	input_edit_mode = arg
	emit_changed()


func _set_input_clear_button_enabled(arg: bool) -> void:
	input_clear_button_enabled = arg
	emit_changed()


func _set_input_alignment(arg: HorizontalAlignment) -> void:
	input_alignment = arg
	emit_changed()


func _set_input_max_length(arg: int) -> void:
	input_max_length = maxi(0, arg)
	emit_changed()


func _set_input_font_size(arg: int) -> void:
	input_font_size = maxi(0, arg)
	emit_changed()

# Percentage Menu
func _set_percentage_menu_button_index(arg: MouseButton) -> void:
	percentage_menu_button_index = arg
	emit_changed()


func _set_percentage_menu_bounds(arg: Vector2i) -> void:
	percentage_menu_bounds = UtilsVector.sorted_clamped_vector2i(arg, 0, 100)
	emit_changed()


func _set_percentage_menu_step(arg: int) -> void:
	percentage_menu_step = clampi(arg, 1, 100)
	emit_changed()

# Step Buttons
func _set_step_buttons_type(arg: StepButtonsType) -> void:
	step_buttons_type = arg
	emit_changed()


func _set_step_buttons_min_size(arg: Vector2) -> void:
	step_buttons_min_size = arg.max(Vector2.ZERO)
	emit_changed()


func _set_step_buttons_font_size(arg: int) -> void:
	step_buttons_font_size = maxi(0, arg)
	emit_changed()


func _set_step_buttons_side_separation(arg: int) -> void:
	step_buttons_separation = arg
	emit_changed()


func _set_step_buttons_increment_text(arg: String) -> void:
	step_buttons_increment_text = arg
	emit_changed()


func _set_step_buttons_increment_icon(arg: CompressedTexture2D) -> void:
	step_buttons_increment_icon = arg
	emit_changed()


func _set_step_buttons_decrement_text(arg: String) -> void:
	step_buttons_decrement_text = arg
	emit_changed()


func _set_step_buttons_decrement_icon(arg: CompressedTexture2D) -> void:
	step_buttons_decrement_icon = arg
	emit_changed()


func _set_step_buttons_side_spacing(arg: int) -> void:
	step_buttons_side_spacing = arg
	emit_changed()

# Step Multipliers
func _set_step_value(arg: float) -> void:
	step_value = maxf(0.001, arg)
	emit_changed()


func _set_step_1_multiply(arg: float) -> void:
	step_1_multiply = maxf(0.001, arg)
	emit_changed()


func _set_step_1_key(arg: Key) -> void:
	step_1_multiply = arg
	emit_changed()


func _set_step_2_multiply(arg: float) -> void:
	step_2_multiply = maxf(0.001, arg)
	emit_changed()


func _set_step_2_key(arg: Key) -> void:
	step_2_multiply = arg
	emit_changed()


func _set_step_3_multiply(arg: float) -> void:
	step_3_multiply = maxf(0.001, arg)
	emit_changed()


func _set_step_3_key(arg: Key) -> void:
	step_3_multiply = arg
	emit_changed()
#endregion

#region Getter Methods
#endregion
