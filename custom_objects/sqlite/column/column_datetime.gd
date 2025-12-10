class_name SQLColumnDateTime extends SQLColumn

#region Exports
@export_group("Default Value", "default_")
@export var default_enabled: bool = true
@export var default_value: String
@export var default_current_timestamp: bool = true
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.DATETIME, name_arg)


func _get_class() -> String:
	return "SQLColumnDateTime"
#endregion

#region Public Methods
func set_default_enabled(state: bool = true) -> SQLColumnDateTime:
	default_enabled = state
	return self


func set_default_value(value: String) -> SQLColumnDateTime:
	default_value = value
	return self


func set_default_current_timestamp(state: bool = true) -> SQLColumnDateTime:
	default_current_timestamp = state
	return self
#endregion

#region Private Methods
func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if default_enabled:
		definitions.append("DEFAULT %s" % ("CURRENT_TIMESTAMP" if default_current_timestamp else default_value))
	
	return " ".join(definitions)
#endregion
