"""
# Version 1.0.1 (03-Apr-2025):
	- Added to_string definition;
	
# Version 1.0.0 (28-Mar-2025):
	- Initial release;
"""

#@tool
class_name DataSetProperty
#extends 

#region Signals
#endregion

#region Enums
enum Type {
	NONE = -1,
	ARRAY = 28,
	BOOL = 1,
	FLOAT = 3,
	INT = 2,
	STRING = 4,
	}
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var type: Type = Type.NONE
var name: String
var emit_changed_enabled: bool = true: set = emit_changed
var is_valid: bool
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(type_arg: Type, property_name: String) -> void:
	type = type_arg
	
	if type == Type.NONE:
		printerr("The property type cannot be none!")
	
	name = property_name.strip_edges()
	
	if name.is_empty():
		printerr("The property name cannot be empty!")
	
	is_valid = true


func _to_string() -> String:
	return "<DataSetProperty[%s][%s][%s]>" % [UtilsDictionary.enum_to_str(Type, type), name, get_default_value()]
#endregion

#region Public Methods
func get_default_value() -> Variant:
	printerr("Called from an abstract class!")
	return null


func get_default_value_string() -> String:
	printerr("Called from an abstract class!")
	return ""


func get_variable_string() -> String:
	printerr("Called from an abstract class!")
	return ""


func get_setter_string(_signal_name: String) -> String:
	printerr("Called from an abstract class!")
	return ""


func get_signature_string() -> String:
	printerr("Called from an abstract class!")
	return ""


func get_helper_methods_string_pack() -> PackedStringArray:
	printerr("Called from an abstract class!")
	return PackedStringArray([])
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
func emit_changed(mode: bool) -> DataSetProperty:
	emit_changed_enabled = mode
	return self
#endregion

#region Getter Methods
#endregion
