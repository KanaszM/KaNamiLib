class_name ExtendedAnimationPlayer extends AnimationPlayer

#region Export Variables
@export var one_shot: bool: set = _set_one_shot
#endregion

#region Signal Callbacks
func _on_animation_finished(_animation_name: StringName) -> void:
	queue_free()
#endregion

#region Setter Methods
func _set_one_shot(arg: bool) -> void:
	one_shot = arg
	UtilsSignal.connect_safe_if(animation_finished, _on_animation_finished, one_shot)
#endregion
