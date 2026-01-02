@tool
extends EditorScript

#region Constants
const ROOT_DIR: String = "res://resources"
const METHOD_GET_CUSTOM_CLASS_NAME: StringName = &"_get_class"
const IGNORED_EXTENSIONS: Array[String] = ["import", "uid"]
const NON_UID_EXTENSTIONS: Array[String] = ["png", "svg"]
#endregion

#region Main Method
func _run() -> void:
	var dir: DirAccess = DirAccess.open(ROOT_DIR)
	
	if dir == null:
		push_error("Could not open the dir at path: '%s'! %s" % [ROOT_DIR, error_string(DirAccess.get_open_error())])
		return
	
	dir.list_dir_begin()
	
	var results: Array[_Result]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if dir.current_is_dir():
			results.append(_process_current_element(current_element, ROOT_DIR.path_join(current_element)))
		
		current_element = dir.get_next()
	
	dir.list_dir_end()
	
	if results.is_empty():
		push_warning("No resources could be detected from root dir: '%s'." % ROOT_DIR)
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
		push_error(
			"Could not open the dir at path: '%s'! %s" % [element_path, error_string(DirAccess.get_open_error())]
			)
		return
	
	result.category_name = element
	
	dir.list_dir_begin()
	
	var current_sub_element: String = dir.get_next()
	
	while not current_sub_element.is_empty():
		if not dir.current_is_dir():
			var sub_element_path: String = element_path.path_join(current_sub_element)
			var sub_element_extension: String = sub_element_path.get_extension()
			
			if not sub_element_extension in IGNORED_EXTENSIONS:
				var resource: Resource = load(sub_element_path)
				
				if resource == null:
					push_error("Could not load the resource at path: '%s'!" % sub_element_path)
				
				else:
					var sub_element_name: String = sub_element_path.get_file().get_slice(".", 0)
					var resource_name: String = sub_element_name.to_upper()
					var resource_class: String
					var resource_path: String
					
					if resource.has_method(METHOD_GET_CUSTOM_CLASS_NAME):
						resource_class = UtilsScript.get_gd_script_from_object(resource).get_global_name()
					
					else:
						resource_class = resource.get_class()
					
					if sub_element_extension in NON_UID_EXTENSTIONS:
						resource_path = resource.resource_path
					
					else:
						resource_path = UtilsResource.get_uid(resource)
					
					if resource_path.is_empty():
						push_error("Could not detect the UID of resource at path: '%s'!" % sub_element_path)
					
					else:
						var resource_line: String = "const %s: %s = preload(\"%s\")" % [
							resource_name, resource_class, resource_path
							]
						
						result.resource_lines.append(resource_line)
		
		current_sub_element = dir.get_next()
	
	dir.list_dir_end()
	
	return result
#endregion

#region SubClasses
class _Result:
	#region Public Variables
	var category_name: String
	var resource_lines: PackedStringArray
	#endregion
	
	#region Virtual Methods
	func _to_string() -> String:
		return "\n#region %s\n%s\n#endregion" % [category_name.capitalize(), "\n".join(resource_lines)]
	#endregion
#endregion
