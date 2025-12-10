class_name SQLQueryUpsert extends SQLQueryStandard

#region Exports
@export var automatic_conflict_columns_detection: bool = true
@export var on_conflict_do_nothing: bool = true
#endregion

#region Private Variables
var _conflict_columns: Array[SQLColumn]
var _parameters: Array[SQLParameters]
var _validated_conflict_column_names: PackedStringArray
#endregion

#region Virtual Methods
func _init(table: SQLTable = null, columns: Array[SQLColumn] = [], conflict_columns: Array[SQLColumn] = []) -> void:
	super._init(QueryType.UPSERT, table, columns)
	
	if not conflict_columns.is_empty():
		_conflict_columns = conflict_columns


func _get_class() -> String:
	return "SQLQueryUpsert"
#endregion

#region Public Methods
func set_parameters(parameters: SQLParameters) -> SQLQueryUpsert:
	_parameters = [parameters]
	return self


func set_multiple_parameters(parameters: Array[SQLParameters]) -> SQLQueryUpsert:
	_parameters = parameters
	return self


func set_value(value: Variant) -> SQLQueryUpsert:
	_parameters.clear()
	_parameters.append(SQLParameters.new().set_value(value))
	return self


func set_values(values: Array[Variant], single_column_comparison: bool = false) -> SQLQueryUpsert:
	_parameters.clear()
	_parameters.append(SQLParameters.new().set_values(values).set_single_column_comparison(single_column_comparison))
	return self


func set_multiple_parameter_values(
	value_groups: Array[Array], single_column_comparison: bool = false
	) -> SQLQueryUpsert:
		_parameters.clear()
		
		for values: Array in value_groups:
			_parameters.append(
				SQLParameters.new().set_values(values).set_single_column_comparison(single_column_comparison)
				)
		
		return self


func set_column_and_value(column: SQLColumn, value: Variant) -> SQLQueryUpsert:
	return (set_column(column) as SQLQueryUpsert).set_value(value)


func set_columns_and_values(columns: Array[SQLColumn], values: Array[Variant]) -> SQLQueryUpsert:
	return (set_columns(columns) as SQLQueryUpsert).set_values(values)


func set_columns_and_values_by_dict(data: Dictionary[SQLColumn, Variant]) -> SQLQueryUpsert:
	set_columns(Array(data.keys(), TYPE_OBJECT, &"Resource", SQLColumn))
	set_values(data.values())
	return self


func get_conflict_columns() -> Array[SQLColumn]:
	return _conflict_columns


func set_conflict_columns(columns: Array[SQLColumn]) -> SQLQueryUpsert:
	_conflict_columns = columns
	return self


func get_validated_conflict_column_names() -> PackedStringArray:
	return _validated_conflict_column_names


func is_automatic_conflict_columns_detection() -> bool:
	return automatic_conflict_columns_detection


func set_automatic_conflict_columns_detection(state: bool = true) -> SQLQueryUpsert:
	automatic_conflict_columns_detection = state
	return self


func is_on_conflict_do_nothing() -> bool:
	return on_conflict_do_nothing


func set_on_conflict_do_nothing(state: bool = true) -> SQLQueryUpsert:
	on_conflict_do_nothing = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	var table: SQLTable = get_table()
	
	if _parameters.is_empty():
		Log.error("No parameters were provided! Table: '%s'." % table.name, _validate)
		return false
	
	var validated_parameters_count: int = 0
	
	for parameters: SQLParameters in _parameters:
		if _validate_parameters(parameters):
			validated_parameters_count += 1
	
	if validated_parameters_count != _parameters.size():
		Log.error("Not all parameters could be validated!", _validate)
		return false
	
	if _conflict_columns.is_empty():
		if automatic_conflict_columns_detection:
			for column: SQLColumn in table.columns:
				if column.is_unique():
					_conflict_columns.append(column)
		
		else:
			Log.error("No conflict columns were provided! Table: '%s'." % table.name, _validate)
			return false
	
	_validated_conflict_column_names = SQLUtils.get_validated_column_names(_conflict_columns)
	
	if _validated_conflict_column_names.is_empty():
		Log.error("Not all provided conflict columns are valid! Table: '%s'." % table.name, _validate)
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var grouped_values: PackedStringArray
	
	for parameters: SQLParameters in _parameters:
		grouped_values.append("(%s)" % ", ".join(parameters.get_validated_values()))
	
	definitions.append_array(PackedStringArray([
		"INSERT INTO %s" % get_table().get_validated_name(),
		"(%s)" % ", ".join(get_validated_column_names()),
		"VALUES %s" % ", ".join(grouped_values),
		"ON CONFLICT (%s) DO" % ", ".join(_validated_conflict_column_names),
		]))
	
	if on_conflict_do_nothing:
		definitions.append("NOTHING")
	
	else:
		var mapped_set_columns: PackedStringArray
		
		for column: SQLColumn in get_columns():
			var column_validated_name: String = column.get_validated_name()
			
			mapped_set_columns.append("%s = excluded.%s" % [column_validated_name, column_validated_name])
		
		definitions.append("UPDATE SET %s" % ", ".join(mapped_set_columns))
	
	return " ".join(definitions)
#endregion
