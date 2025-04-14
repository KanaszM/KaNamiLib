@tool
class_name ExtendedProgressBars
extends ProgressBar

#region Signals
signal smooth_target_reached
#endregion

#region Enums
#endregion

#region Constants
const SMOOTHING_THRESHOLD: float = 0.005
#endregion

#region Export Variables
@export_group("Smoothing", "smoothing_")
@export var smoothing_enabled: bool = true: set = _set_smoothing_enabled
@export var smoothing_duration: float = 0.25: set = _set_smoothing_duration
@export var smoothing_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var smoothing_transition: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
#endregion

#region Public Variables
#endregion

#region Private Variables
var _smooth_target_value: float
var _smooth_current_value: float
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _set(property: StringName, new_value: Variant) -> bool:
	var is_changed: bool = true
	
	match property:
		&"value":
			if smoothing_enabled:
				_smooth_target_value = new_value
				set_process(true)
			
			else:
				value = new_value
			
		_:
			is_changed = false
	
	return is_changed


func _ready() -> void:
	_set_smoothing_enabled(smoothing_enabled)


func _process(_delta: float) -> void:
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(self, ^"_smooth_current_value", _smooth_target_value, smoothing_duration)
	tween.set_ease(smoothing_ease)
	tween.set_trans(smoothing_transition)
	
	value = _smooth_current_value
	
	if absf(_smooth_current_value - _smooth_target_value) < SMOOTHING_THRESHOLD:
		smooth_target_reached.emit()
		set_process(false)
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_smoothing_enabled(arg: bool) -> void:
	smoothing_enabled = arg
	
	_smooth_target_value = value
	_smooth_current_value = value
	
	set_process(false)


func _set_smoothing_duration(arg: float) -> void:
	smoothing_enabled = maxf(0.0, arg)
#endregion

#region Getter Methods
#endregion
