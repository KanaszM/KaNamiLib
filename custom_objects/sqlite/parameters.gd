class_name SQLParameters

#region Private Variables
var _values: Array[Variant]
var _is_valid: bool
var _validated_values: PackedStringArray
var _single_column_comparison: bool
#endregion

#region Virtual Methods
func _init(values: Array[Variant] = []) -> void:
	if not values.is_empty():
		_values = values


func _to_string() -> String:
	return "<SQLParameters[%d]>" % _values.size()


func _get_class() -> String:
	return "SQLParameters"
#endregion

#region Public Methods
func get_values() -> Array[Variant]:
	return _values


func set_value(value: Variant) -> SQLParameters:
	_values = [value]
	return self


func set_values(values: Array[Variant]) -> SQLParameters:
	_values = values
	return self


func append_value(value: Variant) -> SQLParameters:
	_values.append(value)
	return self


func append_values(values: Array[Variant]) -> SQLParameters:
	_values.append_array(values)
	return self


func is_single_column_comparison() -> bool:
	return _single_column_comparison


func set_single_column_comparison(state: bool = true) -> SQLParameters:
	_single_column_comparison = state
	return self


func is_valid() -> bool:
	return _is_valid


func get_validated_values() -> PackedStringArray:
	return _validated_values


func validate(expected_columns: Array[SQLColumn]) -> bool:
	_is_valid = false
	_validated_values.clear()
	
	if expected_columns.is_empty():
		Log.error("No expected columns were provided!", validate)
		return false
	
	var func_on_failed_check_value_type_by_column_type: Callable = func(
		value_arg: Variant, column_type_arg: SQLColumn.DataType
		) -> void:
			Log.error(
				"Invalid value: %s of type: %s. Correct type: %s!" % [
					value_arg, type_string(typeof(value_arg)), SQLColumn.data_type_to_str(column_type_arg)
				],
				validate
				)
	
	if _single_column_comparison:
		if _values.is_empty():
			Log.error("No values were provided.", validate)
			return false
		
		var column: SQLColumn = expected_columns[0]
		var column_type: SQLColumn.DataType = column.get_data_type()
		
		for value_value: Variant in _values:
			if SQLUtils.check_value_type_by_column_type(value_value, column_type):
				var validated_value: String = SQLUtils.get_value_definition_by_column_type(value_value, column_type)
				
				if validated_value == SQLUtils.Keyword.ERROR:
					Log.error("Invalid value: %s. Value could not be defined!" % value_value, validate)
					return false
				
				_validated_values.append(validated_value)
			
			else:
				func_on_failed_check_value_type_by_column_type.call(value_value, column_type)
	
	else:
		var expected_columns_count: int = expected_columns.size()
		
		if _values.size() != expected_columns_count:
			Log.error("Values count out-of-bounds! Expected: %d values." % expected_columns_count, validate)
			return false
		
		var valid_value_count: int = 0
		
		for column_idx: int in expected_columns_count:
			var value_value: Variant = _values[column_idx]
			var column: SQLColumn = expected_columns[column_idx]
			var column_type: SQLColumn.DataType = column.get_data_type()
			
			if SQLUtils.check_value_type_by_column_type(value_value, column_type):
				var validated_value: String = SQLUtils.get_value_definition_by_column_type(value_value, column_type)
				
				if validated_value == SQLUtils.Keyword.ERROR:
					Log.error("Invalid value: %s. Value could not be defined!" % value_value, validate)
					continue
				
				valid_value_count += 1
				_validated_values.append(validated_value)
			
			else:
				func_on_failed_check_value_type_by_column_type.call(value_value, column_type)
		
		if valid_value_count != expected_columns_count:
			Log.error("Not all values are valid!", validate)
			return false
	
	_is_valid = true
	return true
#endregion
