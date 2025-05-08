class_name UtilsResource


static func get_uid(resource: Resource, trim_prefix: bool = false, if_null: String = "") -> String:
	if resource == null:
		return if_null
	
	var uid: String = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(resource.resource_path))
	
	if uid == "uid://<invalid>":
		return if_null
	
	if trim_prefix:
		uid = uid.trim_prefix("uid://")
	
	return uid
