class_name SQLQueryUpdate extends SQLQueryWrite

#region Exports
@export var filter: SQLFilter
#endregion

#region Private Variables
var _parameters: SQLParameters
#endregion

#region Virtual Methods
func _init(
	table: SQLTable = null, columns: Array[SQLColumn] = [],
	confilct_clause_type_arg: ConflictClauseType = ConflictClauseType.NONE, filter_arg: SQLFilter = null
	) -> void:
		super._init(QueryType.UPDATE, table, columns, confilct_clause_type_arg)
		
		if filter_arg != null:
			filter = filter_arg


func _get_class() -> String:
	return "SQLQueryUpdate"
#endregion

#region Public Methods
func get_filter() -> SQLFilter:
	return filter


func set_filter(filter_arg: SQLFilter) -> SQLQueryUpdate:
	filter = filter_arg
	return self


func set_parameters(parameters: SQLParameters) -> SQLQueryUpdate:
	_parameters = parameters
	return self


func set_value(value: Variant) -> SQLQueryUpdate:
	_parameters = SQLParameters.new().set_value(value)
	return self


func set_values(values: Array[Variant]) -> SQLQueryUpdate:
	_parameters = SQLParameters.new().set_values(values)
	return self


func append_value(value: Variant) -> SQLQueryUpdate:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.append_value(value)
	return self


func append_values(values: Array[Variant]) -> SQLQueryUpdate:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.append_values(values)
	return self


func set_column_and_value(column: SQLColumn, value: Variant) -> SQLQueryUpdate:
	return (set_column(column) as SQLQueryUpdate).set_value(value)


func set_columns_and_values(columns: Array[SQLColumn], values: Array[Variant]) -> SQLQueryUpdate:
	return (set_columns(columns) as SQLQueryUpdate).set_values(values)
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if not _validate_parameters(_parameters):
		return false
	
	if not _validate_filter(filter):
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var mapped_columns_and_values: PackedStringArray
	var validated_values: PackedStringArray = _parameters.get_validated_values()
	var validated_column_names: PackedStringArray = get_validated_column_names()
	
	definitions.append("UPDATE")
	
	if confilct_clause_type != ConflictClauseType.NONE:
		definitions.append(_get_confilct_clause_type_definition())
	
	definitions.append(get_table().get_validated_name())
	
	for idx: int in validated_column_names.size():
		mapped_columns_and_values.append("%s = %s" % [validated_column_names[idx], validated_values[idx]])
	
	definitions.append("SET %s" % ", ".join(mapped_columns_and_values))
	
	if filter != null:
		definitions.append(filter.get_definition())
	
	return " ".join(definitions)
#endregion
