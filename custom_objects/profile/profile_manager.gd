class_name ProfileManager

#region Constants
const ROOT_DIR_NAME: String = "saves"
const FILE_EXTENSION: String = "sav"
const PASSWORD: String = "congratsyoureverseengineeredmysupersecretpasswordgoaheadandgrabyourselfamedalyouprick"
const VALUE_DIVIDER: String = "|"
#endregion

#region Public Static Variables
static var extended_base_profile_uid_path: String
static var encrypted: bool = false
#endregion

#region Static Public Methods
static func save_profile(file_name: String, profile: ProfileBase) -> bool:
	return save_profile_at_path(_get_complete_file_path(file_name), profile)


static func save_profile_at_path(file_path: String, profile: ProfileBase, overwrite: bool = true) -> bool:
	Log.info("Saving profile: '%s', at path: '%s'..." % [profile, file_path], save_profile_at_path)
	
	var dir: DirAccess = _open_root_path()
	
	if dir == null:
		return false
	
	if not overwrite and _file_exists_at_path(file_path):
		Log.warning(
			"File already exists at path: '%s' and overwrite is set to `false`. Skipping..." % file_path, 
			save_profile_at_path
			)
		return false
	
	var file: FileAccess
	
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, PASSWORD)
	
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		Log.error("Could not write the profile file at path: '%s'! %s" % [
			file_path, error_string(FileAccess.get_open_error())
			],
			save_profile_at_path
		)
		return false
	
	file.store_string(_serialize_profile(profile))
	file.flush()
	file.close()
	
	Log.success("Profile: '%s', saved successfully at path: '%s'." % [profile, file_path], save_profile_at_path)
	return true


static func load_profile(file_name: String, log_info_and_success: bool = true) -> ProfileBase:
	return load_profile_at_path(_get_complete_file_path(file_name), log_info_and_success)


static func load_profile_at_path(file_path: String, log_info_and_success: bool = true) -> ProfileBase:
	if log_info_and_success:
		Log.info("Loading profile at path: '%s'..." % file_path, load_profile_at_path)
	
	var file: FileAccess
	
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, PASSWORD)
	
	else:
		file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		Log.error("Could not read the profile file at path: '%s'! %s" % [
			file_path, error_string(FileAccess.get_open_error())
			],
			load_profile_at_path
		)
		return null
	
	var profile: ProfileBase = _deserialize_profile(file.get_as_text())
	
	if profile == null:
		return null
	
	file.close()
	
	if log_info_and_success:
		Log.success("Profile: '%s', loaded successfully at path: '%s'." % [profile, file_path], load_profile_at_path)
	
	return profile


static func get_profiles_dicts() -> Array[ProfileDict]:
	Log.info("Collecting profile dicts...", get_profiles_dicts)
	
	var root_dir_path: String = _get_root_dir_path()
	var dir: DirAccess = _open_root_path()
	
	if dir == null:
		return []
	
	dir.list_dir_begin()
	
	var profile_dicts: Array[ProfileDict]
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if not dir.current_is_dir():
			var element_path: String = root_dir_path.path_join(current_element)
			
			if _file_is_valid(element_path):
				var profile: ProfileBase = load_profile_at_path(element_path, false)
				
				if profile != null:
					var profile_dict: ProfileDict = ProfileDict.new()
					
					profile_dict.name = profile.profile_name
					profile_dict.path = element_path
					
					profile_dicts.append(profile_dict)
		
		current_element = dir.get_next()
	
	dir.list_dir_end()
	
	var profiles_count: int = profile_dicts.size()
	
	if profiles_count > 0:
		Log.success("Successfully collected: %d profile dicts." % profiles_count, get_profiles_dicts)
	
	else:
		Log.info("No profiles could be found.")
	
	return profile_dicts


static func get_profiles_count() -> int:
	var root_dir_path: String = _get_root_dir_path()
	var dir: DirAccess = _open_root_path()
	
	if dir == null:
		return 0
	
	dir.list_dir_begin()
	
	var profiles_count: int = 0
	var current_element: String = dir.get_next()
	
	while not current_element.is_empty():
		if not dir.current_is_dir():
			var element_path: String = root_dir_path.path_join(current_element)
			
			if _file_is_valid(element_path):
				profiles_count += 1
		
		current_element = dir.get_next()
	
	dir.list_dir_end()
	
	return profiles_count


static func create_new_profile(profile_name: String, unique: bool = true, custom_seed: String = "") -> ProfileBase:
	profile_name = profile_name.strip_edges()
	
	if profile_name.is_empty():
		Log.error("Name cannot be empty!", create_new_profile)
		return null
	
	var file_path: String = _get_complete_file_path(profile_name)
	
	if unique and _file_exists_at_path(file_path):
		Log.error("File already exists at path: '%s'!" % file_path, create_new_profile)
		return null
	
	var profile: ProfileBase = _create_new_extended_profile()
	
	if profile == null:
		return null
	
	Log.info("Creating a new profile with name: '%s'..." % profile_name, create_new_profile)
	
	profile.profile_name = profile_name
	profile.profile_seed = str(UUID.new()) if custom_seed.is_empty() else custom_seed
	
	if save_profile_at_path(file_path, profile) == null:
		return
	
	Log.success("Profile: '%s', created successfully at path: '%s'." % [profile, file_path], create_new_profile)
	return profile


