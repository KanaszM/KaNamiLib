@tool
class_name ExtendedProgressBar extends ProgressBar

#region Signals
signal smooth_target_reached
#endregion

#region Constants
const SMOOTHING_THRESHOLD: float = 0.005
#endregion

#region Export Variables
@export_group("Smoothing", "smoothing_")
@export var smoothing_enabled: bool: set = _set_smoothing_enabled
@export var smoothing_duration: float = 0.25: set = _set_smoothing_duration
@export var smoothing_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var smoothing_transition: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
#endregion

#region Private Variables
var _smooth_target_value: float
var _smooth_current_value: float
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

#region Theme Methods
func get_font_size() -> int:
	return get_theme_font_size(&"font_size")


func get_background_style() -> StyleBox:
	return get_theme_stylebox(&"background")


func get_fill_style() -> StyleBox:
	return get_theme_stylebox(&"fill")


func set_font_size(font_size: int) -> void:
	add_theme_font_size_override(&"font_size", font_size)


func set_background_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"background", style)


func set_fill_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"fill", style)
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
