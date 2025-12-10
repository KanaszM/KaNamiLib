class_name SQLColumnReal extends SQLColumn

#region Exports
@export_group("Default Value", "default_")
@export var default_enabled: bool
@export var default_value: float
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.REAL, name_arg)


func _get_class() -> String:
	return "SQLColumnReal"
#endregion

#region Public Methods
func set_default_enabled(state: bool = true) -> SQLColumnReal:
	default_enabled = state
	return self


func set_default_value(value: float) -> SQLColumnReal:
	default_value = value
	return self
#endregion

#region Private Methods
func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if default_enabled:
		definitions.append("DEFAULT %.5f" % default_value)
	
	return " ".join(definitions)
#endregion
