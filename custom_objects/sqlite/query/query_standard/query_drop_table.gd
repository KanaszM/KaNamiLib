class_name SQLQueryDropTable extends SQLQueryStandard

#region Exports
@export var if_exists: bool = true
#endregion

#region Virtual Methods
func _init(table: SQLTable = null) -> void:
	super._init(QueryType.CREATE_TABLE, table)
	set_columns_required(false)


func _get_class() -> String:
	return "SQLQueryDropTable"
#endregion

#region Public Methods
func get_if_exists() -> bool:
	return if_exists


func set_if_exists(state: bool = true) -> SQLQueryDropTable:
	if_exists = state
	return self
#endregion

#region Private Methods
func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append("DROP TABLE")
	
	if if_exists:
		definitions.append("IF EXISTS")
	
	definitions.append(get_table().get_validated_name())
	
	return " ".join(definitions)
#endregion
