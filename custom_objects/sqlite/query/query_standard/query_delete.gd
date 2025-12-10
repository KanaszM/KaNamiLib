class_name SQLQueryDelete extends SQLQueryStandard

#region Exports
@export var filter: SQLFilter
@export var filter_required: bool = true
#endregion

#region Virtual Methods
func _init(table: SQLTable = null, filter_arg: SQLFilter = null) -> void:
	super._init(QueryType.DELETE, table)
	set_columns_required(false)
	
	if filter_arg != null:
		filter = filter_arg


func _get_class() -> String:
	return "SQLQueryDelete"
#endregion

#region Public Methods
func get_filter() -> SQLFilter:
	return filter


func set_filter(filter_arg: SQLFilter) -> SQLQueryDelete:
	filter = filter_arg
	return self


func is_filter_required() -> bool:
	return filter_required


func set_filter_required(state: bool = true) -> SQLQueryDelete:
	filter_required = state
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if not super._validate():
		return false
	
	if not _validate_filter(filter, filter_required):
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	
	definitions.append("DELETE FROM %s" % get_table().get_validated_name())
	
	if filter != null:
		definitions.append(filter.get_definition())
	
	return " ".join(definitions)
#endregion
