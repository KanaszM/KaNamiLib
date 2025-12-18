@tool
class_name QuickTweenVector3 extends QuickTween

#region Exports
@export var value_target: Vector3
@export var value_from: Vector3
#endregion

#region Virtual Methods
func _ready() -> void:
	_type = Type.VECTOR_3
#endregion

#region Getter Methods
func get_target_value() -> Vector3:
	return value_target


func get_from_value() -> Vector3:
	return value_from
#endregion
