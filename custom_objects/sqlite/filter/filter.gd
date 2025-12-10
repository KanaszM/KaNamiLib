class_name SQLFilter extends SQLResource

#region Exports
@export var conditions: Array[SQLFilterCondition]
#endregion

#region Private Variables
var _grouped_validated_conditions: Dictionary[int, PackedStringArray]
#endregion

#region Virtual Methods
func _init(conditions_arg: Array[SQLFilterCondition] = []) -> void:
	super._init(ResourceType.FILTER)
	
	if not conditions_arg.is_empty():
		conditions = conditions_arg


func _to_string() -> String:
	return "<SQLFilter[%d][%d]>" % [get_instance_id(), conditions.size()]


func _get_class() -> String:
	return "SQLFilter"
#endregion

#region Public Methods
func get_conditions() -> Array[SQLFilterCondition]:
	return conditions


func set_condition(conditions_arg: SQLFilterCondition) -> SQLFilter:
	conditions = [conditions_arg]
	return self


func set_conditions(conditions_arg: Array[SQLFilterCondition]) -> SQLFilter:
	conditions = conditions_arg
	return self


func append_condition(condition: SQLFilterCondition) -> SQLFilter:
	conditions.append(condition)
	return self


func append_conditions(conditions_arg: Array[SQLFilterCondition]) -> SQLFilter:
	conditions.append_array(conditions_arg)
	return self
#endregion

#region Private Methods
func _validate() -> bool:
	if conditions.is_empty():
		Log.error("Not conditions were provided!", _validate)
		return false
	
	_grouped_validated_conditions.clear()
	
	var valid_conditions_count: int = 0
	
	for condition: SQLFilterCondition in conditions:
		condition.validate()
		
		if condition.is_valid():
			var condition_group_id: int = condition.get_group_id()
			var condition_definition: String = condition.get_definition()
			
			valid_conditions_count += 1
			
			if not condition_group_id in _grouped_validated_conditions:
				_grouped_validated_conditions[condition_group_id] = PackedStringArray([])
			
			_grouped_validated_conditions[condition_group_id].append(condition_definition)
		
		else:
			Log.error("The provided condition: %s on filter: %s, is invalid!" % [condition, self], _validate)
	
	if valid_conditions_count != conditions.size():
		Log.error("Not all provided conditions are valid on filter: %s!" % self, _validate)
		return false
	
	return true


func _get_definition() -> String:
	var definitions: PackedStringArray
	var condition_group_ids_count: int = 0
	
	definitions.append("WHERE")
	
	for condition_group_id: int in _grouped_validated_conditions:
		var validated_conditions: PackedStringArray = _grouped_validated_conditions[condition_group_id]
		var group_condition: String
		var is_not_the_first_group_id: bool = condition_group_ids_count != 0
		
		if validated_conditions.is_empty():
			continue
		
		if definitions.size() == 1 or is_not_the_first_group_id:
			var split: PackedStringArray = SQLFilterCondition.split_logical_operator_from_validated_condition(
				validated_conditions[0]
				)
			
			if is_not_the_first_group_id:
				group_condition = split[0]
			
			validated_conditions[0] = split[1]
		
		definitions.append("%s(%s)" % [group_condition, " ".join(validated_conditions)])
		condition_group_ids_count += 1
	
	return " ".join(definitions)
#endregion
