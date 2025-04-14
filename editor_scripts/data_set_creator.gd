@tool
extends EditorScript

#region Virtual Methods
func _run() -> void:
	var dir_path: String = "res://common/editor_scripts/"
	var properties: Array[DataSetProperty] = [
		DataSetPropertyArray.new("test_array"),
		DataSetPropertyBool.new("test_bool"),
		DataSetPropertyFloat.new("test_float"),
		DataSetPropertyInt.new("test_int"),
		DataSetPropertyString.new("test_string"),
	]
	
	var options: DataSetGeneratorOptions = DataSetGeneratorOptions.new()
	
	options.type = DataSetGeneratorOptions.Type.RESOURCE
	options.file_name = "data"
	options.custom_class_name = "TestData"
	options.custom_signal_name = "value_changed"
	options.export_dir_path = "user://"
	options.export_file_name = "data"
	options.export_json_extension = "json"
	options.export_compressed_extension = "dat"
	
	var generator: DataSetGenerator = DataSetGenerator.new(dir_path, properties, options)
	
	generator.make()
	#generator.remove()
	
	#var test_data: TestData = TestData.new()
	#print(test_data.to_dict())
	#test_data.save_to_config_file()
	#test_data.load_from_config_file()
	#print(test_data.to_dict())
	#print("> ", test_data._config_parse_error_text)
#endregion
