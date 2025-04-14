#@tool
class_name LoggerFileOptions
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
var root_dir_name: String = "logs"

var file_prefix: String = "log_"
var file_extension: String = "tsv"
var files_max_count: int = 50

var contents_separator: String = "\t"
var contents_header: Array[String] = ["date", "time", "type", "origin", "method", "message"]
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
#endregion

#region Getter Methods
#endregion
