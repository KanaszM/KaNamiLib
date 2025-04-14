class_name UtilsOS


static func get_username(if_not_found: String = "", attribute: String = "USERNAME") -> String:
	return OS.get_environment(attribute) if OS.has_environment(attribute) else if_not_found
