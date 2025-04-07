"""
# Version 1.0.0 (28-Mar-2025):
	- Initial release;
"""

#@tool
class_name DataSetPropertyString
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
var strip_on_set_enabled: bool: set = strip_on_set
#endregion

#region Private Variables
var _default_value: String
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(property_name: String, default_value: String = "") -> void:
	super._init(Type.STRING, property_name)
	
	_default_value = default_value.strip_edges()
#endregion

#region Public Methods
func get_default_value() -> String:
	return _default_value


func get_default_value_string() -> String:
	return "\"%s\"" % _default_value


func get_variable_string() -> String:
	return "var %s : String = %s : set = _set_%s" % [name, get_default_value_string(), name]


func get_setter_string(signal_name: String) -> String:
	var lines: PackedStringArray = PackedStringArray([
		"func _set_%s(arg: String) -> void:" % name,
			"\t%s = arg%s" % [name, ".strip_edges()" if strip_on_set_enabled else ""],
		])
	
	if emit_changed_enabled and not signal_name.is_empty():
		lines.append("\t%s.emit()" % signal_name)
	
	lines.append("\n")
	
	return "\n".join(lines)


func get_signature_string() -> String:
	return "#%d#%s#%s#%s" % [type, name, get_default_value_string(), ", ".join(PackedStringArray([
		strip_on_set_enabled,
		]))]

func get_helper_methods_string_pack() -> PackedStringArray:
	var contents: PackedStringArray
	
	contents.append_array(PackedStringArray([
		"func get_default_value_%s() -> String:" % name,
			"\treturn %s" % get_default_value_string(),
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
func strip_on_set(mode: bool) -> DataSetPropertyString:
	strip_on_set_enabled = mode
	return self
#endregion

#region Getter Methods
#endregion
