class_name SQLResultRow

#region Private Variables
var _is_valid: bool
var _mapped_results: Dictionary[SQLColumn, Variant]
#endregion

#region Virtual Methods
func _init(raw_data: Dictionary, query: SQLQuery) -> void:
	if raw_data.is_empty():
		Log.error("Raw data not provided!", _init)
		return
	
	if query == null:
		Log.error("Query reference not provided!", _init)
		return
	
	var query_type: SQLQuery.QueryType = query.get_query_type()
	
	match query_type:
		SQLQuery.QueryType.CUSTOM:
			for column: Variant in raw_data:
				var column_name: String = str(column)
				var value: String = str(raw_data[column])
				var custom_column: SQLColumnText = SQLColumnText.new(column_name)
				
				custom_column.validate()
				_mapped_results[custom_column as SQLColumn] = value
		
		SQLQuery.QueryType.SELECT:
			var query_select := query as SQLQuerySelect
			var columns: Array[SQLColumn] = query_select.get_columns()
			
			for column: SQLColumn in columns:
				var column_validated_name: String = column.get_validated_name()
				var raw_data_value: Variant = raw_data.get(column_validated_name)
				
				if column_validated_name.is_empty():
					Log.error("Empty validated name on column: %s!" % column, _init)
					continue
				
				if raw_data_value == null:
					Log.error("Value not found for column with name: '%s'!" % column_validated_name, _init)
					continue
				
				match column.get_data_type():
					SQLColumn.DataType.BOOLEAN: raw_data_value = bool(raw_data_value)
				
				_mapped_results[column] = raw_data_value
			
			if _mapped_results.size() != columns.size():
				Log.error("Could not map all results from the provided raw data!", _init)
				return
		
		_:
			Log.error("The referenced query is of invalid type: %s!" % SQLQuery.query_type_to_str(query_type), _init)
			return
	
	_is_valid = true


func _to_string() -> String:
	return "<SQLResultRow[%s]>" % _mapped_results.size()


func _get_class() -> String:
	return "SQLResultRow"
#endregion

#region Public Methods
func is_valid() -> bool:
	return _is_valid


func get_data() -> Dictionary[SQLColumn, Variant]:
	return _mapped_results


func get_values() -> Array[Variant]:
	return _mapped_results.values()


func get_columns() -> Array[SQLColumn]:
	return _mapped_results.keys()


func get_value(column: SQLColumn) -> Variant:
	if not column in _mapped_results:
		Log.error("Column: %s, not found in the results!" % column, get_value)
		return null
	
	return _mapped_results[column]


func get_first_value() -> Variant:
	for column: SQLColumn in _mapped_results:
		return _mapped_results[column]
	
	return null


func get_mapped_results_to_string() -> String:
	var pool: PackedStringArray
	
	for column: SQLColumn in _mapped_results:
		pool.append("%s = %s" % [column.get_validated_name(), _mapped_results[column]])
	
	return ", ".join(pool)
#endregion
