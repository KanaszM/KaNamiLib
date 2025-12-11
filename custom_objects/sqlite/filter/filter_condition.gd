class_name SQLFilterCondition extends SQLResource

#region Enums
enum LogicalOperator {NONE, AND, OR}
enum ComparisonOperator {
	NONE, EQUAL_TO, LESS_THAN, GREATER_THAN, LESS_THAN_OR_EQUAL_TO, GREATER_THAN_OR_EQUAL_TO, IN,
	LIKE_STARTS, LIKE_ENDS, LIKE_ANY, BETWEEN,
	}
enum ComparisonOperatorValueType {NONE, SINGLE, DOUBLE, MULTIPLE}
#endregion

#region Exports
@export var logical_operator: LogicalOperator = LogicalOperator.AND
@export var column: SQLColumn
@export var comparison_operator: ComparisonOperator = ComparisonOperator.EQUAL_TO
@export var negative: bool
@export var group_id: int
#endregion

#region Private Variables
var _parameters: SQLParameters
var _validated_column_name: String
#endregion

#region Virtual Methods
func _init(
	logical_operator_arg: LogicalOperator = LogicalOperator.NONE, column_arg: SQLColumn = null,
	comparison_operator_arg: ComparisonOperator = ComparisonOperator.NONE, parameters: SQLParameters = null,
	) -> void:
		super._init(ResourceType.CONDITION)
		
		if logical_operator_arg != LogicalOperator.NONE:
			logical_operator = logical_operator_arg
		
		if column_arg != null:
			column = column_arg
		
		if comparison_operator_arg != ComparisonOperator.NONE:
			comparison_operator = comparison_operator_arg
		
		if parameters != null:
			_parameters = parameters


func _to_string() -> String:
	return "<SQLFilterCondition[%s][%s][%s]>" % [
		logical_operator_to_str(logical_operator),
		("" if column == null else column.name),
		comparison_operator_to_str(comparison_operator)
		]


func _get_class() -> String:
	return "SQLFilterCondition"
#endregion

#region Public Static Methods
static func get_logical_operators() -> Array[LogicalOperator]:
	return Array(LogicalOperator.values().slice(1), TYPE_INT, &"", null) as Array[LogicalOperator]


static func get_comparison_operators() -> Array[ComparisonOperator]:
	return Array(ComparisonOperator.values().slice(1), TYPE_INT, &"", null) as Array[ComparisonOperator]


static func logical_operator_to_str(logical_operator_arg: LogicalOperator) -> String:
	return UtilsDictionary.enum_to_str(LogicalOperator, logical_operator_arg)


static func comparison_operator_to_str(comparison_operator_arg: ComparisonOperator) -> String:
	return UtilsDictionary.enum_to_str(ComparisonOperator, comparison_operator_arg)


static func get_comparison_operator_value_type(
	comparison_operator_arg: ComparisonOperator
	) -> ComparisonOperatorValueType:
		match comparison_operator_arg:
			ComparisonOperator.EQUAL_TO: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.LESS_THAN: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.GREATER_THAN: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.LESS_THAN_OR_EQUAL_TO: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.GREATER_THAN_OR_EQUAL_TO: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.IN: return ComparisonOperatorValueType.MULTIPLE
			ComparisonOperator.LIKE_STARTS: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.LIKE_ENDS: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.LIKE_ANY: return ComparisonOperatorValueType.SINGLE
			ComparisonOperator.BETWEEN: return ComparisonOperatorValueType.DOUBLE
			_: return ComparisonOperatorValueType.NONE


static func strip_logical_operator_from_validated_condition(validated_condition: String) -> String:
	var logical_and: String = "%s " % logical_operator_to_str(LogicalOperator.AND)
	
	if validated_condition.begins_with(logical_and):
		return validated_condition.trim_prefix(logical_and)
	
	var logical_or: String = "%s " % logical_operator_to_str(LogicalOperator.OR)
	
	if validated_condition.begins_with(logical_or):
		return validated_condition.trim_prefix(logical_or)
	
	return validated_condition


