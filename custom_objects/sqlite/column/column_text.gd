class_name SQLColumnText extends SQLColumn

#region Exports
@export_group("Length Limit", "length_")
@export var length_enabled: bool
@export var length_exact: bool
@export_range(0, 100, 1, "or_greater") var length_limit_min: int
@export_range(0, 100, 1, "or_greater") var length_limit_max: int

@export_group("Default Value", "default_")
@export var default_enabled: bool
@export var default_value: String
@export var default_strip_edges: bool = true
#endregion

#region Private Variables
var _validated_default_value: String
var _validated_length_definition: String
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.TEXT, name_arg)


func _get_class() -> String:
	return "SQLColumnText"
#endregion

#region Public Methods
func set_length_enabled(state: bool = true) -> SQLColumnText:
	length_enabled = state
	return self


func set_length_exact(state: bool = true) -> SQLColumnText:
	length_exact = state
	return self


func set_length_limit(value_min: int, value_max: int) -> SQLColumnText:
	length_limit_min = maxi(0, value_min)
	length_limit_max = maxi(0, value_max)
	return self


func set_length_limit_min(value: int) -> SQLColumnText:
	length_limit_min = maxi(0, value)
	return self


func set_length_limit_max(value: int) -> SQLColumnText:
	length_limit_max = maxi(0, value)
	return self


func set_default_enabled(state: bool = true) -> SQLColumnText:
	default_enabled = state
	return self


func set_default_value(value: String) -> SQLColumnText:
	default_value = value
	return self


func set_default_strip_edges(state: bool = true) -> SQLColumnText:
	default_strip_edges = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if default_enabled:
		_validated_default_value = SQLUtils.get_string_definition(default_value, default_strip_edges)
	
	if length_enabled:
		if length_exact and length_limit_max == 0:
			Log.error(
				"The maximum length limit must be greater than 0 if expected an exact length! Column: %s" % name,
				_validate
				)
			return false
		
		if default_enabled:
			var default_value_sanitized: String = default_value.strip_edges()
			var default_value_length: int = default_value_sanitized.length()
			
			if length_exact:
				if default_value_length != length_limit_max:
					Log.error(
						"The length of the default value: %d ('%s'), must be exactly: %d! Column: %s" % [
							default_value_length, default_value_sanitized, length_limit_max, name
							],
						_validate
						)
					return false
			
			else:
				if length_limit_min > 0 and default_value_length < length_limit_min:
					Log.error(
						"The length of the default value: %d ('%s'), must be greater than: %d! Column: %s" % [
							default_value_length, default_value_sanitized, length_limit_min, name
							],
						_validate
						)
					return false
				
				if length_limit_max > 0 and default_value_length > length_limit_max:
					Log.error(
						"The length of the default value: %d ('%s'), must be lower than: %d! Column: %s" % [
							default_value_length, default_value_sanitized, length_limit_max, name
							],
						_validate
						)
					return false
		
		var prefix: String = "CHECK (length(%s) " % get_validated_name()
		var suffix: String
		
		if length_exact:
			suffix = "= %d)" % length_limit_max
		
		else:
			if length_limit_min > 0 and length_limit_max > 0:
				suffix = "BETWEEN %d AND %d)" % [length_limit_min, length_limit_max]
			
			else:
				if length_limit_min > 0:
					suffix = "<= %d)" % length_limit_min
				
				elif length_limit_max > 0:
					suffix = ">= %d)" % length_limit_max
		
		if suffix.is_empty():
			Log.error("Could not define the suffix for the length definition! Column: %s" % name, _validate)
			return false
		
		_validated_length_definition = "%s%s" % [prefix, suffix]
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append(super._get_definition())
	
	if default_enabled:
		definitions.append("DEFAULT %s" % _validated_default_value)
	
	if length_enabled:
		definitions.append(_validated_length_definition)
	
	return " ".join(definitions)
#endregion
