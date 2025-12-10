class_name SQLColumnBoolean extends SQLColumn

#region Exports
@export_group("Default Value", "default_")
@export var default_enabled: bool
@export var default_value: bool
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.BOOLEAN, name_arg)


func _get_class() -> String:
	return "SQLColumnBoolean"
#endregion

#region Public Methods
func set_default_enabled(state: bool = true) -> SQLColumnBoolean:
	default_enabled = state
	return self


func set_default_value(value: bool) -> SQLColumnBoolean:
	default_value = value
	return self
#endregion

#region Private Methods
func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if default_enabled:
		definitions.append("DEFAULT %d" % int(default_value))
	
	return " ".join(definitions)
#endregion
