"""
# Version 1.1.1 (03-Apr-2025):
	- Added verification on initialization for duplicate property names;

# Version 1.1.0 (29-Mar-2025):
	- Separated the internal classes into their own files;
	- Added the new `DataSetPropertyArray` class;

# Version 1.0.0 (28-Mar-2025):
	- Initial release;
"""

#@tool
class_name DataSetGenerator
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var properties: Array[DataSetProperty]
var options: DataSetGeneratorOptions
var file_path: String
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(
	dir_path_arg: String, properties_arg: Array[DataSetProperty], options_arg: DataSetGeneratorOptions = null,
	) -> void:
		assert(not dir_path_arg.is_empty(), "The dir path cannot be empty!")
		assert(DirAccess.dir_exists_absolute(dir_path_arg), "The dir at path: '%s' does not exist!" % dir_path_arg)
		assert(not properties_arg.is_empty(), "The properties array cannot be empty!")
		
		properties = properties_arg.filter(
			func(property: DataSetProperty) -> bool: return property.is_valid
			) as Array[DataSetProperty]
		
		if options_arg == null:
			options = DataSetGeneratorOptions.new()
		
		else:
			options = options_arg
		
		file_path = dir_path_arg.path_join("%s.gd" % options.file_name)
		
		var unique_properties: Collection = Collection.new()
		
		for property: DataSetProperty in properties:
			assert(not unique_properties.has(property.name), "Duplicate property: %s!" % property)
			
			unique_properties.add(property.name)
#endregion

#region Public Methods
func make() -> Error:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		return FileAccess.get_open_error()
	
	var header_contents: PackedStringArray = _generate_header_contents()
	var properties_contents: Array[PackedStringArray] = _generate_properties_contents()
	var private_variables_contents: PackedStringArray = _generate_private_variables_contents()
	var public_methods_contents: PackedStringArray = _generate_public_methods_contents()
	var private_methods_contents: PackedStringArray = _generate_private_methods_contents()
	var signatures_contents: PackedStringArray = properties_contents[0]
	var variables_contents: PackedStringArray = properties_contents[1]
	var helper_methods_contents: PackedStringArray = properties_contents[2]
	var setter_methods_contents: PackedStringArray = properties_contents[3]
	
	for line: String in (
		signatures_contents +
		header_contents +
		variables_contents +
		private_variables_contents +
		public_methods_contents +
		helper_methods_contents +
		private_methods_contents +
		setter_methods_contents
		):
			file.store_line(line)
	
	file.close()
	
	return OK


func remove() -> Error:
	return DirAccess.remove_absolute(file_path)
#endregion

#region Private Methods
func _generate_header_contents() -> PackedStringArray:
	var contents: PackedStringArray
	
	var file_class_name: String = options.get_class_name()
	var file_class_extends: String = options.get_class_extends()
	
	if not file_class_name.is_empty():
		contents.append("class_name %s" % file_class_name)
	
	if not file_class_extends.is_empty():
		contents.append("extends %s" % file_class_extends)
	
	if not file_class_name.is_empty() or not file_class_extends.is_empty():
		contents.append("")
	
	if options.type != DataSetGeneratorOptions.Type.RESOURCE:
		contents.append_array(PackedStringArray([
			"#region Signals",
			"signal %s" % options.get_changed_signal_name(),
			"#endregion",
			"",
			]))
	
	return contents


func _generate_properties_contents() -> Array[PackedStringArray]:
	var signatures_contents: PackedStringArray
	var variables_contents: PackedStringArray
	var helper_methods_contents: PackedStringArray
	var setter_methods_contents: PackedStringArray
	
	signatures_contents.append_array(PackedStringArray([
		"# ⚠️",
		"# ⚠️ This script is auto-generated. DO NOT EDIT.",
		"# ⚠️",
		"",
		"#SigStart",
		]))
	
	variables_contents.append("#region Public Variables")
	helper_methods_contents.append("#region Helper Methods")
	setter_methods_contents.append("#region Setter Methods")
	
	for property: DataSetProperty in properties:
		signatures_contents.append(property.get_signature_string())
		variables_contents.append(property.get_variable_string())
		helper_methods_contents.append_array(property.get_helper_methods_string_pack())
		setter_methods_contents.append(property.get_setter_string(options.get_changed_signal_name()))
	
	helper_methods_contents.resize(helper_methods_contents.size() - 2)
	setter_methods_contents[-1] = setter_methods_contents[-1].strip_edges(false)
	
	signatures_contents.append("#SigEnd\n")
	variables_contents.append("#endregion\n")
	helper_methods_contents.append("#endregion\n")
	setter_methods_contents.append("#endregion\n")
	
	return [signatures_contents, variables_contents, helper_methods_contents, setter_methods_contents]


func _generate_private_variables_contents() -> PackedStringArray:
	var contents: PackedStringArray
	
	contents.append_array(PackedStringArray([
		"#region Private Variables",
		"var _unmarshal_error_text: String",
		"var _json_parse_error_text: String",
		"var _config_parse_error_text: String",
		"#endregion\n"
		]))
	
	return contents


