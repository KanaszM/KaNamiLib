class_name SQLManagerFile

#region Constants
const DATE_FORMAT: String = "yyyymmdd"
const TIME_FORMAT: String = "hhmmss"
#endregion

#region Private Variables
var _path: String
var _name: String
var _date: String
var _size: int
#endregion

#region Virtual Methods
func _init(path: String) -> void:
	path = path.strip_edges()
	
	if path.is_empty():
		Log.error("No path was provided!", _init)
		return
	
	var file_modified_time: int = FileAccess.get_modified_time(path)
	
	if file_modified_time == 0:
		Log.error("Could not get the modified time for file at path: '%s'!" % path, _init)
		return
	
	var file_size: int = FileAccess.get_size(path)
	
	if file_size == -1:
		Log.error("Could not get the size for file at path: '%s'!" % path, _init)
		return
	
	_path = path
	_size = file_size
	_name = UtilsFSO.get_file_name_from_path(_path)
	_date = DateTime.format_system_datetime(
		DATE_FORMAT, TIME_FORMAT, Time.get_datetime_dict_from_unix_time(file_modified_time)
		)


func _to_string() -> String:
	return "<SQLManagerFile[%s]>" % get_file_name()


func _get_class() -> String:
	return "SQLManagerFile"
#endregion

#region Public Methods
func get_path() -> String:
	return _path


func get_file_name() -> String:
	return _name


func get_modified_datetime() -> String:
	return _date


func get_size() -> int:
	return _size


func to_dict() -> Dictionary[String, Variant]:
	return {
		"path": _path,
		"name": _name,
		"date": _date,
		"size": _size,
		}
#endregion
