class_name PathOptions

#region Enums
enum LoggingType {NONE, ENGINE, INTERNAL}
#endregion

#region Public Variables
var logging_type: LoggingType = LoggingType.INTERNAL
var logging_errors_enabled: bool = true
var logging_warnings_enabled: bool
var logging_successes_enabled: bool

var dir_create_if_not_exists: bool
var file_create_if_not_exists: bool

var to_str_show_full_path: bool = true
var to_str_left_length: int = 16
var to_str_right_length: int = 32
#endregion
