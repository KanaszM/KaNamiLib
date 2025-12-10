class_name SQLQuerySelect extends SQLQueryStandard

#region Exports
@export var filter: SQLFilter
#endregion

#region Virtual Methods
func _init(table: SQLTable = null, columns: Array[SQLColumn] = [], filter_arg: SQLFilter = null) -> void:
	super._init(QueryType.SELECT, table, columns)
	
	if filter_arg != null:
		filter = filter_arg


func _get_class() -> String:
	return "SQLQuerySelect"
#endregion

#region Public Methods
func get_filter() -> SQLFilter:
	return filter


func set_filter(filter_arg: SQLFilter) -> SQLQuerySelect:
	filter = filter_arg
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	var table: SQLTable = get_table()
	
	if get_columns().is_empty() and table != null:
		set_columns(table.columns)
	
	if not super._validate():
		return false
	
	if not _validate_filter(filter):
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append_array(PackedStringArray([
		"SELECT",
		", ".join(get_validated_column_names()),
		"FROM %s" % get_table().get_validated_name(),
		]))
	
	if filter != null:
		definitions.append(filter.get_definition())
	
	return " ".join(definitions)
#endregion
