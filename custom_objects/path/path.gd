class_name Path

#region Enums
enum Type {NONE, FILE, DIR}
#endregion

#region Public Variables
var path: String: set = _set_path
var options: PathOptions
var type: Type = Type.NONE: set = _set_type

var is_dir: bool
var is_file: bool
var is_valid: bool

var modified_time: int: get = _get_modified_time
#endregion

#region Private Variables
var _file_stream: FileAccess
#endregion

#region Virtual Methods
func _init(path_arg: String, options_arg: PathOptions = null) -> void:
	options = PathOptions.new() if options_arg == null else options_arg
	path = path_arg


func _to_string() -> String:
	var path_str: String = (
		path
		if options.to_str_show_full_path
		else UtilsText.truncate_middle(path, options.to_str_left_length, options.to_str_right_length)
		)
	
	return "<PathFile[%d][%s][%s]>" % [type, is_valid, path_str]
#endregion

#region General Public Methods
func join(path_to_join: String) -> Path:
	path = path.path_join(path_to_join)
	return self


func get_name() -> String:
	return path.get_file().get_slice(".", 0)


func exists() -> bool:
	if is_dir:
		return DirAccess.dir_exists_absolute(path)
	
	if is_file:
		return FileAccess.file_exists(path)
	
	return false


func remove(send_to_trash: bool = true, log_errors: bool = true) -> bool:
	if not exists():
		if log_errors:
			Log.error(remove, "Does not exist!")
		
		return false
	
	if is_dir:
		var dir_list_options: PathDirListOptions = PathDirListOptions.new()
		
		dir_list_options.limit = 1
		
		var dir_contents: PackedStringArray = dir_list(dir_list_options)
		
		if not dir_contents.is_empty():
			if log_errors:
				Log.error(remove, "Directory is not empty!")
			
			return false
	
	var error_code: Error = OS.move_to_trash(path) if send_to_trash else DirAccess.remove_absolute(path)
	
	if error_code != OK:
		if log_errors:
			Log.error(remove, "Could not be removed! %s" % error_string(error_code))
		
		return false
	
	return true
#endregion

#region File Public Methods
func file_validate_extension(extension: String) -> bool:
	if not is_valid:
		_log_error(file_validate_extension, "This path is invalid!")
		return false
	
	if is_dir:
		_log_warning(file_validate_extension, "This method is only applicable for files.")
		return false
	
	extension = extension.replace(".", "")
	
	return path.get_extension() == extension


func file_get_extension() -> String:
	if not is_valid:
		_log_error(file_get_extension, "This path is invalid!")
		return ""
	
	if is_dir:
		_log_warning(file_get_extension, "This method is only applicable for files.")
		return ""
	
	return path.get_extension()


func file_remove_if_exists() -> bool:
	if not is_valid:
		_log_error(file_remove_if_exists, "This path is invalid!")
		return false
	
	if is_dir:
		_log_warning(file_remove_if_exists, "This method is only applicable for files.")
		return false
	
	if not exists():
		return false
	
	if DirAccess.remove_absolute(path) != OK:
		_log_error(file_remove_if_exists, "File could not be removed! %s" % error_string(FileAccess.get_open_error()))
		return false
	
	return true


func file_open_stream(mode:  FileAccess.ModeFlags = FileAccess.WRITE) -> FileAccess:
	if not is_valid:
		_log_error(file_open_stream, "This path is invalid!")
		return null
	
	if is_dir:
		_log_warning(file_open_stream, "This method is only applicable for files.")
		return null
	
	if _file_stream != null:
		return _file_stream
	
	_file_stream = FileAccess.open(path, mode)
	
	if _file_stream == null:
		_log_error(file_open_stream, "File stream could not be created! %s" % error_string(FileAccess.get_open_error()))
		return null
	
	return _file_stream


func file_close_stream() -> bool:
	if not is_valid:
		_log_error(file_open_stream, "This path is invalid!")
		return false
	
	if is_dir:
		_log_warning(file_open_stream, "This method is only applicable for files.")
		return false
	
	if _file_stream == null:
		_log_warning(file_open_stream, "File stream not opened.")
		return false
	
	_file_stream.close()
	_file_stream = null
	
	return true


func file_get_contents(skip_empty_rows: bool = true) -> PackedStringArray:
	var contents: PackedStringArray
	
	if not is_valid:
		_log_error(file_get_contents, "This path is invalid!")
		return contents
	
	if is_dir:
		_log_warning(file_get_contents, "This method is only applicable for files.")
		return contents
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		_log_error(file_get_contents, "File could not be opened! %s" % error_string(FileAccess.get_open_error()))
		return contents
	
	var current_line: String
	
	while not file.eof_reached():
		current_line = file.get_line()
		
		if current_line.is_empty() and skip_empty_rows:
			continue
		
		contents.append(current_line)
	
	file.close()
	
	return contents


