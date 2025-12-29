class_name ConfigManager

#region Enums
enum UpdateMode {SAVE, LOAD}
#endregion

#region Constants
const FILE_NAME: String = "config"
const FILE_EXTENSION: String = "cfg"
const KEY_DELIMITER: String = "_"
#endregion

#region Public Static Methods
static func update_file(
	config: ConfigBase, mode: UpdateMode, enable_warnings: bool, enable_debug_messages: bool
	) -> bool:
		if config == null:
			Log.error("A 'ConfigBase' object is required!")
			return false
		
		var file_path: String = _get_complete_file_path()
		
		Log.info("Updating the config file from path: '%s'..." % file_path)
		
		if not FileAccess.file_exists(file_path):
			var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
			
			if file == null:
				Log.error(
					"Could not create a new config file at path: '%s'! %s" % [
						file_path, error_string(FileAccess.get_open_error())
						]
					)
				return false
		
		var config_file: ConfigFile = ConfigFile.new()
		var load_error_code: Error = config_file.load(file_path)
		
		if load_error_code != OK:
			Log.error(
				"Could not load the config file at path: '%s'! %s" % [file_path, error_string(load_error_code)]
				)
			return false
		
		var config_file_changed: bool
		var properties: Dictionary[StringName, Variant] = UtilsObject.get_properties(config)
		
		for property: StringName in properties:
			var property_splices: PackedStringArray = property.split(KEY_DELIMITER)
			var property_section: String = property_splices[0]
			var property_key: String = KEY_DELIMITER.join(property_splices.slice(1))
			
			var config_object_value: Variant = properties[property]
			
			if not config_file.has_section_key(property_section, property_key):
				if enable_warnings:
					Log.warning(
						"Missing section: [%s] and key: '%s'. Reseting..." % [property_section, property_key]
						)
				
				config_file.set_value(property_section, property_key, config_object_value)
				config_file_changed = true
				continue
			
			var config_file_value: Variant = config_file.get_value(property_section, property_key)
			
			if config_file_value == null:
				Log.error(
					"The retrieved config file key: '%s' at section: [%s] is null! Reseting..." % [
						property_section, property_key
						]
					)
				
				config_file.set_value(property_section, property_key, config_object_value)
				config_file_changed = true
				continue
			
			var config_object_value_type: int = typeof(config_object_value)
			var config_file_value_type: int = typeof(config_file_value)
			
			if config_object_value_type != config_file_value_type:
				Log.error(
					"Invalid config file value type: '%s' on key/section: '%s' [%s]! It must be: '%s'." % [
						type_string(config_file_value_type),
						property_key,
						property_section,
						type_string(config_object_value_type)
						]
					)
				continue
			
			if config_file_value != config_object_value:
				match mode:
					UpdateMode.LOAD:
						if enable_debug_messages:
							Log.debug(
								"Updating the object property: '%s' with the new file value: '%s'..." % [
									property, config_file_value
									]
								)
						
						config.set(property, config_file_value)
					
					UpdateMode.SAVE:
						if enable_debug_messages:
							Log.debug(
								"Updating the file key/section: '%s' [%s] with the new object value: '%s'..." % [
									property_key, property_section, config_object_value
									]
								)
						
						config_file.set_value(property_section, property_key, config_object_value)
						config_file_changed = true
		
		for section: String in config_file.get_sections():
			for key: String in config_file.get_section_keys(section):
				var config_file_property: StringName = StringName("%s%s%s" % [section, KEY_DELIMITER, key])
				
				if not config_file_property in properties and enable_warnings:
					Log.warning("Invalid key/section: '%s' [%s]. Not used." % [key, section])
		
		if config_file_changed:
			var save_error_code: Error = config_file.save(file_path)
			
			if save_error_code != OK:
				Log.error(
					"Could not save the config file at path: '%s'! %s" % [file_path, error_string(save_error_code)]
					)
				return false
		
		Log.success("Config file updated successfully at path: '%s'." % file_path)
		
		match mode:
			UpdateMode.SAVE: config.saved.emit()
			UpdateMode.LOAD: config.loaded.emit()
		
		config.updated.emit()
		return true


static func save_file(config: ConfigBase, enable_warnings: bool = false, enable_debug_messages: bool = false) -> bool:
	return update_file(config, UpdateMode.SAVE, enable_warnings, enable_debug_messages)


static func load_file(config: ConfigBase, enable_warnings: bool = false, enable_debug_messages: bool = false) -> bool:
	return update_file(config, UpdateMode.LOAD, enable_warnings, enable_debug_messages)
#endregion

#region Private Static Methods
static func _get_complete_file_name() -> String:
	return "%s.%s" % [FILE_NAME, FILE_EXTENSION]


static func _get_complete_file_path() -> String:
	return OS.get_user_data_dir().path_join(_get_complete_file_name())


static func _file_is_valid(file_name: String) -> bool:
	if not file_name.begins_with(FILE_NAME) or file_name.get_extension() != FILE_EXTENSION:
		Log.error(
			"Invalid file name: '%s'! It must begin with: '%s' and have the extension: '%s'." % [
				file_name, FILE_NAME, FILE_EXTENSION
				]
			)
		return false
	
	return true
#endregion
