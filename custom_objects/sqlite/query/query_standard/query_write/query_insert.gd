class_name SQLQueryInsert extends SQLQueryWrite

#region Private Variables
var _parameters: Array[SQLParameters]
#endregion

#region Virtual Methods
func _init(
	table: SQLTable = null, columns: Array[SQLColumn] = [],
	confilct_clause_type_arg: ConflictClauseType = ConflictClauseType.NONE
	) -> void:
		super._init(QueryType.INSERT, table, columns, confilct_clause_type_arg)


func _get_class() -> String:
	return "SQLQueryInsert"
#endregion

#region Public Methods
func set_column_and_value(column: SQLColumn, value: Variant) -> SQLQueryInsert:
	return (set_column(column) as SQLQueryInsert).set_value(value)


func set_columns_and_values(columns: Array[SQLColumn], values: Array[Variant]) -> SQLQueryInsert:
	return (set_columns(columns) as SQLQueryInsert).set_values(values)


func set_parameters(parameters: SQLParameters) -> SQLQueryInsert:
	_parameters = [parameters]
	return self


func set_multiple_parameters(parameters: Array[SQLParameters]) -> SQLQueryInsert:
	_parameters = parameters
	return self


func set_value(value: Variant) -> SQLQueryInsert:
	_parameters.clear()
	_parameters.append(SQLParameters.new().set_value(value))
	return self


func set_values(values: Array[Variant], single_column_comparison: bool = false) -> SQLQueryInsert:
	_parameters.clear()
	_parameters.append(SQLParameters.new().set_values(values).set_single_column_comparison(single_column_comparison))
	return self


func set_multiple_parameter_values(
	value_groups: Array[Array], single_column_comparison: bool = false
	) -> SQLQueryInsert:
		_parameters.clear()
		
		for values: Array in value_groups:
			_parameters.append(
				SQLParameters.new().set_values(values).set_single_column_comparison(single_column_comparison)
				)
		
		return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if _parameters.is_empty():
		Log.error("No parameters were provided! Table: '%s'." % get_table().name, _validate)
		return false
	
	var validated_parameters_count: int = 0
	
	for parameters: SQLParameters in _parameters:
		if _validate_parameters(parameters):
			validated_parameters_count += 1
	
	if validated_parameters_count != _parameters.size():
		Log.error("Not all parameters could be validated!", _validate)
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var grouped_values: PackedStringArray
	
	definitions.append("INSERT")
	
	if confilct_clause_type != ConflictClauseType.NONE:
		definitions.append(_get_confilct_clause_type_definition())
	
	for parameters: SQLParameters in _parameters:
		grouped_values.append("(%s)" % ", ".join(parameters.get_validated_values()))
	
	definitions.append_array(PackedStringArray([
		"INTO %s" % get_table().get_validated_name(),
		"(%s)" % ", ".join(get_validated_column_names()),
		"VALUES %s" % ", ".join(grouped_values),
		]))
	
	return " ".join(definitions)
#endregion
