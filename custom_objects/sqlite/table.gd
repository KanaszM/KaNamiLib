class_name SQLTable extends SQLResource

#region Exports
@export var name: String
@export var columns: Array[SQLColumn]
#endregion

#region Private Variables
var _validated_name: String
#endregion

#region Virtual Methods
func _init(name_arg: String = "", columns_arg: Array[SQLColumn] = []) -> void:
	super._init(ResourceType.TABLE)
	
	name_arg = name_arg.strip_edges()
	
	if not name_arg.is_empty():
		name = name_arg
	
	if not columns_arg.is_empty():
		columns = columns_arg


func _to_string() -> String:
	return "<SQLTable[%s]>" % name


func _get_class() -> String:
	return "SQLTable"
#endregion

#region Public Methods
func set_table_name(name_arg: String) -> SQLTable:
	name = name_arg.strip_edges()
	return self


func get_columns() -> Array[SQLColumn]:
	return columns


func set_columns(columns_arg: Array[SQLColumn]) -> SQLTable:
	columns = columns_arg
	return self


func append_column(column: SQLColumn) -> SQLTable:
	columns.append(column)
	return self


func append_columns(columns_arg: Array[SQLColumn]) -> SQLTable:
	columns.append_array(columns_arg)
	return self


func get_validated_name() -> String:
	return _validated_name
#endregion

#region Private Methods
func _validate() -> bool:
	#region Name Validation
	_validated_name = name.strip_edges().to_lower().replace(" ", "_")
	
	if (
		_validated_name.is_empty()
		or not UtilsRegex.is_valid(UtilsRegex.MATCH_ALPHA_START_ALPHANUM, _validated_name)
		):
			Log.error("Invalid table name: '%s'!" % _validated_name, _validate)
			return false
	#endregion
	
	#region Columns Validation
	if columns.is_empty():
		Log.error("No columns were provided for table: '%s'!" % name, _validate)
		return false
	
	var validated_column_names_list: PackedStringArray
	
	for column: SQLColumn in columns:
		if column == null:
			continue
		
		column.validate()
		
		if not column.is_valid():
			Log.error("The provided column: '%s' on table: '%s', is invalid!" % [column.name, name], _validate)
			continue
		
		if column._validated_name in validated_column_names_list:
			Log.error("A column with name: '%s', already exists on table: '%s'!" % [column.name, name], _validate)
			continue
		
		validated_column_names_list.append(column._validated_name)
	
	if validated_column_names_list.size() != columns.size():
		Log.error("Not all provided columns were validated on table: '%s'!" % name, _validate)
		return false
	#endregion
	
	return true
#endregion
