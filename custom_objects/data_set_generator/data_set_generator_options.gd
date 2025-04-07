"""
# Version 1.0.1 (29-Mar-2025):
	- Removed the `custom_extension_name` variable. Only Node and Resource is permited;

# Version 1.0.0 (28-Mar-2025):
	- Initial release;
"""

#@tool
class_name DataSetGeneratorOptions
extends Node

#region Signals
#endregion

#region Enums
enum Type {SINGLETON, RESOURCE, NODE}
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var type: Type = Type.SINGLETON

var file_name: String = "data"
var custom_class_name: String = "Data"
var custom_signal_name: String = "value_changed"

var export_dir_path: String = "user://"
var export_file_name: String = "data"
var export_json_extension: String = "json"
var export_config_extension: String = "cfg"
var export_compressed_extension: String = "dat"
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init() -> void:
	assert(not file_name.is_empty())
	assert(not file_name.contains("."))
	assert(not export_dir_path.is_empty())
	assert(not export_dir_path.contains("."))
	assert(not export_file_name.is_empty())
	assert(not export_file_name.contains("."))
	assert(not export_json_extension.is_empty())
	assert(not export_json_extension.begins_with("."))
	assert(not export_config_extension.is_empty())
	assert(not export_config_extension.begins_with("."))
	assert(not export_compressed_extension.is_empty())
	assert(not export_compressed_extension.begins_with("."))
#endregion

#region Public Methods
func get_class_name() -> String:
	if type == Type.SINGLETON:
		return ""
	
	assert(not custom_class_name.is_empty())
	return custom_class_name


func get_class_extends() -> String:
	return "Resource" if type == Type.RESOURCE else "Node"


func get_changed_signal_name() -> String:
	if type == Type.RESOURCE:
		return "changed"
	
	assert(not custom_signal_name.is_empty())
	return custom_signal_name


func get_export_json_file_path() -> String:
	return "%s%s.%s" % [export_dir_path, export_file_name, export_json_extension]


func get_export_config_file_path() -> String:
	return "%s%s.%s" % [export_dir_path, export_file_name, export_config_extension]


func get_export_compressed_file_path() -> String:
	return "%s%s.%s" % [export_dir_path, export_file_name, export_compressed_extension]
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
