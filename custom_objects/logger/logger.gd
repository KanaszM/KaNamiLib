"""
# Version 3.2.0 (29-Mar-2025):
	- Using the `Path` class for all file-related operations;
	- Eliminated static initialization, allowing users to manually initiate it if file logging is desired;
	- Moved constants into a dedicated options class;

# Version 2.2.0 (29-Mar-2025):
	- Separated the internal classes into their own files;

# Version 2.1.0 (25-Mar-2025):
	- Verifying the number of debug instance runs during initialization to prevent the cleanup of
	old log files from being executed multiple times;

# Version 2.0.0 (20-Mar-2025):
	- Refactored the entire class;
	- Replaced logging with engine prints;
	- Introduced an `LoggerEntryOptions` class to streamline method calls by reducing the number of arguments;
"""

#@tool
class_name Logger
#extends 

#region Signals
#endregion

#region Enums
enum Type {INFO, ERROR, WARNING, SUCCESS, DEBUG, CRITICAL, TRACE, NOTICE, ALERT, FATAL}
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
static var _file: FileAccess
static var _file_options: LoggerFileOptions = LoggerFileOptions.new()
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
static func initialize_file_logging(options: LoggerFileOptions = null) -> void:
	if options != null:
		_file_options = options
	
	var path_options: PathOptions = PathOptions.new()
	
	path_options.logging_type = PathOptions.LoggingType.ENGINE
	path_options.dir_create_if_not_exists = true
	
	var root_dir_path: Path = Path.new_user_data_dir(path_options).join(_file_options.root_dir_name)
	
	if not root_dir_path.is_valid:
		return
	
	var current_file_paths_options: PathDirListOptions = PathDirListOptions.new()
	
	current_file_paths_options.include_file_extensions = [_file_options.file_extension]
	
	var current_file_paths: Array[Path] = root_dir_path.dir_list(current_file_paths_options)
	
	if current_file_paths.size() >= _file_options.files_max_count:
		current_file_paths = Path.get_sorted_by_modified_time(current_file_paths)
		
		for current_file_path: Path in current_file_paths.slice(_file_options.files_max_count - 1) as Array[Path]:
			await (Engine.get_main_loop() as SceneTree).process_frame
			current_file_path.file_remove_if_exists()
	
	var new_file_name: String = "%s%s.%s" % [_file_options.file_prefix, DateTime.stamp(), _file_options.file_extension]
	var new_file_path: Path = Path.new_from_path(root_dir_path, path_options).join(new_file_name)
	
	_file = new_file_path.file_open_stream()
	
	if _file == null:
		return
	
	_file.store_csv_line(_file_options.contents_header, _file_options.contents_separator)


static func info(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.INFO, callback, message, options)


static func error(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.ERROR, callback, message, options)


static func warning(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.WARNING, callback, message, options)


static func success(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.SUCCESS, callback, message, options)


static func debug(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	if OS.is_debug_build():
		_format_entry(Type.DEBUG, callback, message, options)


static func critical(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.CRITICAL, callback, message, options)


static func trace(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.TRACE, callback, message, options)


static func notice(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.NOTICE, callback, message, options)


static func alert(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.ALERT, callback, message, options)


static func fatal(callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	_format_entry(Type.FATAL, callback, message, options)


static func _format_entry(type: Type, callback: Callable, message: Variant, options: LoggerEntryOptions = null) -> void:
	if options == null:
		options = LoggerEntryOptions.new()
	
	var str_type: String = PackedStringArray(Type.keys())[type]
	var str_message: String = str(message)
	
	var origin: Object
	var origin_string: String = options.placeholder_null
	var origin_method: String = options.placeholder_null if options.indent_prefix.is_empty() else options.indent_prefix
	
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
	
	if options.enable_file_logging and _file != null:
		_file.store_csv_line(
			PackedStringArray([
				DateTime.format_system_date("ddmmmyyyy"),
				DateTime.format_system_time("hhmmss"),
				str_type,
				str_type.capitalize() if origin_string == options.placeholder_null else origin_string,
				origin_method,
				str_message,
				]),
			_file_options.contents_separator
			)
		_file.flush()
	
	if options.enable_output_logging and OS.is_debug_build():
		var formatted_message: String = "%s%s%s%s" % [
			"".lpad(options.indent_length, " "),
			"" if options.indent_prefix.is_empty() else ("%s " % options.indent_prefix),
			"" if origin_string == options.placeholder_null else ("<%s.%s> " % [origin_string, origin_method]),
			str_message.strip_edges().strip_escapes(),
			]
		
		if OS.has_feature("editor"):
			var entry_html_color: String = (
				options.output_custom_color if options.output_custom_color != Color.TRANSPARENT
				else _get_entry_color(type)
				).to_html()
			
			print_rich(
				"[color=%s][font_size=%d]%s[/font_size][/color]"
				% [entry_html_color, options.output_font_size, formatted_message]
				)
		
		else:
			print(formatted_message)


static func _get_entry_color(type: Type) -> Color:
	match type:
		Type.INFO: return Shade.gray(3)
		Type.ERROR: return Shade.red(4)
		Type.WARNING: return Shade.yellow(4)
		Type.SUCCESS: return Shade.green(4)
		Type.DEBUG: return Shade.cyan(4)
		Type.CRITICAL: return Shade.pink(5)
		Type.TRACE: return Shade.indigo(4)
		Type.NOTICE: return Shade.violet(4)
		Type.ALERT: return Shade.orange(5)
		Type.FATAL: return Shade.grape(6)
		_: return Shade.gray(0) 
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
