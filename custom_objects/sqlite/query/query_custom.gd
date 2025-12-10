class_name SQLQueryCustom extends SQLQuery

#region Exports
@export var definition: String
#endregion

#region Virtual Methods
func _init(definition_arg: String = "") -> void:
	super._init(QueryType.CUSTOM)
	
	if not definition_arg.is_empty():
		set_definition(definition_arg)


func _to_string() -> String:
	return "<SQLQueryCustom[%s]>" % UtilsText.truncate(definition, 20)


func _get_class() -> String:
	return "SQLQueryCustom"
#endregion

#region Public Methods
func get_definition() -> String:
	return definition


func set_definition(definition_arg: String) -> SQLQueryCustom:
	definition = definition_arg.strip_edges()
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if definition.is_empty():
		Log.error("No definition was defined!", _validate)
		return false
	
	return true


func _get_definition() -> String:
	return definition
#endregion
