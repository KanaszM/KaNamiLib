@tool
extends EditorScript


func _run() -> void:
	var root_dir: String = "res://resources"
	var dir: DirAccess = DirAccess.open(root_dir)
	
	if dir == null:
		var dir_open_error: String = error_string(DirAccess.get_open_error())
		
		push_error("Could not open the dir at path: '%s'! %s" % [root_dir, dir_open_error])
		
		return
	
	dir.list_dir_begin()
	
	var results: Array[_Result]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if dir.current_is_dir():
			var element_path: String = root_dir.path_join(current_element)
			
			results.append(_process_current_element(current_element, element_path))
		
		current_element = dir.get_next()
	
	dir.list_dir_end()
	
	if results.is_empty():
		push_warning("No resources could be detected from root dir: '%s'." % root_dir)
		return
	
	var result_lines: PackedStringArray = PackedStringArray(
		results.map(func(result: _Result) -> String: return str(result))
		)
	
	var final_result: String = "class_name Resources\n%s" % "\n".join(result_lines)
	
	DisplayServer.clipboard_set(final_result)
	
	print("\"Resources\" script contents copied.")


func _process_current_element(element: String, element_path: String) -> _Result:
	var result: _Result = _Result.new()
	var dir: DirAccess = DirAccess.open(element_path)
	
	if dir == null:
		var dir_open_error: String = error_string(DirAccess.get_open_error())
		
		push_error("Could not open the dir at path: '%s'! %s" % [element_path, dir_open_error])
		
		return
	
	result.category_name = element
	
	dir.list_dir_begin()
	
	var current_sub_element: String = dir.get_next()
	var ignored_extensions: PackedStringArray = PackedStringArray(["import", "uid"])
	
	while not current_sub_element.is_empty():
		if not dir.current_is_dir():
			var sub_element_path: String = element_path.path_join(current_sub_element)
			var sub_element_extension: String = sub_element_path.get_extension()
			
			if not sub_element_extension in ignored_extensions:
				var resource: Resource = load(sub_element_path)
				
				if resource == null:
					push_error("Could not load the resource at path: '%s'!" % sub_element_path)
				
				else:
					var sub_element_name: String = sub_element_path.get_file().get_slice(".", 0)
					
					var resource_name: String = sub_element_name.to_upper()
					var resource_class: String = resource.get_class()
					var resource_uid: String = UtilsResource.get_uid(resource)
					
					if resource_uid.is_empty():
						push_error("Could not detect the UID of resource at path: '%s'!" % sub_element_path)
					
					else:
						var resource_line: String = "const %s: %s = preload(\"%s\")" % [
							resource_name, resource_class, resource_uid
							]
						
						result.resource_lines.append(resource_line)
		
		current_sub_element = dir.get_next()
	
	dir.list_dir_end()
	
	return result


class _Result:
	var category_name: String
	var resource_lines: PackedStringArray
	
	func _to_string() -> String:
		return "\n#region %s\n%s\n#endregion" % [category_name.capitalize(), "\n".join(resource_lines)]
