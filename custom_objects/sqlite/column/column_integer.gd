class_name SQLColumnInteger extends SQLColumn

#region Exports
@export var auto_increment: bool

@export_group("Default Value", "default_")
@export var default_enabled: bool
@export var default_value: int
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.INTEGER, name_arg)


func _get_class() -> String:
	return "SQLColumnInteger"
#endregion

#region Public Methods
func set_default_enabled(state: bool = true) -> SQLColumnInteger:
	default_enabled = state
	return self


func set_default_value(value: int) -> SQLColumnInteger:
	default_value = value
	return self


func set_auto_increment(state: bool = true) -> SQLColumnInteger:
	auto_increment = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if auto_increment:
		var invalid_constraints_available: bool
		
		if is_unique() or not_null:
			Log.error(
				"The constraints 'unique' or 'not null' cannot be used with AUTOINCREMENT on column: '%s'!" % name,
				_validate
				)
			invalid_constraints_available = true
		
		if invalid_constraints_available:
			return false
		
		if not primary_key:
			Log.error(
				"Invalid constraint: AUTOINCREMENT requires a 'primary key' constraint on column: '%s'!" % name,
				_validate
				)
			return false
		
		if default_enabled:
			Log.error(
				"Invalid constraint: AUTOINCREMENT cannot be used with DEFAULT on column: '%s'!" % name, _validate
				)
			return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if auto_increment:
		definitions.append("AUTOINCREMENT")
	
	if default_enabled:
		definitions.append("DEFAULT %d" % default_value)
	
	return " ".join(definitions)
#endregion
