class_name SQLManager

#region Enums
enum FileOperationType {SAVE, LOAD, REMOVE}
#endregion

#region Constants
const DEFAULT_ROOT_DIR_NAME: String = "sql"
const DEFAULT_FILE_EXTENSION: String = "db"
#endregion

#region Signals
signal query_executed(result: SQLResult)
#endregion

#region Private Variables
var _connection: SQLite
var _root_dir_name: String
var _file_extension: String
var _active_file_path: String
#endregion

#region Virtual Methods
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE when is_instance_valid(self): close_connection()


func _init(root_dir_name: String = DEFAULT_ROOT_DIR_NAME, file_extension: String = DEFAULT_FILE_EXTENSION) -> void:
	set_root_dir_name(root_dir_name)
	set_file_extension(file_extension)


func _to_string() -> String:
	return "<SQLManager[%s]>" % get_opened_database_name()


func _get_class() -> String:
	return "SQLManager"
#endregion

#region Public Base Methods
func get_root_dir_name() -> String:
	return _root_dir_name


func set_root_dir_name(root_dir_name: String) -> SQLManager:
	_root_dir_name = root_dir_name.strip_edges()
	return self


func get_file_extension() -> String:
	return _file_extension


func set_file_extension(file_extension: String) -> SQLManager:
	_file_extension = file_extension.strip_edges()
	return self


func get_opened_database_path() -> String:
	return _active_file_path if connection_is_opened() else ""


func get_opened_database_name() -> String:
	return UtilsFSO.get_file_name_from_path(_active_file_path) if connection_is_opened() else ""


func get_last_connection_error_message() -> String:
	return _connection.error_message
#endregion

#region Public Connection Methods
func open_connection() -> bool:
	Log.info("Opening connection...", open_connection)
	
	if _connection != null:
		Log.warning("Already connected.", open_connection)
		return false
		
	_connection = SQLite.new()
	_connection.verbosity_level = SQLite.VerbosityLevel.QUIET
	_connection.path = ":memory:"
	
	if not _connection.open_db():
		Log.error("Could not connect! Error: %s." % _connection.error_message, open_connection)
		return false
	
	Log.success("Connected successfully.", open_connection)
	return true


func close_connection() -> bool:
	Log.info("Closing connection...", close_connection)
	
	if _connection == null:
		Log.error("No SQLite connection was established!", close_connection)
		return false
	
	if not _connection.close_db():
		Log.error("Could not disconnect! Error: %s." % _connection.error_message, close_connection)
		return false
	
	_connection = null
	_active_file_path = ""
	
	Log.success("Disconnected successfully.", close_connection)
	return true


func connection_is_opened() -> bool:
	return _connection != null
#endregion

#region Public File Operation Methods
func save_file_by_name(file_name: String) -> bool:
	return save_file_at_path(get_file_path_by_name(file_name))


func save_file_at_path(file_path: String) -> bool:
	return _execute_file_operation(file_path, FileOperationType.SAVE)


func load_file_by_name(file_name: String) -> bool:
	return load_file_at_path(get_file_path_by_name(file_name))


func load_file_at_path(file_path: String) -> bool:
	return _execute_file_operation(file_path, FileOperationType.LOAD)


func load_most_recently_modified_file() -> bool:
	var file: SQLManagerFile = get_most_recently_modified_file()
	
	return false if file == null else load_file_at_path(file.get_path())


func remove_file_by_name(file_name: String) -> bool:
	return remove_file_at_path(get_file_path_by_name(file_name))


func remove_file_at_path(file_path: String) -> bool:
	return _execute_file_operation(file_path, FileOperationType.REMOVE)


func remove_all_files_from_root_dir() -> bool:
	var files: Array[SQLManagerFile] = get_all_files()
	var files_removed_successfully_count: int = 0
	
	for database_file_data: SQLManagerFile in files:
		if remove_file_at_path(database_file_data.get_path()):
			files_removed_successfully_count += 1
	
	if files_removed_successfully_count != files.size():
		return false
	
	return true


func remove_all_files_and_root_dir() -> bool:
	if not remove_all_files_from_root_dir():
		return false
	
	var root_dir_path: String = get_root_dir_path()
	var error: Error = DirAccess.remove_absolute(root_dir_path)
	
	if error != Error.OK:
		Log.error(
			"Could not remove the root dir at path: '%s'! Error: %s" % [root_dir_path, error_string(error)],
			remove_all_files_and_root_dir
			)
		return false
	
	return true