static func remove_profile(file_name: String) -> bool:
	return remove_profile_at_path(_get_complete_file_path(file_name))


static func remove_profile_at_path(file_path: String) -> bool:
	Log.info("Removing profile at path: '%s'..." % file_path, remove_profile_at_path)
	
	if not FileAccess.file_exists(file_path):
		Log.error("Profile does not exist at path: '%s'!" % file_path, remove_profile_at_path)
		return false
	
	var error_code: Error = DirAccess.remove_absolute(file_path)
	
	if error_code != OK:
		Log.error(
			"Could not remove profile at path: '%s'! %s" % [file_path, error_string(error_code)],
			remove_profile_at_path
			)
		return false
	
	Log.success("Profile at path: '%s' was removed successfully." % file_path, remove_profile_at_path)
	return true


static func rename_profile(old_file_name: String, new_name: String) -> bool:
	return rename_profile_at_path(_get_complete_file_path(old_file_name), new_name)


static func rename_profile_at_path(old_file_path: String, new_name: String) -> bool:
	Log.info("Renaming profile at path: '%s'..." % old_file_path, rename_profile_at_path)
	
	new_name = new_name.strip_edges()
	
	if new_name.is_empty():
		Log.error("The new name cannot be empty!", rename_profile_at_path)
		return false
	
	var profile: ProfileBase = load_profile_at_path(old_file_path)
	
	if profile == null:
		return false
	
	if profile.profile_name == new_name:
		Log.warning(
			"The new name is the same as the existing one: '%s'." % profile.profile_name,
			rename_profile_at_path
			)
		return true
	
	var new_file_path: String = _get_complete_file_path(new_name)
	
	profile.profile_name = new_name
	
	if not save_profile_at_path(new_file_path, profile):
		return false
	
	Log.success("Profile at path: '%s' was renamed successfully." % new_file_path, rename_profile_at_path)
	
	var error_code: Error = DirAccess.remove_absolute(old_file_path)
	
	if error_code != OK:
		Log.error(
			"Could not remove the old file at path: '%s'! %s" % [old_file_path, error_string(error_code)],
			rename_profile_at_path
			)
	
	return true
#endregion

#region Static Private Methods
static func _serialize_profile(profile: ProfileBase) -> String:
	var initial_properties: Dictionary[StringName, Variant] = UtilsObject.get_properties(profile)
	var profile_properties: Dictionary[StringName, Variant]
	
	for property: StringName in initial_properties:
		var value: Variant = initial_properties[property]
		var value_type: int = typeof(value)
		
		match value_type:
			TYPE_COLOR:
				value = "%s%s%s%s%s%s%s" % [
					value.r, VALUE_DIVIDER, value.g, VALUE_DIVIDER, value.b, VALUE_DIVIDER, value.a
					]
			
			TYPE_VECTOR2:
				value = "%s%s%s" % [value.x, VALUE_DIVIDER, value.y]
			
			TYPE_VECTOR3:
				value = "%s%s%s%s" % [value.x, VALUE_DIVIDER, value.y, VALUE_DIVIDER, value.z]
		
		profile_properties[property] = value
	
	return JSON.stringify(profile_properties, "", false, true)


static func _deserialize_profile(serialized_profile: String) -> ProfileBase:
	var parsed_profile: Variant = JSON.parse_string(serialized_profile)
	
	if parsed_profile == null:
		Log.error("Parse failed!", _deserialize_profile)
		return null
	
	var parsed_profile_type: int = typeof(parsed_profile)
	
	if parsed_profile_type != TYPE_DICTIONARY:
		Log.error(
			"Invalid type of the deserialized profile: '%s'! It's not a dictionary." % type_string(parsed_profile_type),
			_deserialize_profile
			)
		return null
	
	var parsed_profile_typed := Dictionary(
		parsed_profile, TYPE_STRING, &"", null, TYPE_NIL, &"", null
		) as Dictionary[String, Variant]
	
	var profile: ProfileBase = _create_new_extended_profile()
	
	if profile == null:
		return
	
	if parsed_profile_typed.is_empty():
		return profile
	
	for property: String in parsed_profile_typed:
		var initial_property_type: int = typeof(profile.get(property))
		var value: Variant = parsed_profile_typed[property]
		
		match initial_property_type:
			TYPE_COLOR:
				
				var value_split: PackedStringArray = str(value).split(VALUE_DIVIDER)
				
				if value_split.size() < 4:
					Log.error("Invalid Color value: '%s'!" % value, _deserialize_profile)
					continue
				
				value = Color(
					float(value_split[0]), float(value_split[1]), float(value_split[2]), float(value_split[3])
					)
			
			TYPE_VECTOR2:
				var value_split: PackedStringArray = str(value).split(VALUE_DIVIDER)
				
				if value_split.size() < 2:
					Log.error("Invalid Vector2 value: '%s'!" % value, _deserialize_profile)
					continue
				
				value = Vector2(float(value_split[0]), float(value_split[1]))
			
			TYPE_VECTOR3:
				var value_split: PackedStringArray = str(value).split(VALUE_DIVIDER)
				
				if value_split.size() < 3:
					Log.error("Invalid Vector3 value: '%s'!" % value, _deserialize_profile)
					continue
				
				value = Vector3(float(value_split[0]), float(value_split[1]), float(value_split[2]))
		
		profile.set(property, value)
	
	return profile


