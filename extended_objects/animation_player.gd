#@tool
class_name ExtendedAnimationPlayer 
extends AnimationPlayer

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var one_shot: bool: set = _set_one_shot
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
func _on_animation_finished(_animation_name: StringName) -> void:
	queue_free()
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_one_shot(arg: bool) -> void:
	one_shot = arg
	UtilsSignal.connect_safe_if(animation_finished, _on_animation_finished, one_shot)
#endregion

#region Getter Methods
#endregion
