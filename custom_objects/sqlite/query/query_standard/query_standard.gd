class_name SQLQueryStandard extends SQLQuery

#region Exports
@export var columns_required: bool = true
#endregion

#region Private Variables
var _table: SQLTable
var _columns: Array[SQLColumn]
var _validated_column_names: PackedStringArray
#endregion

#region Virtual Methods
func _init(query_type: QueryType, table: SQLTable = null, columns: Array[SQLColumn] = []) -> void:
	super._init(query_type)
	
	if table != null:
		_table = table
	
	if not columns.is_empty():
		_columns = columns


func _to_string() -> String:
	return "<SQLQuery%s[%s]%s>" % [
		query_type_to_str(get_query_type()).capitalize(),
		("" if _table == null else _table.name),
		("[%d]" % _columns.size()) if columns_required else "",
		]


func _get_class() -> String:
	return "SQLQueryStandard"
#endregion

#region Public Methods
func get_table() -> SQLTable:
	return _table


func set_table(table: SQLTable) -> SQLQueryStandard:
	_table = table
	return self


func get_columns() -> Array[SQLColumn]:
	return _columns


func set_column(column: SQLColumn) -> SQLQueryStandard:
	_columns = [column]
	return self


func set_columns(columns: Array[SQLColumn]) -> SQLQueryStandard:
	_columns = columns
	return self


func get_validated_column_names() -> PackedStringArray:
	return _validated_column_names


func are_columns_required() -> bool:
	return columns_required


func set_columns_required(state: bool = true) -> SQLQueryStandard:
	columns_required = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if _table == null:
		Log.error("No table was provided!", _validate)
		return false
	
	_table.validate()
	
	if not _table.is_valid():
		Log.error("The provided table is invalid!", _validate)
		return false
	
	if columns_required:
		if _columns.is_empty():
			Log.error("No columns were provided! Table: '%s'." % _table.name, _validate)
			return false
		
		_validated_column_names = SQLUtils.get_validated_column_names(_columns)
		
		if _validated_column_names.is_empty():
			Log.error("Not all provided columns are valid! Table: '%s'." % _table.name, _validate)
			return false
	
	else:
		_validated_column_names.clear()
	
	return true


func _validate_parameters(parameters: SQLParameters, required: bool = true) -> bool:
	if parameters == null:
		if required:
			Log.error("No parameters were provided! Table: '%s'." % _table.name, _validate_parameters)
			return false
		
		return true
	
	if not parameters.validate(_columns):
		Log.error(
			"The provided parameters: %s, or columns are invalid! Table: '%s'." % [parameters, _table.name],
			_validate_parameters
			)
		return false
	
	return true


func _validate_filter(filter: SQLFilter, required: bool = false) -> bool:
	if filter == null:
		if required:
			Log.error("No filter was provided! Table: '%s'." % _table.name, _validate)
			return false
		
		return true
	
	filter.validate()
	
	if not filter.is_valid():
		Log.error("The provided filter is invalid! Table: '%s'." % _table.name, _validate)
		return false
	
	var filter_conditions: Array[SQLFilterCondition] = filter.get_conditions()
	var valid_condition_columns_count: int = 0
	
	for condition: SQLFilterCondition in filter_conditions:
		if condition.column in _table.columns:
			valid_condition_columns_count += 1
		
		else:
			Log.error(
				"Filter condition column: '%s', does not exist on table: '%s'!" % [condition.column.name, _table.name],
				_validate
				)
	
	if valid_condition_columns_count != filter_conditions.size():
		Log.error("Some filter condition columns are invalid for the provided table: '%s'!" % _table.name, _validate)
		return false
	
	return true
#endregion