func _generate_private_methods_contents() -> PackedStringArray:
	var contents: PackedStringArray
	
	# Start:
	contents.append("#region Private Methods")
	
	#region _set_property
	contents.append_array(PackedStringArray([
		"func _set_property(property_arg: String, value_arg: Variant) -> String:",
		"\tvar property_type: int = typeof(property_arg)",
		"\tif property_type != TYPE_STRING:",
		"\t\treturn (",
		"\t\t\t'Invalid type: %s, for property name: %s'",
		"\t\t\t% [type_string(property_type), property_arg]",
		"\t\t\t)",
		"\tvar value_type_b: int = typeof(get(property_arg))",
		"\tvar value_type_a: int = typeof(value_arg)",
		"\tif value_type_b != value_type_a:",
		"\t\treturn (",
		"\t\t\t'Mismatched value types on property: %s [B: %s] [A: %s]'",
		"\t\t\t% [property_arg, type_string(value_type_b), type_string(value_type_a)]",
		"\t\t\t)",
		"\tset(property_arg, value_arg)",
		"\treturn ''",
		"",
		"",
	]))
	#endregion
	
	# End:
	contents.resize(contents.size() - 2)
	contents.append("#endregion\n")

	return contents


func _generate_public_methods_contents() -> PackedStringArray:
	var contents: PackedStringArray
	var export_json_file_path: String = options.get_export_json_file_path()
	var export_config_file_path: String = options.get_export_config_file_path()
	var export_compressed_file_path: String = options.get_export_compressed_file_path()
	var properties_size: int = properties.size()
	
	# Start:
	contents.append("#region Public Methods")
	
	#region marshal
	contents.append_array(PackedStringArray([
		"func marshal() -> PackedByteArray:",
		"\treturn var_to_bytes([",
		]))
	
	for property: DataSetProperty in properties:
		contents.append(
			"\t\t%s," % property.name
			)
	
	contents.append_array(PackedStringArray([
		"\t\t])",
		"",
		"",
		]))
	#endregion
	
	#region unmarshal
	contents.append_array(PackedStringArray([
		"func unmarshal(bytes: PackedByteArray) -> void:",
		"\tvar result: Variant = bytes_to_var(bytes)",
		"\tvar result_type: int = typeof(result)",
		"\t_unmarshal_error_text = \"\"",
		"\tif typeof(result) == TYPE_ARRAY:",
		"\t\tvar result_size: int = result.size()",
		"\t\tvar value_type_b: int",
		"\t\tvar value_type_a: int",
		"\t\tif result_size == %d:" % properties_size,
		"\t\t\tvar error_texts: PackedStringArray",
		]))
	
	for property_idx: int in properties_size:
		var property: DataSetProperty = properties[property_idx]
		
		contents.append_array(PackedStringArray([
			"\t\t\tvalue_type_b = typeof(%s)" % property.name,
			"\t\t\tvalue_type_a = typeof(result[%d])" % property_idx,
			"\t\t\tif value_type_b == value_type_a:",
			"\t\t\t\t%s = result[%d]" % [property.name, property_idx],
			"\t\t\telse:",
			"\t\t\t\terror_texts.append(",
			"\t\t\t\t\t\"Mismatched types on param with index: %s [B: %%s] [A: %%s]\"" % property_idx,
			"\t\t\t\t\t% [type_string(value_type_b), type_string(value_type_a)]",
			"\t\t\t\t\t)",
			]))
	
	contents.append_array(PackedStringArray([
		"\t\telse:",
		"\t\t\t_unmarshal_error_text = (",
		"\t\t\t\t\"Invalid result size: %%d / %d\" %% result_size" % properties_size,
		"\t\t\t\t)",
		"\telse:",
		"\t\t_unmarshal_error_text = \"Invalid result type: %s\" % type_string(result_type)",
		"",
		"",
		]))
	#endregion
	
	#region to_dict
	contents.append_array(PackedStringArray([
		"func to_dict() -> Dictionary[StringName, Variant]:",
		"\treturn {",
		]))
	
	for property: DataSetProperty in properties:
		contents.append(
			"\t\t&\"%s\": %s," % [property.name, property.name]
			)
	
	contents.append_array(PackedStringArray([
		"\t\t}",
		"",
		"",
		]))
	#endregion
	
	#region to_json
	contents.append_array(PackedStringArray([
		"func to_json() -> String:",
		"\treturn JSON.stringify(to_dict())",
		"",
		"",
		]))
	#endregion
	
	#region parse_json
	contents.append_array(PackedStringArray([
		"func parse_json(json_string: String) -> void:",
		"\tvar parsed_result: Variant = JSON.parse_string(json_string)",
		"\tvar parsed_result_type: int = typeof(parsed_result)",
		"\t_json_parse_error_text = ''",
		"\tif parsed_result_type == TYPE_DICTIONARY:",
		"\t\tvar parsed_json := parsed_result as Dictionary",
		"\t\tvar error_texts: PackedStringArray",
		"\t\tfor key: Variant in parsed_json:",
		"\t\t\tvar error_text: String = _set_property(key, parsed_json[key])",
		"\t\t\tif not error_text.is_empty():",
		"\t\t\t\terror_texts.append(error_text)",
		"\t\t\t\tcontinue",
		"\t\tif not error_texts.is_empty():",
		"\t\t\t_json_parse_error_text = ' | '.join(error_texts)",
		"\telse:",
		"\t\t_json_parse_error_text = 'Invalid parse result type: %s' % type_string(parsed_result_type)",
		"",
		"",
	]))
	#endregion
	
	#region save_to_compressed_file
	contents.append_array(PackedStringArray([
		"func save_to_compressed_file(path: String = \"%s\") -> Error:" % export_compressed_file_path,
		"\tvar file: FileAccess = FileAccess.open(path, FileAccess.WRITE)",
		"\tif file != null:",
		"\t\tfile.store_buffer(marshal())",
		"\treturn FileAccess.get_open_error()",
		"",
		"",
		]))
	#endregion
	
	#region save_to_json_file
	contents.append_array(PackedStringArray([
		"func save_to_json_file(path: String = \"%s\") -> Error:" % export_json_file_path,
		"\tvar file: FileAccess = FileAccess.open(path, FileAccess.WRITE)",
		"\tif file != null:",
		"\t\tfile.store_line(to_json())",
		"\treturn FileAccess.get_open_error()",
		"",
		"",
		]))
	#endregion
	
	#region save_to_config_file
	contents.append_array(PackedStringArray([
		"func save_to_config_file(path: String = '%s') -> Error:" % export_config_file_path,
		"\tvar config: ConfigFile = ConfigFile.new()",
		]))
	
	for property: DataSetProperty in properties:
		contents.append(
			"\tconfig.set_value('%s', '%s', %s)" % [options.export_file_name, property.name, property.name]
			)
	
	contents.append_array(PackedStringArray([
		"\treturn config.save(path)",
		"",
		"",
		]))
	#endregion
	
	#region load_from_compressed_file
	contents.append_array(PackedStringArray([
		"func load_from_compressed_file(path: String = \"%s\") -> Error:" % export_compressed_file_path,
		"\tvar file: FileAccess = FileAccess.open(path, FileAccess.READ)",
		"\tif file != null:",
		"\t\tunmarshal(file.get_buffer(file.get_length()))",
		"\treturn FileAccess.get_open_error()",
		"",
		"",
		]))
	#endregion
	
	#region load_from_json_file
	contents.append_array(PackedStringArray([
		"func load_from_json_file(path: String = \"%s\") -> Error:" % export_json_file_path,
		"\tvar file: FileAccess = FileAccess.open(path, FileAccess.READ)",
		"\tif file != null:",
		"\t\tparse_json(file.get_as_text())",
		"\treturn FileAccess.get_open_error()",
		"",
		"",
		]))
	#endregion
	
	#region load_from_config_file
	contents.append_array(PackedStringArray([
		"func load_from_config_file(path: String = '%s') -> void:" % export_config_file_path,
		"\tvar config: ConfigFile = ConfigFile.new()",
		"\tvar error_code: int = config.load(path)",
		"\t_config_parse_error_text = ''",
		"\tif error_code != OK:",
		"\t\t_config_parse_error_text = (",
		"\t\t\t\"Could not load config file at path: '%s'! Error: %s\"",
		"\t\t\t% [path, error_string(error_code)]",
		"\t\t\t)",
		"\t\treturn",
		"\tif not config.has_section('%s'):" % options.export_file_name,
		"\t\t_config_parse_error_text = \"Missing config file section: '%s'!\"" % options.export_file_name,
		"\t\treturn",
		"\tvar error_texts: PackedStringArray",
		"\tfor section_key: String in config.get_section_keys('%s'):" % options.export_file_name,
		"\t\tvar error_text: String = _set_property(",
		"\t\t\tsection_key, config.get_value('%s', section_key)" % options.export_file_name,
		"\t\t\t)",
		"\t\tif not error_text.is_empty():",
		"\t\t\terror_texts.append(error_text)",
		"\t\t\tcontinue",
		"\tif not error_texts.is_empty():",
		"\t\t_config_parse_error_text = ' | '.join(error_texts)",
		"",
		"",
	]))
	#endregion
	
	#region get_json_parse_error_text
	contents.append_array(PackedStringArray([
		"func get_json_parse_error_text() -> String:",
		"\treturn _json_parse_error_text",
		"",
		"",
		]))
	#endregion
	
	#region get_config_parse_error_text
	contents.append_array(PackedStringArray([
		"func get_config_parse_error_text() -> String:",
		"\treturn _config_parse_error_text",
		"",
		"",
		]))
	#endregion
	
	#region get_umarshal_error_text
	contents.append_array(PackedStringArray([
		"func get_unmarshal_error_text() -> String:",
		"\treturn _unmarshal_error_text",
		"",
		"",
		]))
	#endregion
	
	# End:
	contents.resize(contents.size() - 2)
	contents.append("#endregion\n")
	
	return contents
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
