class_name Log

#region Enums
enum Type {INFO, ERROR, WARNING, SUCCESS, DEBUG, CRITICAL, TRACE, NOTICE, ALERT, FATAL}
#endregion

#region Private Variables
static var _file: FileAccess
static var _file_options: LogFileOptions = LogFileOptions.new()
#endregion

#region Static Methods
static func initialize_file_logging(options: LogFileOptions = null) -> void:
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


static func info(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.INFO, callback, message, options)


static func error(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.ERROR, callback, message, options)


static func warning(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.WARNING, callback, message, options)


static func success(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.SUCCESS, callback, message, options)


static func debug(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	if OS.is_debug_build():
		_format_entry(Type.DEBUG, callback, message, options)


static func critical(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.CRITICAL, callback, message, options)


static func trace(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.TRACE, callback, message, options)


static func notice(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.NOTICE, callback, message, options)


static func alert(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.ALERT, callback, message, options)


static func fatal(callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	_format_entry(Type.FATAL, callback, message, options)


static func _format_entry(type: Type, callback: Callable, message: Variant, options: LogEntryOptions = null) -> void:
	if options == null:
		options = LogEntryOptions.new()
	
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
			"" if origin_string == options.placeholder_null else ("%s.%s :: " % [origin_string, origin_method]),
			str_message.strip_edges().strip_escapes(),
			]
		
		match type:
			Type.ERROR, Type.CRITICAL: push_error(formatted_message)
			Type.WARNING, Type.ALERT: push_warning(formatted_message)
			Type.SUCCESS: print("✅ %s" % formatted_message)
			Type.NOTICE: print("💡 %s" % formatted_message)
			Type.TRACE: print("🔍 %s" % formatted_message)
			Type.DEBUG: print("⚙️ %s" % formatted_message)
			_: print(formatted_message)
#endregion