func file_get_csv_contents(skip_empty_rows: bool = true, csv_delimiter: String = ",") -> Array[PackedStringArray]:
	var contents: Array[PackedStringArray]
	
	if not is_valid:
		_log_error(file_get_contents, "This path is invalid!")
		return contents
	
	if is_dir:
		_log_warning(file_get_contents, "This method is only applicable for files.")
		return contents
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		_log_error(file_get_contents, "File could not be opened! %s" % error_string(FileAccess.get_open_error()))
		return contents
	
	var current_line: PackedStringArray
	var file_extension: String = path.get_extension()
	
	while not file.eof_reached():
		match file_extension:
			"csv":
				current_line = file.get_csv_line(csv_delimiter)
			"tsv":
				current_line = file.get_csv_line("\t")
			_:
				_log_error(file_get_contents, "Invalid csv file type!")
				return contents
		
		if current_line.is_empty() and skip_empty_rows:
			continue
		
		contents.append(current_line)
	
	file.close()
	
	return contents


func file_get_text_contents() -> String:
	var contents: String
	
	if not is_valid:
		_log_error(file_get_contents, "This path is invalid!")
		return contents
	
	if is_dir:
		_log_warning(file_get_contents, "This method is only applicable for files.")
		return contents
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		_log_error(file_get_contents, "File could not be opened! %s" % error_string(FileAccess.get_open_error()))
		return contents
	
	contents = file.get_as_text()
	file.close()
	
	return contents
#endregion

#region Dir Public Methods
func dir_list(dir_list_options: PathDirListOptions = null) -> Array[Path]:
	var paths: Array[Path]
	
	if not is_valid:
		_log_error(dir_list, "This path is invalid!")
		return paths
	
	if is_file:
		_log_warning(dir_list, "This method is only applicable to directories.")
		return paths
	
	if dir_list_options == null:
		dir_list_options = PathDirListOptions.new()
	
	var dir: DirAccess = DirAccess.open(path)
	
	if dir == null:
		_log_error(dir_list, "The directory could not be created!")
		return paths
	
	dir.list_dir_begin()
	
	var current_name: String = dir.get_next()
	
	while not current_name.is_empty():
		var current_path: Path = Path.new(path, options).join(current_name)
		var current_path_is_valid: bool = true
		
		if current_path.is_dir:
			if not dir_list_options.allow_dirs:
				current_path_is_valid = false
			
			if current_name in dir_list_options.exclude_dir_names:
				current_path_is_valid = false
			
			else:
				if dir_list_options.recursive:
					paths.append_array(current_path.dir_list(dir_list_options))
		
		elif current_path.is_file:
			if not dir_list_options.allow_files:
				current_path_is_valid = false
			
			else:
				var current_path_extension: String = current_path.file_get_extension()
				
				if not dir_list_options.include_file_extensions.is_empty():
					if current_path_extension not in dir_list_options.include_file_extensions:
						current_path_is_valid = false
				
				if current_path_extension in dir_list_options.exclude_file_extensions:
					current_path_is_valid = false
				
				if not dir_list_options.exclude_file_names.is_empty():
					if current_path.get_name() in dir_list_options.exclude_file_names:
						current_path_is_valid = false
		
		if current_path_is_valid:
			paths.append(current_path)
			
			if dir_list_options.limit > 0 and paths.size() >= 0:
				return paths.slice(0, dir_list_options.limit)
		
		current_name = dir.get_next()
	
	return paths


func dir_remove_contents(dir_remove_contents_options: PathDirRemoveContentsOptions = null) -> bool:
	if not is_valid:
		_log_error(dir_remove_contents, "This path is invalid!")
		return false
	
	if is_file:
		_log_warning(dir_remove_contents, "This method is only applicable to directories.")
		return false
	
	if dir_remove_contents_options == null:
		dir_remove_contents_options = PathDirRemoveContentsOptions.new()
	
	var dir: DirAccess = DirAccess.open(path)
	
	if dir == null:
		if dir_remove_contents_options.safe_returns:
			return true
		
		_log_error(dir_remove_contents, "The directory could not be created!")
		return false
	
	dir.list_dir_begin()
	
	var current_name: String = dir.get_next()
	var results: Array[bool]
	
	while not current_name.is_empty():
		var current_path: Path = Path.new(path, options).join(current_name)
		
		if current_path.is_dir and not dir_remove_contents_options.skip_dirs:
			results.append(current_path.remove(
				dir_remove_contents_options.send_to_trash, not dir_remove_contents_options.safe_returns
				))
		
		elif current_path.is_file and not dir_remove_contents_options.skip_files:
			results.append(current_path.remove(
				dir_remove_contents_options.send_to_trash, not dir_remove_contents_options.safe_returns
				))
		
		current_name = dir.get_next()
	
	if dir_remove_contents_options.safe_returns:
		return OK
	
	return results.all(func(result: bool) -> bool: return result)
