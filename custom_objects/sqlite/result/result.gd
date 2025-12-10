class_name SQLResult

#region Private Variables
var _is_valid: bool
var _message: String
var _rows: Array[SQLResultRow]
#endregion

#region Virtual Methods
func _init(is_valid_arg: bool = false, message_arg: String = "", rows_arg: Array[SQLResultRow] = []) -> void:
	_is_valid = is_valid_arg
	
	message_arg = message_arg.strip_edges()
	
	if not message_arg.is_empty():
		_message = message_arg
	
	if not rows_arg.is_empty():
		_rows = rows_arg


func _to_string() -> String:
	return "<SQLResult[%s][%d]>" % [_is_valid, _rows.size()]


func _get_class() -> String:
	return "SQLResult"
#endregion

#region Public Methods
func set_is_valid(state: bool = true) -> SQLResult:
	_is_valid = state
	return self


func set_message(message: String) -> SQLResult:
	_message = message.strip_edges()
	return self


func is_valid() -> bool:
	return _is_valid


func get_message() -> String:
	return _message


func get_rows() -> Array[SQLResultRow]:
	return _rows


func get_first_row() -> SQLResultRow:
	return null if _rows.is_empty() else _rows[0]


func append_row(row: SQLResultRow) -> SQLResult:
	if not row.is_valid():
		Log.error("The provided row: %s, is invalid!", append_row)
		return self
	
	_rows.append(row)
	return self


func append_rows(rows: Array[SQLResultRow]) -> SQLResult:
	for row: SQLResultRow in rows:
		append_row(row)
	
	return self


func set_rows(rows: Array[SQLResultRow]) -> SQLResult:
	var rows_are_valid: bool = true
	
	for row: SQLResultRow in rows:
		if not row.is_valid():
			Log.error("The provided row: %s, is invalid!", append_row)
			rows_are_valid = false
	
	if not rows_are_valid:
		return self
	
	_rows = rows
	return self
#endregion
