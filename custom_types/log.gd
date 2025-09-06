class_name Log

#region Enums
enum Type {INFO, ERROR, WARNING, SUCCESS, DEBUG, CRITICAL, TRACE, NOTICE, ALERT, FATAL}
#endregion

#region Constants
const ROOT_DIR_NAME: String = "logs"

const FILE_PREFIX: String = "log_"
const FILE_EXTENSION: String = "tsv"
const FILES_MAX_COUNT: int = 50

const CONTENTS_SEPARATOR: String = "\t"
const CONTENTS_HEADER: Array[String] = ["date", "time", "type", "origin", "method", "contents"]
#endregion

#region Private Static Variables
static var _file: FileAccess
#endregion

#region Static Public Methods
static func initialize_file_logging() -> void:
	var root_dir_path: String = OS.get_user_data_dir().path_join(ROOT_DIR_NAME)
	
	if not DirAccess.dir_exists_absolute(root_dir_path):
		var error_code: Error = DirAccess.make_dir_absolute(root_dir_path)
		
		if error_code != OK:
			error(
				"Could not create the dir at path: '%s'! %s" % [root_dir_path, error_string(error_code)],
				initialize_file_logging
				)
			return
	
	var dir: DirAccess = DirAccess.open(root_dir_path)
	
	if dir == null:
		error(
			"Could not open the dir at path: '%s'! %s" % [root_dir_path, error_string(DirAccess.get_open_error())],
			initialize_file_logging
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
		error(
			"Could not write the file at path: '%s'! %s" % [new_file_path, error_string(FileAccess.get_open_error())],
			initialize_file_logging
			)
		return
	
	_file.store_csv_line(CONTENTS_HEADER, CONTENTS_SEPARATOR)
#endregion

#region Static Public Methods
static func info(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.INFO, contents, origin, options)


static func error(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.ERROR, contents, origin, options)


static func warning(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.WARNING, contents, origin, options)


static func success(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.SUCCESS, contents, origin, options)


static func debug(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	if OS.is_debug_build():
		_format_entry(Type.DEBUG, contents, origin, options)


static func critical(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.CRITICAL, contents, origin, options)


static func trace(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.TRACE, contents, origin, options)


static func notice(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.NOTICE, contents, origin, options)


static func alert(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.ALERT, contents, origin, options)


static func fatal(contents: Variant, origin: Callable = Callable(), options: Options = null) -> void:
	_format_entry(Type.FATAL, contents, origin, options)
#endregion

#region Private Methods
static func _format_entry(type: Type, contents: Variant, origin: Callable, options: Options) -> void:
	if options == null:
		options = Options.new()
	
	var str_type: String = PackedStringArray(Type.keys())[type]
	var str_contents: String = str(contents)
	
	var origin_object: Object
	var origin_string: String = options.placeholder_null
	var origin_method: String = options.placeholder_null if options.indent_prefix.is_empty() else options.indent_prefix
	
	if origin.is_valid():
		origin_object = origin.get_object()
		origin_method = origin.get_method()
		
		if origin_object is Resource:
			origin_string = (origin_object as Resource).resource_path.get_file().get_slice(".", 0)
			
			if origin_string.is_empty():
				origin_string = str(origin_object)
		
		elif origin_object is Node:
			origin_string = (origin_object as Node).name
		
		else:
			origin_string = str(origin_object)
	
	if options.enable_file_logging and _file != null:
		_file.store_csv_line(
			PackedStringArray([
				DateTime.format_system_date("ddmmmyyyy"),
				DateTime.format_system_time("hhmmss"),
				str_type,
				str_type.capitalize() if origin_string == options.placeholder_null else origin_string,
				origin_method,
				str_contents,
				]),
			CONTENTS_SEPARATOR
			)
		_file.flush()
	
	if options.enable_output_logging:
		var formatted_message: String = "%s%s%s%s" % [
			"".lpad(options.indent_length, " "),
			"" if options.indent_prefix.is_empty() else ("%s " % options.indent_prefix),
			"" if origin_string == options.placeholder_null else (
				"%s.%s%s" % [origin_string, origin_method, options.divider]
				),
			str_contents.strip_edges().strip_escapes(),
			]
		
		match type:
			Type.ERROR, Type.CRITICAL, Type.FATAL: push_error(formatted_message)
			Type.WARNING, Type.ALERT: push_warning(formatted_message)
			Type.INFO: print("%s%s" % [options.icon_info, formatted_message])
			Type.SUCCESS: print("%s%s" % [options.icon_success, formatted_message])
			Type.NOTICE: print("%s%s" % [options.icon_notice, formatted_message])
			Type.TRACE: print("%s%s" % [options.icon_trace, formatted_message])
			Type.DEBUG: print("%s%s" % [options.icon_debug, formatted_message])
			_: print(formatted_message)
#endregion

#region SubClasses
class Options:
	#region Public Variables
	var indent_length: int
	var indent_prefix: String

	var placeholder_null: String

	var enable_output_logging: bool = true
	var enable_file_logging: bool = true
	
	var icon_info: String = "ℹ️ "
	var icon_success: String = "✅ "
	var icon_notice: String = "💡 "
	var icon_trace: String = "🔍 "
	var icon_debug: String = "⚙️ "
	
	var divider: String = " :: "
	#endregion
#endregion
