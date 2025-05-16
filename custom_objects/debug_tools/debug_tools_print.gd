class_name DebugToolsPrint


static func print_variable(variable: Variant, name: String) -> void:
	print(get_variable_string(variable, name))


static func get_variable_string(variable: Variant, name: String) -> String:
	var variable_name: String = name.strip_edges()
	var variable_type: String = get_variable_type_string(variable)
	var variable_value: String = get_variable_value_string(variable)
	var variable_value_is_available: bool = not variable_value.is_empty()
	
	return "var %s: %s%s%s" % [
		variable_name,
		variable_type,
		" = " if variable_value_is_available else "",
		variable_value if variable_value_is_available else "",
		]


static func get_variable_type_string(variable: Variant) -> String:
	match typeof(variable):
		TYPE_ARRAY:
			var detected_types: PackedStringArray
			
			for entry: Variant in variable:
				var entry_type_string: String = get_variable_type_string(entry)
				
				if not entry_type_string in detected_types:
					detected_types.append(entry_type_string)
			
			return "Array%s" % ("" if detected_types.is_empty() else ("[%s]" % detected_types[0]))
		
		TYPE_FLOAT:
			return "float"
		
		TYPE_INT:
			return "int"
		
		TYPE_PACKED_VECTOR2_ARRAY:
			return "PackedVector2Array"
		
		TYPE_STRING:
			return "String"
		
		TYPE_STRING_NAME:
			return "StringName"
		
		TYPE_VECTOR2:
			return "Vector2"
		
		_:
			return "null"


static func get_variable_value_string(variable: Variant) -> String:
	var variable_type: int = typeof(variable)
	
	match variable_type:
		TYPE_ARRAY, TYPE_PACKED_VECTOR2_ARRAY:
			var parts: PackedStringArray
			
			for entry: Variant in variable:
				parts.append(get_variable_value_string(entry))
			
			match variable_type:
				TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array([%s])" % ", ".join(parts)
				_: return "[%s]" % ", ".join(parts)
		
		TYPE_STRING:
			return "\"%s\"" % variable
		
		TYPE_STRING_NAME:
			return "&\"%s\"" % variable
		
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [variable.x, variable.y]
		
		_:
			return str(variable)
