class_name UtilsJSON


static func safe_parse_dict(json: Variant) -> Dictionary:
	var parsed: Variant = JSON.parse_string(str(json))
	
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	
	return {}


static func safe_parse_array(json: Variant) -> Array:
	var parsed: Variant = JSON.parse_string(str(json))
	
	return parsed if typeof(parsed) == TYPE_ARRAY else []