static func split_logical_operator_from_validated_condition(validated_condition: String) -> PackedStringArray:
	var logical_and: String = "%s " % logical_operator_to_str(LogicalOperator.AND)
	
	if validated_condition.begins_with(logical_and):
		return PackedStringArray([logical_and, validated_condition.trim_prefix(logical_and)])
	
	var logical_or: String = "%s " % logical_operator_to_str(LogicalOperator.OR)
	
	if validated_condition.begins_with(logical_or):
		return PackedStringArray([logical_or, validated_condition.trim_prefix(logical_or)])
	
	return PackedStringArray(["", validated_condition])
#endregion

#region Public Methods
func get_logical_operator() -> LogicalOperator:
	return logical_operator


func set_logical_operator(logical_operator_arg: LogicalOperator) -> SQLFilterCondition:
	logical_operator = logical_operator_arg
	return self


func set_and() -> SQLFilterCondition:
	logical_operator = LogicalOperator.AND
	return self


func set_or() -> SQLFilterCondition:
	logical_operator = LogicalOperator.OR
	return self


func get_column() -> SQLColumn:
	return column


func set_column(column_arg: SQLColumn) -> SQLFilterCondition:
	column = column_arg
	return self


func get_comparison_operator() -> ComparisonOperator:
	return comparison_operator


func set_comparison_operator(comparison_operator_arg: ComparisonOperator) -> SQLFilterCondition:
	comparison_operator = comparison_operator_arg
	return self