#endregion

#region Public Query Execution Methods
func execute_query(query: SQLQuery) -> SQLResult:
	return _execute_query(query)


func execute_query_and_call(query: SQLQuery, callback: Callable) -> void:
	if _callback_is_valid(callback):
		callback.call(execute_query(query))


func execute_query_once_and_call_multiple(query: SQLQuery, callbacks: Array[Callable]) -> void:
	if _callbacks_are_valid(callbacks):
		var result: SQLResult = execute_query(query)
		
		for callback: Callable in callbacks:
			callback.call(result)


func execute_query_for_each_and_call_multiple(query: SQLQuery, callbacks: Array[Callable]) -> void:
	if _callbacks_are_valid(callbacks):
		for callback: Callable in callbacks:
			callback.call(execute_query(query))
#endregion

#region Public Manager File Methods
func get_file_by_name(file_name: String) -> SQLManagerFile:
	return get_file_at_path(get_file_path_by_name(file_name))


func get_file_at_path(file_path: String) -> SQLManagerFile:
	var validated_element_path: String = UtilsFSO.get_validated_file_path(file_path, _file_extension)
	
	return null if validated_element_path.is_empty() else SQLManagerFile.new(validated_element_path)


func get_most_recently_modified_file() -> SQLManagerFile:
	var files: Array[SQLManagerFile] = get_all_files()
	
	if files.is_empty():
		return null
	
	var func_sorter: Callable = func(a: SQLManagerFile, b: SQLManagerFile) -> bool:
		return a.get_modified_datetime() > b.get_modified_datetime()
	
	files.sort_custom(func_sorter)
	
	return files[0]


func get_all_files() -> Array[SQLManagerFile]:
	var dir: DirAccess = _open_root_dir_steam()
	
	if dir == null:
		return []
	
	dir.list_dir_begin()
	
	var root_dir_path: String = get_root_dir_path()
	var files: Array[SQLManagerFile]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if not dir.current_is_dir():
			var element_path: String = root_dir_path.path_join(current_element)
			var validated_element_path: String = UtilsFSO.get_validated_file_path(element_path, _file_extension)
			
			if not validated_element_path.is_empty():
				files.append(SQLManagerFile.new(validated_element_path))
		
		current_element = dir.get_next()
	
	dir.list_dir_end()
	
	return files
#endregion

#region Public Helper Methods
func get_root_dir_path() -> String:
	return OS.get_user_data_dir().path_join(_root_dir_name)


func get_file_path_by_name(file_name: String) -> String:
	var validated_file_name_with_extension: String = get_validated_file_name_with_extension(file_name)
	
	if validated_file_name_with_extension.is_empty():
		return ""
	
	return get_root_dir_path().path_join(validated_file_name_with_extension)


func get_validated_file_name_with_extension(file_name: String) -> String:
	var validated_file_name: String = UtilsFSO.get_validated_file_name(file_name)
	
	return "" if validated_file_name.is_empty() else "%s.%s" % [validated_file_name, _file_extension]


func file_exists_by_name(file_name: String) -> bool:
	return UtilsFSO.file_exists_at_path(get_file_path_by_name(file_name))
#endregion

#region Private Methods
func _execute_file_operation(file_path: String, file_operation_type: FileOperationType) -> bool:
	Log.info(
		"Executing file operation of type: '%s', at path: '%s'." % [
			UtilsDictionary.enum_to_str_capizalized(FileOperationType, file_operation_type), file_path
			],
		_execute_file_operation
		)
	
	if not connection_is_opened():
		Log.error("No connection was established!", _execute_file_operation)
		return false
	
	var dir: DirAccess = _open_root_dir_steam()
	
	if dir == null:
		return false
	
	var validated_file_path: String = UtilsFSO.get_validated_file_path(file_path, _file_extension)
	
	if validated_file_path.is_empty():
		Log.error("The provided file path: '%s', is invalid!" % file_path, _execute_file_operation)
		return false
	
	match file_operation_type:
		FileOperationType.LOAD:
			if not UtilsFSO.file_exists_at_path(validated_file_path):
				Log.error("File does not exist at path: '%s'!" % validated_file_path, _execute_file_operation)
				return false
			
			if not _connection.restore_from(validated_file_path):
				Log.error(
					"Could not load the file from path: '%s'! Error: %s." % [
						validated_file_path, _connection.error_message
						],
					_execute_file_operation
					)
				return false
			
			_active_file_path = validated_file_path
			
			Log.success("File loaded successfully from path: '%s'." % validated_file_path, _execute_file_operation)
		
		FileOperationType.SAVE:
			if not _connection.backup_to(validated_file_path):
				Log.error(
					"Could not save the file at path: '%s'! Error: %s." % [
						validated_file_path, _connection.error_message
						],
					_execute_file_operation
					)
				return false
			
			Log.success("File saved successfully at path: '%s'." % validated_file_path, _execute_file_operation)
		
		FileOperationType.REMOVE:
			if not UtilsFSO.file_exists_at_path(validated_file_path):
				Log.error("File does not exist at path: '%s'!" % validated_file_path, _execute_file_operation)
				return false
			
			if _active_file_path == validated_file_path:
				_active_file_path = ""
			
			var error: Error = DirAccess.remove_absolute(validated_file_path)
			
			if error != Error.OK:
				Log.error(
					"Could not remove the file at path: '%s'! Error: %s." % [validated_file_path, error_string(error)],
					_execute_file_operation
					)
				return false
			
			Log.success("File removed successfully from path: '%s'." % validated_file_path, _execute_file_operation)
	
	return true


