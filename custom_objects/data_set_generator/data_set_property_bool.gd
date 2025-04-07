"""
# Version 1.0.0 (28-Mar-2025):
	- Initial release;
"""

#@tool
class_name DataSetPropertyBool
extends DataSetProperty

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
var _default_value: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(property_name: String, default_value: bool = false) -> void:
	super._init(Type.BOOL, property_name)
	
	_default_value = default_value
#endregion

#region Public Methods
func get_default_value() -> bool:
	return _default_value


func get_default_value_string() -> String:
	return str(_default_value)


func get_variable_string() -> String:
	return "var %s : bool = %s : set = _set_%s" % [name, get_default_value_string(), name]


func get_setter_string(signal_name: String) -> String:
	var lines: PackedStringArray = PackedStringArray([
		"func _set_%s(arg: bool) -> void:" % name,
			"\t%s = arg" % name,
		])
	
	if emit_changed_enabled and not signal_name.is_empty():
		lines.append("\t%s.emit()" % signal_name)
	
	lines.append("\n")
	
	return "\n".join(lines)


func get_signature_string() -> String:
	return "#%d#%s#%s#%s" % [type, name, get_default_value_string(), ", ".join(PackedStringArray([]))]


func get_helper_methods_string_pack() -> PackedStringArray:
	var contents: PackedStringArray
	
	contents.append_array(PackedStringArray([
		"func get_default_value_%s() -> bool:" % name,
			"\treturn %s" % get_default_value_string(),
		"",
		"",
		"func toggle_%s() -> void:" % name,
			"\t%s = not %s" % [name, name],
		"",
		"",
		]))
	
	return contents
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
