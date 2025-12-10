class_name SQLColumnDate extends SQLColumn

#region Exports
@export_group("Default Value", "default_")
@export var default_enabled: bool = true
@export var default_value: String
@export var default_current_date: bool = true
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.DATE, name_arg)


func _get_class() -> String:
	return "SQLColumnDate"
#endregion

#region Public Methods
func set_default_enabled(state: bool = true) -> SQLColumnDate:
	default_enabled = state
	return self


func set_default_value(value: String) -> SQLColumnDate:
	default_value = value
	return self


func set_default_current_date(state: bool = true) -> SQLColumnDate:
	default_current_date = state
	return self
#endregion

#region Private Methods
func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if default_enabled:
		definitions.append("DEFAULT %s" % ("CURRENT_DATE" if default_current_date else default_value))
	
	return " ".join(definitions)
#endregion
