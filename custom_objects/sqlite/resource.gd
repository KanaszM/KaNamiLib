class_name SQLResource extends Resource

#region Enums
enum ResourceType {NONE, COLUMN, CONDITION, FILTER, QUERY, TABLE}
#endregion

#region Private Variables
var _resource_type: ResourceType
var _is_valid: bool
#endregion

#region Virtual Methods
func _init(resource_type: ResourceType = ResourceType.NONE) -> void:
	_resource_type = resource_type


func _to_string() -> String:
	return "<SQLResource[%s]>" % [resource_type_to_str(_resource_type).capitalize()]


func _get_class() -> String:
	return "SQLResource"
#endregion

#region Public Static Methods
static func get_resource_types() -> Array[ResourceType]:
	return Array(ResourceType.values().slice(1), TYPE_INT, &"", null) as Array[ResourceType]


static func resource_type_to_str(resource_type: ResourceType) -> String:
	return UtilsDictionary.enum_to_str(ResourceType, resource_type)
#endregion

#region Public Methods
func validate() -> bool:
	_is_valid = false
	
	if _resource_type == ResourceType.NONE or not _resource_type in ResourceType.values():
		Log.error("Invalid resource type: %d!" % _resource_type, validate)
		return false
	
	_is_valid = _validate()
	
	return _is_valid


func is_valid() -> bool:
	return _is_valid


func get_definition() -> String:
	if not _is_valid:
		Log.error("This SQLResource: %s, is not valid!" % self, get_definition)
		return ""
	
	return _get_definition()


func validate_and_get_definition() -> String:
	validate()
	
	return get_definition()
#endregion

#region Private Methods
func _validate() -> bool:
	return false


func _get_definition() -> String:
	return ""
#endregion
