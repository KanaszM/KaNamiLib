@tool
class_name EnumBoxAlignProperty
extends Property

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var value: BoxContainer.AlignmentMode: set = _set_value
#endregion

#region Public Variables
var default_value: BoxContainer.AlignmentMode
var previous_value: BoxContainer.AlignmentMode
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(
	name_arg: String = "",
	default_value_arg: BoxContainer.AlignmentMode = BoxContainer.AlignmentMode.ALIGNMENT_BEGIN,
	) -> void:
		super._init(Type.ENUM_BOX_ALIGN, name_arg)
		
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


func is_changed() -> int:
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
func _set_value(arg: BoxContainer.AlignmentMode) -> void:
	previous_value = value
	value = arg
	
	if not _default_value_set:
		default_value = value
	
	emit_changed()
#endregion

#region Getter Methods
#endregion
