"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsDictionary


#region Public Static Methods [Enum]
static func enum_to_str(enum_arg: Dictionary, idx: int, to_lower: bool = false) -> String:
	var result: String
	var enum_dict: Dictionary[String, int] = enum_to_typed_dict(enum_arg)
	
	for key: String in enum_dict:
		if enum_dict[key] == idx:
			result = str(key).replace("_", " ")
			break
	
	return result.to_lower() if to_lower else result


static func enum_to_str_capizalized(enum_param: Dictionary, idx: int) -> String:
	return enum_to_str(enum_param, idx).capitalize()


static func enum_to_typed_dict(enum_arg: Dictionary) -> Dictionary[String, int]:
	return Dictionary(enum_arg, TYPE_STRING, &"", null, TYPE_INT, &"", null) as Dictionary[String, int]
#endregion