func set_equal_to(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.EQUAL_TO
	return set_value(value)


func set_less_than(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.LESS_THAN
	return set_value(value)


func set_greater_than(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.GREATER_THAN
	return set_value(value)


func set_less_than_or_equal_to(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.LESS_THAN_OR_EQUAL_TO
	return set_value(value)


func set_greater_than_or_equal_to(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.GREATER_THAN_OR_EQUAL_TO
	return set_value(value)


func set_in(values: Array[Variant], single_column_comparison: bool = true) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.IN
	return set_values(values, single_column_comparison)


func set_like_starts(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.LIKE_STARTS
	return set_value(value)


func set_like_ends(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.LIKE_ENDS
	return set_value(value)


func set_like_any(value: Variant) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.LIKE_ANY
	return set_value(value)


func set_between(values: Array[Variant], single_column_comparison: bool = true) -> SQLFilterCondition:
	comparison_operator = ComparisonOperator.BETWEEN
	return set_values(values, single_column_comparison)


func set_parameters(parameters: SQLParameters) -> SQLFilterCondition:
	_parameters = parameters
	return self


func set_value(value: Variant) -> SQLFilterCondition:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.set_value(value)
	return self


func set_values(values: Array[Variant], single_column_comparison: bool = false) -> SQLFilterCondition:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.set_values(values)
	_parameters.set_single_column_comparison(single_column_comparison)
	return self


func append_value(value: Variant) -> SQLFilterCondition:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.append_value(value)
	return self


func append_values(values: Array[Variant], single_column_comparison: bool = false) -> SQLFilterCondition:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	_parameters.append_values(values)
	_parameters.set_single_column_comparison(single_column_comparison)
	return self


func set_column_and_value(column_arg: SQLColumn, value: Variant) -> SQLFilterCondition:
	if _parameters == null:
		_parameters = SQLParameters.new()
	
	column = column_arg
	_parameters.set_value(value)
	return self


func is_negative() -> bool:
	return negative


func set_negative(state: bool = true) -> SQLFilterCondition:
	negative = state
	return self


func get_group_id() -> int:
	return group_id


func set_group_id(group_id_arg: int) -> SQLFilterCondition:
	group_id = group_id_arg
	return self
#endregion

#region Private Methods
func _get_comparison_operator_definition(comparison_operator_arg: ComparisonOperator) -> String:
	match comparison_operator_arg:
		ComparisonOperator.EQUAL_TO when not negative: return "= %s"
		ComparisonOperator.EQUAL_TO when negative: return "<> %s"
		ComparisonOperator.LESS_THAN: return "< %s"
		ComparisonOperator.GREATER_THAN: return "> %s"
		ComparisonOperator.LESS_THAN_OR_EQUAL_TO: return "<= %s"
		ComparisonOperator.GREATER_THAN_OR_EQUAL_TO: return ">= %s"
		ComparisonOperator.IN when not negative: return "IN (%s)"
		ComparisonOperator.IN when negative: return "NOT IN (%s)"
		ComparisonOperator.LIKE_STARTS: return "LIKE '%s%%'"
		ComparisonOperator.LIKE_ENDS: return "LIKE '%%%s'"
		ComparisonOperator.LIKE_ANY: return "LIKE '%%%s%%'"
		ComparisonOperator.BETWEEN when not negative: return "BETWEEN %s AND %s"
		ComparisonOperator.BETWEEN when negative: return "NOT BETWEEN %s AND %s"
		_: return ""


func _validate() -> bool:
	if logical_operator == LogicalOperator.NONE or not logical_operator in LogicalOperator.values():
		Log.error("Invalid logical operator type: %d!" % logical_operator, _validate)
		return false
	
	if comparison_operator == ComparisonOperator.NONE or not comparison_operator in ComparisonOperator.values():
		Log.error("Invalid comparison operator type: %d!" % comparison_operator, _validate)
		return false
	
	if column == null:
		Log.error("No table was provided!", _validate)
		return false
	
	column.validate()
	
	if not column.is_valid():
		Log.error("The provided column is invalid!", _validate)
		return false
	
	if _parameters == null:
		Log.error("No parameters were provided! Column: '%s'." % column.name, _validate)
		return false
	
	if not _parameters.validate([column]):
		Log.error(
			"The provided parameters: %s, or columns are invalid! Column: '%s'." % [_parameters, column.name], _validate
			)
	
	_validated_column_name = SQLUtils.get_validated_column_name(column)
	
	if _validated_column_name.is_empty():
		Log.error("Not all provided columns are valid! Column: '%s'." % column.name, _validate)
		return false
	
	var validated_values: PackedStringArray = _parameters.get_validated_values()
	var validated_values_count: int = validated_values.size()
	var func_log_invalid_comparison_operator: Callable = func(specification: String) -> void:
		Log.error(
			"Parameters out-of-bounds! Expected: %s for comparison of type: '%s'. Column: '%s'." % [
				specification, comparison_operator_to_str(comparison_operator), column.name
				],
			_validate
			)
	
	match get_comparison_operator_value_type(comparison_operator):
		ComparisonOperatorValueType.SINGLE:
			if validated_values_count != 1:
				func_log_invalid_comparison_operator.call("one value")
				return false
		
		ComparisonOperatorValueType.DOUBLE:
			if validated_values_count != 2:
				func_log_invalid_comparison_operator.call("two values")
				return false
		
		ComparisonOperatorValueType.MULTIPLE:
			if validated_values_count == 0:
				func_log_invalid_comparison_operator.call("one or more values")
				return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var comparison_operator_definition: String = _get_comparison_operator_definition(comparison_operator)
	var validated_values: PackedStringArray = _parameters.get_validated_values()
	var value_definition: String
	
	match get_comparison_operator_value_type(comparison_operator):
		ComparisonOperatorValueType.SINGLE:
			if comparison_operator in [
				ComparisonOperator.LIKE_STARTS, ComparisonOperator.LIKE_ENDS, ComparisonOperator.LIKE_ANY
				]:
					if validated_values[0].begins_with("'") and validated_values[0].ends_with("'"):
						validated_values[0] = validated_values[0].trim_prefix("'").trim_suffix("'")
			
			value_definition = comparison_operator_definition % validated_values[0]
		
		ComparisonOperatorValueType.DOUBLE:
			value_definition = comparison_operator_definition % [validated_values[0], validated_values[1]]
		
		ComparisonOperatorValueType.MULTIPLE:
			value_definition = comparison_operator_definition % ", ".join(validated_values)
	
	definitions.append_array(PackedStringArray([
		logical_operator_to_str(logical_operator),
		_validated_column_name,
		value_definition,
		]))
	
	return " ".join(definitions)
#endregion
