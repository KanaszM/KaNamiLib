class_name Log

#region Enums
enum Type {INFO, ERROR, WARNING, SUCCESS, DEBUG, CRITICAL, TRACE, NOTICE, ALERT, FATAL}
#endregion

#region Constants
const CONTENTS_SEPARATOR: String = "\t"
const CONTENTS_HEADER: Array[String] = ["date", "time", "type", "origin", "method", "contents"]
#endregion

#region Private Static Variables
static var _file: FileAccess
static var _options: Options
#endregion

#region Static Public Methods
static func _static_init() -> void:
	_options = Options.new()


static func initialize(options: Options = null) -> void:
	_options = Options.new() if options == null else options
	
	var root_dir_path: String = OS.get_user_data_dir().path_join(_options.root_dir_name)
	
	if not DirAccess.dir_exists_absolute(root_dir_path):
		var error_code: Error = DirAccess.make_dir_absolute(root_dir_path)
		
		if error_code != OK:
			error(
				"Could not create the dir at path: '%s'! %s" % [root_dir_path, error_string(error_code)], initialize
				)
			return
	
	var dir: DirAccess = DirAccess.open(root_dir_path)
	
	if dir == null:
		error(
			"Could not open the dir at path: '%s'! %s" % [root_dir_path, error_string(DirAccess.get_open_error())],
			initialize
			)
		return
	
	dir.list_dir_begin()
	
	var current_file_paths: Array[String]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if not dir.current_is_dir():
			if current_element.get_extension() == _options.file_extension:
				current_file_paths.append(current_element)
		
		current_element = dir.get_next()
	
	if current_file_paths.size() >= _options.files_max_count:
		current_file_paths = UtilsFSO.get_sorted_by_modified_time(current_file_paths)
		
		for current_file_path: String in current_file_paths.slice(_options.files_max_count - 1) as Array[String]:
			await (Engine.get_main_loop() as SceneTree).process_frame
			
			if FileAccess.file_exists(current_file_path):
				DirAccess.remove_absolute(current_file_path)
	
	var new_file_name: String = "%s%s.%s" % [_options.file_prefix, DateTime.stamp(), _options.file_extension]
	var new_file_path: String = root_dir_path.path_join(new_file_name)
	
	_file = FileAccess.open(new_file_path, FileAccess.WRITE)
	
	if _file == null:
		error(
			"Could not write the file at path: '%s'! %s" % [new_file_path, error_string(FileAccess.get_open_error())],
			initialize
			)
		return
	
	_file.store_csv_line(CONTENTS_HEADER, CONTENTS_SEPARATOR)
#endregion

#region Static Public Methods
static func info(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.INFO, contents, origin, format_options)


static func error(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.ERROR, contents, origin, format_options)


static func warning(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.WARNING, contents, origin, format_options)


static func success(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.SUCCESS, contents, origin, format_options)


static func debug(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.DEBUG, contents, origin, format_options)


static func critical(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.CRITICAL, contents, origin, format_options)


static func trace(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.TRACE, contents, origin, format_options)


static func notice(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.NOTICE, contents, origin, format_options)


static func alert(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.ALERT, contents, origin, format_options)


static func fatal(contents: Variant, origin: Callable = Callable(), format_options: FormatOptions = null) -> void:
	_format_entry(Type.FATAL, contents, origin, format_options)
#endregion

#region Private Methods
static func _format_entry(type: Type, contents: Variant, origin: Callable, format_options: FormatOptions) -> void:
	if _options == null:
		_options = Options.new()
	
	var is_enabled: bool = true
	
	match type:
		Type.INFO: is_enabled = _options.enable_info_logging
		Type.ERROR: is_enabled = _options.enable_error_logging
		Type.WARNING: is_enabled = _options.enable_warning_logging
		Type.SUCCESS: is_enabled = _options.enable_success_logging
		Type.DEBUG: is_enabled = _options.enable_debug_logging
		Type.CRITICAL: is_enabled = _options.enable_critical_logging
		Type.TRACE: is_enabled = _options.enable_trace_logging
		Type.NOTICE: is_enabled = _options.enable_notice_logging
		Type.ALERT: is_enabled = _options.enable_alert_logging
		Type.FATAL: is_enabled = _options.enable_fatal_logging
	
	if not is_enabled:
		return
	
	if format_options == null:
		format_options = FormatOptions.new()
	
	var str_type: String = PackedStringArray(Type.keys())[type]
	var str_contents: String = str(contents)
	
	var origin_object: Object
	var origin_string: String = format_options.placeholder_null
	var origin_method: String = (
		format_options.placeholder_null if format_options.indent_prefix.is_empty() else format_options.indent_prefix
		)
	
	if _options.enable_origin and origin.is_valid():
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
	
	if _options.enable_file_logging and _file != null:
		_file.store_csv_line(
			PackedStringArray([
				DateTime.format_system_date(_options.format_date),
				DateTime.format_system_time(_options.format_time),
				str_type,
				str_type.capitalize() if origin_string == format_options.placeholder_null else origin_string,
				origin_method,
				str_contents,
				]),
			CONTENTS_SEPARATOR
			)
		_file.flush()
	
	if _options.enable_output_logging:
		var formatted_message: String = "%s%s%s%s" % [
			"".lpad(format_options.indent_length, " "),
			"" if format_options.indent_prefix.is_empty() else ("%s " % format_options.indent_prefix),
			"" if origin_string == format_options.placeholder_null else (
				"%s.%s%s" % [origin_string, origin_method, _options.divider]
				),
			str_contents.strip_edges().strip_escapes(),
			]
		
		if _options.output_max_length > 0:
			formatted_message = UtilsText.truncate(formatted_message, _options.output_max_length)
		
		match type:
			Type.ERROR, Type.CRITICAL, Type.FATAL: push_error(formatted_message)
			Type.WARNING, Type.ALERT: push_warning(formatted_message)
			Type.INFO: print("%s%s" % [_options.icon_info, formatted_message])
			Type.SUCCESS: print("%s%s" % [_options.icon_success, formatted_message])
			Type.NOTICE: print("%s%s" % [_options.icon_notice, formatted_message])
			Type.TRACE: print("%s%s" % [_options.icon_trace, formatted_message])
			Type.DEBUG: print("%s%s" % [_options.icon_debug, formatted_message])
			_: print(formatted_message)
#endregion

#region SubClasses
class Options:
	#region Public Variables
	var root_dir_name: String = "logs"
	
	var file_prefix: String = "log_"
	var file_extension: String = "tsv"
	var files_max_count: int = 50
	
	var enable_output_logging: bool = true
	var enable_file_logging: bool = true
	var enable_info_logging: bool = true
	var enable_error_logging: bool = true
	var enable_warning_logging: bool = true
	var enable_success_logging: bool = true
	var enable_debug_logging: bool = true
	var enable_critical_logging: bool = true
	var enable_trace_logging: bool = true
	var enable_notice_logging: bool = true
	var enable_alert_logging: bool = true
	var enable_fatal_logging: bool = true
	var enable_origin: bool = true
	
	var icon_info: String = "ℹ️ "
	var icon_success: String = "✅ "
	var icon_notice: String = "💡 "
	var icon_trace: String = "🔍 "
	var icon_debug: String = "⚙️ "
	
	var divider: String = " :: "
	
	var format_date: String = "ddmmmyyyy"
	var format_time: String = "hhmmss"
	
	var output_max_length: int
	#endregion


class FormatOptions:
	#region Public Variables
	var indent_length: int
	var indent_prefix: String

	var placeholder_null: String
	#endregion
#endregion
