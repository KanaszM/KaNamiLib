#@tool
class_name PathDirListOptions
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var allow_dirs: bool = true
var allow_files: bool = true
var recursive: bool
var limit: int: set = _set_limit

var include_file_extensions: Array[String]: set = _set_include_file_extensions
var exclude_file_extensions: Array[String]: set = _set_exclude_file_extensions

var exclude_dir_names: Array[String]
var exclude_file_names: Array[String]
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
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
func _set_limit(arg: int) -> void:
	limit = maxi(0, arg)


func _set_include_file_extensions(arg: Array[String]) -> void:
	include_file_extensions = Array(
		arg.map(func(entry: String) -> String: return entry.replace(".", "")), TYPE_STRING, &"", null
		) as Array[String]


func _set_exclude_file_extensions(arg: Array[String]) -> void:
	exclude_file_extensions = Array(
		arg.map(func(entry: String) -> String: return entry.replace(".", "")), TYPE_STRING, &"", null
		) as Array[String]
#endregion

#region Getter Methods
#endregion
