class_name UtilsFSO


static func get_sorted_by_modified_time(paths: Array[String], asc: bool = true) -> Array[String]:
	paths.sort_custom(func(path_1: String, path_2: String) -> bool:
		var path_1_modified_time: int = FileAccess.get_modified_time(path_1)
		var path_2_modified_time: int = FileAccess.get_modified_time(path_2)
		
		return path_1_modified_time > path_2_modified_time if asc else path_1_modified_time < path_2_modified_time
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


static func get_validated_file_path(file_path: String, expected_file_extension: String) -> String:
	var validated_file_name: String = get_validated_file_name(get_file_name_from_path(file_path))
	
	if validated_file_name.is_empty():
		return ""
	
	var file_extension: String = file_path.get_extension()
	
	if file_extension != expected_file_extension:
		Log.error(
			"Invalid extension: '%s' for file at path: '%s'! Must be: '%s'." % [
				file_extension, file_path, expected_file_extension
				],
			get_validated_file_path
			)
		return ""
	
	return file_path.get_base_dir().path_join("%s.%s" % [validated_file_name, file_extension])


static func open_externally(file_path: String) -> Error:
	return OS.shell_open(file_path)


static func get_file_contents(path: String, skip_empty_rows: bool = true) -> PackedStringArray:
	var contents: PackedStringArray
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		Log.error(
			"File at path: '%s', could not be read! %s" % [path, error_string(FileAccess.get_open_error())],
			get_file_contents
			)
		return contents
	
	var current_line: String
	
	while not file.eof_reached():
		current_line = file.get_line()
		
		if current_line.is_empty() and skip_empty_rows:
			continue
		
		contents.append(current_line)
	
	file.close()
	
	return contents


static func get_file_csv_contents(
	path: String, skip_empty_rows: bool = true, csv_delimiter: String = ","
	) -> Array[PackedStringArray]:
		var contents: Array[PackedStringArray]
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		
		if file == null:
			Log.error(
				"File at path: '%s', could not be read! %s" % [path, error_string(FileAccess.get_open_error())],
				get_file_csv_contents
				)
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
					Log.error(
						"Invalid file extension: '%s'! Must be either 'csv' or 'tsv'." % file_extension,
						get_file_csv_contents
						)
					return contents
			
			if current_line.is_empty() and skip_empty_rows:
				continue
			
			contents.append(current_line)
		
		file.close()
		
		return contents


static func get_file_name_from_path(file_path: String) -> String:
	return file_path.get_file().trim_suffix(file_path.get_extension()).replace(".", "")


static func get_validated_file_name(file_name: String) -> String:
	file_name = file_name.strip_edges().replace(" ", "_").replace("-", "_").replace(".", "")
	file_name = file_name.validate_filename()
	
	if not file_name.is_valid_filename():
		Log.error("Invalid file name: '%s'!" % file_name, get_validated_file_name)
		return ""
	
	return file_name


static func file_exists_at_path(file_path: String) -> bool:
	return FileAccess.file_exists(file_path.strip_edges())


static func dir_exists_at_path(dir_path: String) -> bool:
	return DirAccess.dir_exists_absolute(dir_path.strip_edges())


static func list_dir(
	path: String,
	allow_files: bool = true,
	allow_dirs: bool = false,
	recursive: bool = false,
	limit: int = 0,
	include_file_extensions: PackedStringArray = PackedStringArray([]),
	exclude_file_extensions: PackedStringArray = PackedStringArray([]),
	exclude_file_names: PackedStringArray = PackedStringArray([]),
	exclude_dir_names: PackedStringArray = PackedStringArray([]),
	) -> PackedStringArray:
		var paths: PackedStringArray
		var dir: DirAccess = DirAccess.open(path)
		
		if dir == null:
			Log.error(
				"Dir at path: '%s', could not be opened! %s" % [path, error_string(DirAccess.get_open_error())],
				list_dir
				)
			return paths
		
		dir.list_dir_begin()
		
		var current_element: String = dir.get_next()
		
		while not current_element.is_empty():
			var current_path: String = path.path_join(current_element)
			var current_path_is_valid: bool = true
			
			if dir.current_is_dir():
				if not allow_dirs:
					current_path_is_valid = false
				
				if current_element in exclude_dir_names:
					current_path_is_valid = false
				
				else:
					if recursive:
						paths.append_array(list_dir(
							current_path, allow_files, allow_dirs, recursive, limit,
							include_file_extensions, exclude_file_extensions, exclude_file_names, exclude_dir_names
							))
			
			else:
				if not allow_files:
					current_path_is_valid = false
				
				else:
					var current_path_extension: String = current_path.get_extension()
					
					if not include_file_extensions.is_empty():
						if current_path_extension not in include_file_extensions:
							current_path_is_valid = false
					
					if current_path_extension in exclude_file_extensions:
						current_path_is_valid = false
					
					if not exclude_file_names.is_empty():
						if get_file_name_from_path(current_path) in exclude_file_names:
							current_path_is_valid = false
			
			if current_path_is_valid:
				paths.append(current_path)
				
				if limit > 0 and paths.size() >= 0:
					return paths.slice(0, limit)
			
			current_element = dir.get_next()
		
		return paths
