@tool
class_name QuickTweenInt extends QuickTween

#region Exports
@export var value_target: int
@export var value_from: int
#endregion

#region Virtual Methods
func _ready() -> void:
	_type = Type.INT
#endregion

#region Getter Methods
func get_target_value() -> int:
	return value_target


func get_from_value() -> int:
	return value_from
#endregion
