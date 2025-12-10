class_name SQLFunctions

#region Public Static Methods
static func get_all_table_names(manager: SQLManager) -> PackedStringArray:
	var table_names: PackedStringArray
	var query: SQLQueryCustom = SQLQueryCustom.new(
		"SELECT name FROM sqlite_master WHERE type = 'table' AND name <> 'sqlite_sequence'"
		)
	var result: SQLResult = _execute(manager, query)
	
	if result == null:
		return table_names
	
	for row: SQLResultRow in result.get_rows():
		table_names.append(str(row.get_first_value()))
	
	return table_names


static func table_exists(manager: SQLManager, table: SQLTable) -> bool:
	if table == null:
		Log.error("The provided SQLTable reference is null!", table_exists)
		return false
	
	table.validate()
	
	if not table.is_valid():
		Log.error("The provided table: '%s', is invalid!" % table.name, table_exists)
		return false
	
	var query: SQLQueryCustom = SQLQueryCustom.new(
		"SELECT name FROM sqlite_master WHERE type = 'table' AND name = '%s'" % table.get_validated_name()
		)
	var result: SQLResult = _execute(manager, query)
	
	if result == null:
		return false
	
	return result.get_first_row() != null


static func tables_exists(manager: SQLManager, tables: Array[SQLTable]) -> bool:
	if tables.is_empty():
		Log.error("No tables were provided!", tables_exists)
		return false
	
	var validated_table_names: PackedStringArray
	
	for table: SQLTable in tables:
		if table == null:
			Log.error("The provided SQLTable reference is null!", tables_exists)
		
		else:
			table.validate()
			
			if table.is_valid():
				validated_table_names.append("'%s'" % table.get_validated_name())
			
			else:
				Log.error("The provided table: '%s', is invalid!" % table.name, tables_exists)
	
	if validated_table_names.size() != tables.size():
		Log.error("Not all provided tables are valid!", tables_exists)
		return false
	
	var query: SQLQueryCustom = SQLQueryCustom.new(
		"SELECT name FROM sqlite_master WHERE type = 'table' AND name IN (%s)" % ", ".join(validated_table_names)
		)
	var result: SQLResult = _execute(manager, query)
	
	if result == null:
		return false
	
	return result.get_rows().size() == tables.size()
#endregion

#region Private Static Methods
static func _execute(manager: SQLManager, query: SQLQuery) -> SQLResult:
	if manager == null:
		Log.error("The provided SQLManager reference is null!", _execute)
		return null
	
	var result: SQLResult = manager.execute_query(query)
	
	if not result.is_valid():
		Log.error("Invalid result!", _execute)
		return null
	
	return result
#endregion
