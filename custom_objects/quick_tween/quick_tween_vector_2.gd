@tool
class_name QuickTweenVector2 extends QuickTween

#region Exports
@export var value_target: Vector2
@export var value_from: Vector2
#endregion

#region Virtual Methods
func _ready() -> void:
	_type = Type.VECTOR_2
#endregion

#region Getter Methods
func get_target_value() -> Vector2:
	return value_target


func get_from_value() -> Vector2:
	return value_from
#endregion
