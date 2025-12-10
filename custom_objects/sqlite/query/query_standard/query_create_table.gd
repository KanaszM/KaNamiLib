class_name SQLQueryCreateTable extends SQLQueryStandard

#region Exports
@export var if_not_exists: bool = true
#endregion

#region Private Variables
var _validated_grouped_unique_columns: String
#endregion

#region Virtual Methods
func _init(table: SQLTable = null) -> void:
	super._init(QueryType.CREATE_TABLE, table)
	set_columns_required(false)


func _get_class() -> String:
	return "SQLQueryCreateTable"
#endregion

#region Public Methods
func get_if_not_exists() -> bool:
	return if_not_exists


func set_if_not_exists(state: bool = true) -> SQLQueryCreateTable:
	if_not_exists = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	#region Detect Grouped Unique Columns
	var validated_unique_column_names_for_grouping: PackedStringArray
	
	for column: SQLColumn in get_table().get_columns():
		if column.is_unique_grouped():
			validated_unique_column_names_for_grouping.append(column.get_validated_name())
	
	if not validated_unique_column_names_for_grouping.is_empty():
		_validated_grouped_unique_columns = "UNIQUE (%s)" % ", ".join(validated_unique_column_names_for_grouping)
	#endregion
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var table: SQLTable = get_table()
	
	definitions.append("CREATE TABLE")
	
	if if_not_exists:
		definitions.append("IF NOT EXISTS")
	
	definitions.append(table.get_validated_name())
	
	var column_definitions: PackedStringArray
	
	for column: SQLColumn in table.columns:
		column_definitions.append(column.get_definition())
	
	if not _validated_grouped_unique_columns.is_empty():
		column_definitions.append(_validated_grouped_unique_columns)
	
	definitions.append("(%s)" % ", ".join(column_definitions))
	
	return " ".join(definitions)
#endregion
