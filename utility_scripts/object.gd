class_name UtilsObject


static func get_properties(
	object: Object,
	allow_other_objects: bool = false,
	allow_privates: bool = false,
	property_names_to_ignore: Array[StringName] = [],
	privates_prefix: String = "_",
	) -> Dictionary[StringName, Variant]:
		var script: GDScript = UtilsScript.get_gd_script_from_object(object)
		
		if script == null:
			return {}
		
		var properties_map: Dictionary[StringName, Variant]
		var property_names: Array[StringName] = UtilsScript.get_property_names_from_gd_script(
			script, property_names_to_ignore
			)
		
		for property_name: StringName in property_names:
			if property_name.is_empty():
				continue
			
			if property_name.begins_with(privates_prefix) and not allow_privates:
				continue
			
			var property_value: Variant = object.get(property_name)
			
			if property_value is Object and not allow_other_objects:
				continue
			
			if property_value is Array:
				var array_property_value: = property_value as Array
				
				if array_property_value.is_typed():
					if array_property_value.get_typed_builtin() == TYPE_OBJECT and not allow_other_objects:
						continue
			
			properties_map[property_name] = property_value
		
		return properties_map


static func get_property_names(object: Object, property_names_to_ignore: Array[StringName] = []) -> Array[StringName]:
	return UtilsScript.get_property_names_from_gd_script(
		UtilsScript.get_gd_script_from_object(object), property_names_to_ignore
		)


static func inject_properties(object: Object, properties_map: Dictionary[StringName, Variant]) -> void:
	if object == null:
		return
	
	for property: StringName in properties_map:
		if property in object:
			object.set(property, properties_map[property])


static func get_scene_path_from_reference(object: Object) -> String:
	if not object is Resource:
		return ""
	
	var script_path: String = (object as Resource).resource_path
	
	if not script_path.ends_with(".gd"):
		return ""
	
	script_path = script_path.replace(".gd", ".tscn")
	
	if not ResourceLoader.exists(script_path):
		return ""
	
	return script_path if ResourceLoader.exists(script_path) else ""


static func load_from_reference(object: Object) -> PackedScene:
	var scene_path: String = get_scene_path_from_reference(object)
	
	return null if scene_path.is_empty() else load(scene_path) as PackedScene


static func instantiate_from_reference(object: Object, args: Dictionary[StringName, Variant] = {}) -> Node:
	var pack: PackedScene = load_from_reference(object)
	
	if pack == null:
		return null
	
	var node: Node = pack.instantiate()
	
	if node == null:
		return null
	
	if not args.is_empty():
		inject_properties(node, args)
	
	return node


static func to_str(
	object: Object,
	properties_separator: String = "\n",
	assignment_separator: String = ": ",
	allow_other_objects: bool = true,
	allow_privates: bool = true,
	property_names_to_ignore: Array[StringName] = [],
	privates_prefix: String = "_",
	) -> String:
		var properties_map: Dictionary[StringName, Variant] = get_properties(
			object, allow_other_objects, allow_privates, property_names_to_ignore, privates_prefix
			)
		var property_pairs: PackedStringArray
		
		for property_name: StringName in properties_map:
			property_pairs.append("%s%s%s" % [property_name, assignment_separator, str(properties_map[property_name])])
		
		return properties_separator.join(property_pairs)
