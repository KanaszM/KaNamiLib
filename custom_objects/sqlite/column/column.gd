class_name SQLColumn extends SQLResource

#region Enums
enum DataType {NONE, BLOB, BOOLEAN, DATE, DATETIME, ID, INTEGER, REAL, TEXT, TIME}
enum UniqueType {NONE, ENABLED, GROUPED}
#endregion

#region Constants
const DATA_TYPE_ALIASES: Dictionary[DataType, DataType] = {
	DataType.BOOLEAN: DataType.INTEGER,
	}
#endregion

#region Exports
@export var name: String
@export var not_null: bool
@export var primary_key: bool
@export var unique_type: UniqueType
#endregion

#region Private Variables
var _data_type: DataType
var _validated_name: String
#endregion

#region Virtual Methods
func _init(data_type: DataType = DataType.NONE, name_arg: String = "") -> void:
	super._init(ResourceType.COLUMN)
	
	_data_type = data_type
	name_arg = name_arg.strip_edges()
	
	if not name_arg.is_empty():
		name = name_arg


func _to_string() -> String:
	return "<SQLColumn%s[%s]>" % [data_type_to_str(_data_type).capitalize(), name]


func _get_class() -> String:
	return "SQLColumn"
#endregion

#region Public Static Methods
static func get_data_types() -> Array[DataType]:
	var values: Array = DataType.values()
	values.remove_at(0)
	return Array(values, TYPE_INT, &"", null) as Array[DataType]


static func data_type_to_str(type: DataType) -> String:
	if type in DATA_TYPE_ALIASES:
		type = DATA_TYPE_ALIASES[type]
	
	return UtilsDictionary.enum_to_str(DataType, type)


static func get_unique_types() -> Array[UniqueType]:
	var values: Array = UniqueType.values()
	values.remove_at(0)
	return Array(values, TYPE_INT, &"", null) as Array[UniqueType]


static func unique_type_to_str(type: UniqueType) -> String:
	return UtilsDictionary.enum_to_str(UniqueType, type)
#endregion

#region Public Methods
func set_column_name(name_arg: String) -> SQLColumn:
	name = name_arg.strip_edges()
	return self


func get_data_type() -> DataType:
	return _data_type


func get_validated_name() -> String:
	return _validated_name


func is_not_null() -> bool:
	return not_null


func set_not_null(state: bool = true) -> SQLColumn:
	not_null = state
	return self


func is_primary_key() -> bool:
	return primary_key


func set_primary_key(state: bool = true) -> SQLColumn:
	primary_key = state
	return self


func is_unique() -> bool:
	return unique_type != UniqueType.NONE


func is_unique_grouped() -> bool:
	return unique_type == UniqueType.GROUPED


func set_unique(state: bool = true) -> SQLColumn:
	unique_type = UniqueType.ENABLED if state else UniqueType.NONE
	return self


func set_unique_grouped(state: bool = true) -> SQLColumn:
	unique_type = UniqueType.GROUPED if state else UniqueType.NONE
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	_validated_name = name.strip_edges().to_lower().replace(" ", "_")
	
	if (
		_validated_name.is_empty()
		or not UtilsRegex.is_valid(UtilsRegex.MATCH_ALPHA_START_ALPHANUM, _validated_name)
		):
			Log.error("Invalid column name: '%s'!" % _validated_name, _validate)
			return false
	
	if _data_type == DataType.NONE or not _data_type in DataType.values():
		Log.error("Invalid column data type: %d!" % _data_type, _validate)
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray = PackedStringArray([])
	
	definitions.append_array(PackedStringArray([
		_validated_name,
		data_type_to_str(_data_type),
		]))
	
	var constraints_list: PackedStringArray
	
	if not_null:
		constraints_list.append("NOT NULL")
	
	if primary_key:
		constraints_list.append("PRIMARY KEY")
	
	if unique_type == UniqueType.ENABLED:
		constraints_list.append("UNIQUE")
	
	if not constraints_list.is_empty():
		definitions.append(" ".join(constraints_list))
	
	return " ".join(definitions)
#endregion
