class_name UtilsScript


static func get_gd_script_from_object(object: Object) -> GDScript:
	var script: Variant = object.get_script()
	
	if script == null or script is not Resource:
		return null
	
	return script as GDScript if script is GDScript else null


static func get_property_names_from_gd_script(
	origin: GDScript, property_names_to_ignore: Array[StringName] = []
	) -> Array[StringName]:
		var property_names: Array[StringName]
		
		for property_data: Dictionary in origin.get_script_property_list():
			var property_data_usage := property_data.get("usage", PROPERTY_USAGE_NONE) as PropertyUsageFlags
			var property_data_name := property_data.get("name", "") as String
			
			if property_data_usage in [PROPERTY_USAGE_GROUP, PROPERTY_USAGE_SUBGROUP, PROPERTY_USAGE_CATEGORY]:
				continue
			
			var property_name: StringName = StringName(property_data_name)
			
			if property_name in property_names_to_ignore:
				continue
			
			property_names.append(property_name)
		
		return property_names
