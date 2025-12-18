@tool
class_name QuickTweenFloat extends QuickTween

#region Exports
@export var value_target: float
@export var value_from: float
#endregion

#region Virtual Methods
func _ready() -> void:
	_type = Type.FLOAT
#endregion

#region Getter Methods
func get_target_value() -> float:
	return value_target


func get_from_value() -> float:
	return value_from
#endregion