static func _get_root_dir_path() -> String:
	return OS.get_user_data_dir().path_join(ROOT_DIR_NAME)


static func _get_validated_file_name(file_name: String) -> String:
	return file_name.to_lower().replace(" ", "_").replace("-", "_").replace(".", "").validate_filename()


static func _get_complete_file_name(file_name: String) -> String:
	return "%s.%s" % [_get_validated_file_name(file_name), FILE_EXTENSION]


static func _get_complete_file_path(file_name: String) -> String:
	return _get_root_dir_path().path_join(_get_complete_file_name(file_name))


static func _file_is_valid(file_path: String) -> bool:
	var file_name: String = file_path.get_file()
	var result: bool = file_name.get_extension() == FILE_EXTENSION
	
	if not result:
		Log.warning(
			"Invalid profile file at path: '%s'. It must have the extension: '%s'." % [file_path, FILE_EXTENSION],
			_file_is_valid
			)
	
	return result


static func _file_exists(file_name: String) -> bool:
	return _file_exists_at_path(_get_complete_file_path(file_name))


static func _file_exists_at_path(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)


static func _open_root_path() -> DirAccess:
	var root_dir_path: String = _get_root_dir_path()
	
	if not DirAccess.dir_exists_absolute(root_dir_path):
		Log.warning(
			"Root profile dir does not exist at path: '%s'. Creating a new one..." % root_dir_path,
			_open_root_path
			)
		
		var error_code: Error = DirAccess.make_dir_absolute(root_dir_path)
		
		if error_code != OK:
			Log.error(
				"Could not create the root profiles dir at path: '%s'! %s" % [
					root_dir_path, error_string(error_code)
					],
				_open_root_path
				)
			return null
		
		Log.success("Root profile dir created successfully at path: '%s'." % root_dir_path, _open_root_path)
	
	var dir: DirAccess = DirAccess.open(root_dir_path)
	
	if dir == null:
		var dir_open_error: String = error_string(DirAccess.get_open_error())
		
		Log.error(
			"Could not open the root profiles dir at path: '%s'! %s" % [root_dir_path, dir_open_error],
			_open_root_path
			)
		
		return null
	
	return dir


static func _create_new_extended_profile() -> ProfileBase:
	var extended_profile: Resource = load(extended_base_profile_uid_path)
	
	if extended_profile == null:
		Log.error(
			"Could not load the extended profile resource at path: '%s'!" % extended_base_profile_uid_path,
			_create_new_extended_profile
			)
		return null
	
	var extended_profile_script := extended_profile as GDScript
	
	if not extended_profile_script.can_instantiate():
		Log.error(
			"The extended script at path: '%s', cannot be instantiated!" % extended_base_profile_uid_path,
			_create_new_extended_profile
			)
		return null
	
	var extended_profile_script_class_name: StringName = extended_profile_script.get_global_name()
	var expected_extended_profile_script_class_name: StringName = &"MainProfile"
	
	if extended_profile_script_class_name != expected_extended_profile_script_class_name:
		Log.error(
			"The extended script's class is invalid: '%s'! It must be: '%s'" % [
				extended_profile_script_class_name, expected_extended_profile_script_class_name
				],
			_create_new_extended_profile
			)
		return null
	
	return extended_profile_script.new() as ProfileBase
#endregion

#region SubClasses
class ProfileDict:
	#region Public Variables
	var name: String
	var path: String: set = _set_path
	var size: int
	var date: String
	#endregion
	
	#region Private Methods
	func _to_string() -> String:
		return "<ProfileDict[%s]>" % name
	#endregion
	
	#region Setter Methods
	func _set_path(arg: String) -> void:
		path = arg
		
		if path.is_empty():
			size = FileAccess.get_size(path)
			date = "N/A"
		
		else:
			size = FileAccess.get_size(path)
			date = DateTime.format_system_datetime(
				"yyyymmdd", "hhmmss", Time.get_datetime_dict_from_unix_time(FileAccess.get_modified_time(path))
				)
	#endregion
#endregion
