extends Node # class_name Log

#region Enums
enum Type {INFO, ERROR, WARNING, SUCCESS, DEBUG, CRITICAL, TRACE, NOTICE, ALERT, FATAL}
#endregion

#region Constants
const ROOT_DIR_NAME: String = "logs"

const FILE_PREFIX: String = "log_"
const FILE_EXTENSION: String = "tsv"
const FILES_MAX_COUNT: int = 50

const CONTENTS_SEPARATOR: String = "\t"
const CONTENTS_HEADER: Array[String] = ["date", "time", "type", "origin", "method", "message"]
#endregion

#region Public Variables
var entry_options: LogEntryOptions
#endregion

#region Private Variables
var _file: FileAccess
var _init_result: Result
#endregion

#region Constructor
func _ready() -> void:
	_init_result = Result.new()
	
	var root_dir_path: String = OS.get_user_data_dir().path_join(ROOT_DIR_NAME)
	
	if not DirAccess.dir_exists_absolute(root_dir_path):
		var error_code: Error = DirAccess.make_dir_absolute(root_dir_path)
		
		if error_code != OK:
			_init_result.error("Could not create the dir at path: '%s'! %s" % [root_dir_path, error_string(error_code)])
			return
	
	var dir: DirAccess = DirAccess.open(root_dir_path)
	
	if dir == null:
		_init_result.error(
			"Could not open the dir at path: '%s'! %s" % [root_dir_path, error_string(DirAccess.get_open_error())]
			)
		return
	
	dir.list_dir_begin()
	
	var current_file_paths: Array[String]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if not dir.current_is_dir():
			if current_element.get_extension() == FILE_EXTENSION:
				current_file_paths.append(current_element)
		
		current_element = dir.get_next()
	
	if current_file_paths.size() >= FILES_MAX_COUNT:
		current_file_paths = UtilsFSO.get_sorted_by_modified_time(current_file_paths)
		
		for current_file_path: String in current_file_paths.slice(FILES_MAX_COUNT - 1) as Array[String]:
			await (Engine.get_main_loop() as SceneTree).process_frame
			
			if FileAccess.file_exists(current_file_path):
				DirAccess.remove_absolute(current_file_path)
	
	var new_file_name: String = "%s%s.%s" % [FILE_PREFIX, DateTime.stamp(), FILE_EXTENSION]
	var new_file_path: String = root_dir_path.path_join(new_file_name)
	
	_file = FileAccess.open(new_file_path, FileAccess.WRITE)
	
	if _file == null:
		_init_result.error(
			"Could not write the file at path: '%s'! %s" % [new_file_path, error_string(FileAccess.get_open_error())]
			)
		return
	
	_file.store_csv_line(CONTENTS_HEADER, CONTENTS_SEPARATOR)
	_init_result.success()
#endregion

#region Public Methods
func info(callback: Callable, message: Variant) -> void:
	_format_entry(Type.INFO, callback, message)


func error(callback: Callable, message: Variant) -> void:
	_format_entry(Type.ERROR, callback, message)


func warning(callback: Callable, message: Variant) -> void:
	_format_entry(Type.WARNING, callback, message)


func success(callback: Callable, message: Variant) -> void:
	_format_entry(Type.SUCCESS, callback, message)


func debug(callback: Callable, message: Variant) -> void:
	if OS.is_debug_build():
		_format_entry(Type.DEBUG, callback, message)


func critical(callback: Callable, message: Variant) -> void:
	_format_entry(Type.CRITICAL, callback, message)


func trace(callback: Callable, message: Variant) -> void:
	_format_entry(Type.TRACE, callback, message)


func notice(callback: Callable, message: Variant) -> void:
	_format_entry(Type.NOTICE, callback, message)


func alert(callback: Callable, message: Variant) -> void:
	_format_entry(Type.ALERT, callback, message)


func fatal(callback: Callable, message: Variant) -> void:
	_format_entry(Type.FATAL, callback, message)
#endregion

#region Private Methods
func _format_entry(type: Type, callback: Callable, message: Variant) -> void:
	if entry_options == null:
		entry_options = LogEntryOptions.new()
	
	var str_type: String = PackedStringArray(Type.keys())[type]
	var str_message: String = str(message)
	
	var origin: Object
	var origin_string: String = entry_options.placeholder_null
	var origin_method: String = (
		entry_options.placeholder_null if entry_options.indent_prefix.is_empty() else entry_options.indent_prefix
		)
	
	if callback.is_valid():
		origin = callback.get_object()
		origin_method = callback.get_method()
		
		if origin is Resource:
			origin_string = (origin as Resource).resource_path.get_file().get_slice(".", 0)
			
			if origin_string.is_empty():
				origin_string = str(origin)
		
		elif origin is Node:
			origin_string = (origin as Node).name
		
		else:
			origin_string = str(origin)
	
	if entry_options.enable_file_logging and _file != null:
		_file.store_csv_line(
			PackedStringArray([
				DateTime.format_system_date("ddmmmyyyy"),
				DateTime.format_system_time("hhmmss"),
				str_type,
				str_type.capitalize() if origin_string == entry_options.placeholder_null else origin_string,
				origin_method,
				str_message,
				]),
			CONTENTS_SEPARATOR
			)
		_file.flush()
	
	if entry_options.enable_output_logging and OS.is_debug_build():
		var formatted_message: String = "%s%s%s%s" % [
			"".lpad(entry_options.indent_length, " "),
			"" if entry_options.indent_prefix.is_empty() else ("%s " % entry_options.indent_prefix),
			"" if origin_string == entry_options.placeholder_null else ("%s.%s :: " % [origin_string, origin_method]),
			str_message.strip_edges().strip_escapes(),
			]
		
		match type:
			Type.ERROR, Type.CRITICAL, Type.FATAL: push_error(formatted_message)
			Type.WARNING, Type.ALERT: push_warning(formatted_message)
			Type.INFO: print("ℹ️ %s" % formatted_message)
			Type.SUCCESS: print("✅ %s" % formatted_message)
			Type.NOTICE: print("💡 %s" % formatted_message)
			Type.TRACE: print("🔍 %s" % formatted_message)
			Type.DEBUG: print("⚙️ %s" % formatted_message)
			_: print(formatted_message)
#endregion
