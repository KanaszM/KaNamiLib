@tool
extends EditorScript

#region Constants
const VALID_EXTENSIONS: Array[String] = ["tscn", "tres"]
const DEFAULT_ROOT_DIR_PATH: String = "res://"
#endregion

#region Private Variables
var _file_paths: PackedStringArray
#endregion

#region Constructor
func _run() -> void:
	_file_paths.clear()
	
	_add_files()
	
	for file_path: String in _file_paths:
		var resource: Resource = load(file_path)
		
		print("%s | %s" % [resource, file_path])
		
		ResourceSaver.save(resource)
#endregion

#region Private Methods
func _add_files(root_dir_path: String = DEFAULT_ROOT_DIR_PATH) -> void:
	for file_path: String in DirAccess.get_files_at(root_dir_path):
		if file_path.get_extension() in VALID_EXTENSIONS:
			_file_paths.append(root_dir_path.path_join(file_path))
	
	for dir_path: String in DirAccess.get_directories_at(root_dir_path):
		_add_files(root_dir_path.path_join(dir_path))
#endregion
