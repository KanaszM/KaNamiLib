class_name LogFileOptions

#region Public Variables
var root_dir_name: String = "logs"

var file_prefix: String = "log_"
var file_extension: String = "tsv"
var files_max_count: int = 50

var contents_separator: String = "\t"
var contents_header: Array[String] = ["date", "time", "type", "origin", "method", "message"]
#endregion
