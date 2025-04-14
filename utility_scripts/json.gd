class_name UtilsJSON


static func safe_parse_dict(json: Variant) -> Dictionary[Variant, Variant]:
	var parsed: Variant = JSON.parse_string(str(json))
	
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


static func safe_parse_array(json: Variant) -> Array:
	var parsed: Variant = JSON.parse_string(str(json))
	
	return parsed if typeof(parsed) == TYPE_ARRAY else []