func _execute_query(query: SQLQuery) -> SQLResult:
	var result: SQLResult = SQLResult.new()
	var func_on_result_failed: Callable = func(error_message: String) -> void:
		result.set_message(error_message)
		Log.error(error_message, _execute_query)
		query_executed.emit(result)
	
	if not connection_is_opened():
		func_on_result_failed.call("Not connected!")
		return result
	
	if query == null:
		func_on_result_failed.call("No query was provided!")
		return result
	
	var query_is_valid: bool = query.validate()
	
	if not query_is_valid:
		func_on_result_failed.call("The provided query: %s, is not valid!" % query)
		return result
	
	var query_definition: String = query.get_definition()
	
	if query_definition.is_empty():
		func_on_result_failed.call("Could not generate the definition for the provided query: %s!" % query)
		return result
	
	if not query_definition.ends_with(";"):
		query_definition += ";"
	
	Log.debug(query_definition, _execute_query)
	
	var query_executed_successfully: bool = _connection.query(query_definition)
	
	if not query_executed_successfully:
		func_on_result_failed.call(_connection.error_message)
		return result
	
	result.set_is_valid()
	
	var has_rows: bool
	
	match query.get_query_type():
		SQLQuery.QueryType.CUSTOM: has_rows = (query as SQLQueryCustom).get_definition().begins_with("SELECT")
		SQLQuery.QueryType.SELECT: has_rows = true
	
	if has_rows:
		for raw_data: Dictionary in _connection.query_result:
			result.append_row(SQLResultRow.new(raw_data, query))
	
	query_executed.emit(result)
	return result


func _open_root_dir_steam() -> DirAccess:
	var root_dir_path: String = get_root_dir_path()
	
	if not DirAccess.dir_exists_absolute(root_dir_path):
		Log.warning(
			"Root dir does not exist at path: '%s'. Creating a new one..." % root_dir_path, _open_root_dir_steam
			)
		
		var error_code: Error = DirAccess.make_dir_absolute(root_dir_path)
		
		if error_code != OK:
			Log.error(
				"Could not create the root dir at path: '%s'! Error: %s." % [root_dir_path, error_string(error_code)],
				_open_root_dir_steam
				)
			return null
		
		Log.success("Root dir created successfully at path: '%s'." % root_dir_path, _open_root_dir_steam)
	
	var dir: DirAccess = DirAccess.open(root_dir_path)
	
	if dir == null:
		var dir_open_error: String = error_string(DirAccess.get_open_error())
		
		Log.error(
			"Could not open the root dir at path: '%s'! Error: %s." % [root_dir_path, dir_open_error],
			_open_root_dir_steam
			)
		return null
	
	return dir


func _callback_is_valid(callback: Callable) -> bool:
	if not callback.is_valid():
		Log.error("The provided callback is not valid!", _callback_is_valid)
		return false
	
	if callback.get_argument_count() < 1:
		Log.error(
			"The provided callback: %s, must have at least one argument of type SQLResult!" % callback,
			_callback_is_valid
			)
		return false
	
	return true


func _callbacks_are_valid(callbacks: Array[Callable]) -> bool:
	var valid_callbacks_count: int = 0
	
	for callback: Callable in callbacks:
		if _callback_is_valid(callback):
			valid_callbacks_count += 1
	
	if valid_callbacks_count != callbacks.size():
		return false
	
	return true
#endregion
