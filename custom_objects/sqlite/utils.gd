class_name SQLUtils

#region Classes
class Keyword:
	const ERROR: String = "<ERROR>"
#endregion

#region Public Static Methods
static func get_validated_column_name(column: SQLColumn) -> String:
	column.validate()
	
	return column.get_validated_name() if column.is_valid() else ""


static func get_validated_column_names(columns: Array[SQLColumn]) -> PackedStringArray:
	var validated_column_names: PackedStringArray
	
	for column: SQLColumn in columns:
		var column_name: String = get_validated_column_name(column)
		
		if not column_name.is_empty():
			validated_column_names.append(column_name)
	
	if validated_column_names.size() != columns.size():
		return PackedStringArray([])
	
	return validated_column_names


static func get_string_definition(text: String, strip_edges: bool = true) -> String:
	var string_definition: String = text.replace("'", "''")
	
	if strip_edges:
		string_definition = string_definition.strip_edges()
	
	return "'%s'" % string_definition


static func get_bool_definition(value: Variant) -> String:
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT:
			return str(int(value))
		
		TYPE_STRING, TYPE_STRING_NAME:
			var string: String = UtilsRegex.sub(UtilsRegex.SUB_ALPHANUMERIC, UtilsText.strip(str(value)).to_lower())
			
			return "1" if string in PackedStringArray([
				"true", "1", "positive", "yes", "on", "t", "y", "enabled", "active"
				]) else "0"
	
	return "0"


static func get_value_definition_by_column_type(value: Variant, column_type: SQLColumn.DataType) -> String:
	match column_type:
		SQLColumn.DataType.BOOLEAN:
			return get_bool_definition(value)
		
		SQLColumn.DataType.INTEGER, SQLColumn.DataType.REAL:
			return str(value)
		
		SQLColumn.DataType.TEXT, SQLColumn.DataType.DATE, SQLColumn.DataType.DATETIME, SQLColumn.DataType.TIME:
			return get_string_definition(str(value))
		
		_:
			return Keyword.ERROR


static func check_value_type_by_column_type(value: Variant, column_type: SQLColumn.DataType) -> bool:
	var value_type: int = typeof(value)
	
	match column_type:
		SQLColumn.DataType.BOOLEAN:
			return value_type in [TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME]
		
		SQLColumn.DataType.INTEGER:
			return value_type == TYPE_INT
		
		SQLColumn.DataType.REAL:
			return value_type == TYPE_FLOAT
		
		SQLColumn.DataType.TEXT:
			return true
		
		SQLColumn.DataType.DATE, SQLColumn.DataType.DATETIME, SQLColumn.DataType.TIME:
			return value_type in [TYPE_STRING, TYPE_STRING_NAME]
		
		_:
			return false
#endregion
