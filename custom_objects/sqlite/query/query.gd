class_name SQLQuery extends SQLResource

#region Enums
enum QueryType {NONE, CREATE_TABLE, CUSTOM, DELETE, INSERT, SELECT, UPDATE, UPSERT}
#endregion

#region Private Variables
var _query_type: QueryType
#endregion

#region Virtual Methods
func _init(query_type: QueryType = QueryType.NONE) -> void:
	super._init(ResourceType.QUERY)
	_query_type = query_type


func _to_string() -> String:
	return "<SQLQuery[%s]>" % [query_type_to_str(_query_type).capitalize()]


func _get_class() -> String:
	return "SQLQuery"
#endregion

#region Public Static Methods
static func get_query_types() -> Array[QueryType]:
	return Array(QueryType.values().slice(1), TYPE_INT, &"", null) as Array[QueryType]


static func query_type_to_str(query_type: QueryType) -> String:
	return UtilsDictionary.enum_to_str(QueryType, query_type)
#endregion

#region Public Methods
func get_query_type() -> QueryType:
	return _query_type
#endregion

#region Private Methods
func _validate() -> bool:
	if _query_type == QueryType.NONE or not _query_type in QueryType.values():
		Log.error("Invalid query type: %d!" % _query_type, _validate)
		return false
	
	return true
#endregion
