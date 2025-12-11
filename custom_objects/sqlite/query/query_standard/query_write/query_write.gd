class_name SQLQueryWrite extends SQLQueryStandard

#region Enums
enum ConflictClauseType {NONE, IGNORE, ABORT, REPLACE, FAIL, ROLLBACK}
#endregion

#region Exports
@export var confilct_clause_type: ConflictClauseType
#endregion

#region Virtual Methods
func _init(
	query_type: QueryType, table: SQLTable = null, columns: Array[SQLColumn] = [],
	confilct_clause_type_arg: ConflictClauseType = ConflictClauseType.NONE
	) -> void:
		super._init(query_type, table, columns)
		
		if confilct_clause_type_arg != ConflictClauseType.NONE:
			confilct_clause_type = confilct_clause_type_arg


func _get_class() -> String:
	return "SQLQueryWrite"
#endregion

#region Public Static Methods
static func confilct_clause_types() -> Array[ConflictClauseType]:
	return Array(ConflictClauseType.values().slice(1), TYPE_INT, &"", null) as Array[ConflictClauseType]


static func confilct_clause_type_str(confilct_clause_type_arg: ConflictClauseType) -> String:
	return UtilsDictionary.enum_to_str(ConflictClauseType, confilct_clause_type_arg)
#endregion

#region Public Methods
func get_confilct_clause_type() -> ConflictClauseType:
	return confilct_clause_type


func set_conflict_cause_type(confilct_clause_type_arg: ConflictClauseType) -> SQLQueryWrite:
	confilct_clause_type = confilct_clause_type_arg
	return self


func set_or_ignore() -> SQLQueryWrite:
	confilct_clause_type = ConflictClauseType.IGNORE
	return self


func set_or_abort() -> SQLQueryWrite:
	confilct_clause_type = ConflictClauseType.ABORT
	return self


func set_or_replace() -> SQLQueryWrite:
	confilct_clause_type = ConflictClauseType.REPLACE
	return self


func set_or_fail() -> SQLQueryWrite:
	confilct_clause_type = ConflictClauseType.FAIL
	return self


func set_or_rollback() -> SQLQueryWrite:
	confilct_clause_type = ConflictClauseType.ROLLBACK
	return self
#endregion

#region Private Methods
func _get_confilct_clause_type_definition() -> String:
	return "OR %s" % confilct_clause_type_str(confilct_clause_type)
#endregion
