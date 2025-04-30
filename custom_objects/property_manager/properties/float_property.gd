@tool
class_name FloatProperty
extends Property

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var value: float: set = _set_value
@export var step: float: set = _set_step
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


func _set_step(arg: float) -> void:
	step = maxf(0.0, arg)
	emit_changed()
#endregion

#region Getter Methods
#endregion
