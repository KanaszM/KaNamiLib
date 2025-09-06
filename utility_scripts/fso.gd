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


static func open_externally(file_path: String) -> Error:
	return OS.shell_open(file_path)