#endregion

#region Private Methods
func _log_error(callback: Callable, message: String) -> void:
	if options.logging_errors_enabled:
		match options.logging_type:
			PathOptions.LoggingType.INTERNAL when not Engine.is_editor_hint():
				Log.error(callback, message)
			
			_:
				push_error("%s: %s" % [callback.get_method(), message])


func _log_warning(callback: Callable, message: String) -> void:
	if options.logging_warnings_enabled:
		match options.logging_type:
			PathOptions.LoggingType.INTERNAL when not Engine.is_editor_hint():
				Log.warning(callback, message)
			
			_:
				push_warning("%s: %s" % [callback.get_method(), message])


func _log_success(callback: Callable, message: String) -> void:
	if options.logging_successes_enabled:
		match options.logging_type:
			PathOptions.LoggingType.INTERNAL when not Engine.is_editor_hint():
				Log.success(callback, message)
			
			_:
				print("%s: %s" % [callback.get_method(), message])
#endregion

#region Static Methods
static func new_from_path(other_path: Path, options_arg: PathOptions = null) -> Path:
	return Path.new(other_path.path, options_arg)


static func new_user_data_dir(options_arg: PathOptions = null) -> Path:
	return Path.new(OS.get_user_data_dir(), options_arg)


static func new_temp_dir(options_arg: PathOptions = null) -> Path:
	return Path.new(get_temp_dir_path(), options_arg)


static func new_from_file_steam(file_stream: FileAccess, options_arg: PathOptions = null) -> Path:
	return Path.new(file_stream.get_path() if file_stream != null else "", options_arg)


static func get_sorted_by_modified_time(paths: Array[Path], asc: bool = true) -> Array[Path]:
	paths.sort_custom(func(path_1: Path, path_2: Path) -> bool:
		return path_1.modified_time > path_2.modified_time if asc else path_1.modified_time < path_2.modified_time
	)
	
	return paths


static func get_temp_dir_path() -> String:
	for temp_environment: String in PackedStringArray(["TMP", "TEMP"]):
		if OS.has_environment(temp_environment):
			return OS.get_environment(temp_environment)
	
	return ""


static func get_executable_dir_path() -> String:
	return ProjectSettings.globalize_path("res://") if OS.is_debug_build() else OS.get_executable_path().get_base_dir()


static func get_executable_file_path() -> String:
	return (
		ProjectSettings.globalize_path("res://").path_join("project.godot") if OS.is_debug_build()
		else OS.get_executable_path()
	)


static func get_pack_file_path() -> String:
	return OS.get_executable_path().replace(".exe", ".pck") if not OS.is_debug_build() else ""


static func open_externally(file_path: String) -> Error:
	var error_code: Error = OS.shell_open(file_path)
	
	if error_code != OK:
		Log.error(open_externally, "File at path: '%s' could not be opened externally!" % file_path)
	
	return error_code
#endregion

#region Setter Methods
func _set_path(arg: String) -> void:
	path = arg.strip_edges().strip_escapes().replace("/", "\\")
	type = Type.DIR if path.get_extension().is_empty() else Type.FILE


func _set_type(arg: Type) -> void:
	type = arg
	
	is_dir = type == Type.DIR
	is_file = type == Type.FILE
	is_valid = type != Type.NONE
	
	if is_dir:
		if options != null and options.dir_create_if_not_exists:
			if exists():
				_log_success(_set_type, "File exists at path: '%s'." % path)
				return
			
			var error_code: int = DirAccess.make_dir_recursive_absolute(path)
			
			if error_code != OK:
				_log_error(
					_set_type,
					"The directory could not be created at path: '%s'! Error: %s" % [
						path, error_string(error_code)
						]
					)
				return
			
			_log_success(_set_type, "Directory created at path: '%s'." % path)
	
	else:
		if options != null and options.file_create_if_not_exists:
			if exists():
				_log_success(_set_type, "File exists at path: '%s'." % path)
				return
			
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			
			if file == null:
				_log_error(
					_set_type,
					"The file could not be created at path: '%s'! Error: %s" % [
						path, FileAccess.get_open_error()
						]
					)
				return
			
			_log_success(_set_type, "File created at path: '%s'." % path)
#endregion

#region Getter Methods
func _get_modified_time() -> int:
	return FileAccess.get_modified_time(path)
#endregion
