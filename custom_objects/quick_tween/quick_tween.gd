@tool
class_name QuickTween extends Node

#region Exports
@export var node: Node
@export var property: StringName
@export var value_target: Variant
@export var value_from: Variant
@export_range(0.0, 100.0, 0.001, "or_greater") var duration: float
@export_range(0.0, 100.0, 0.001, "or_greater") var delay: float
@export var transition_type: Tween.TransitionType
@export var ease_type: Tween.EaseType
@export var parallel: bool
@export var as_relative: bool
@export var restart_on_animation_request: bool = true
@export_tool_button("Animate") var callback_animate: Callable = animate
@export_tool_button("Animate From Player") var callback_animate_from_parent: Callable = animate_from_parent
#endregion

#region Signals
signal started
signal finished
#endregion

#region Private Variables
var _tween: Tween
#endregion

#region Public Methods
func animate() -> void:
	if node == null:
		Log.error("Node reference not provided!", animate)
		return
	
	property = property.strip_edges()
	
	if property.is_empty():
		Log.error("No property was provided!", animate)
		return
	
	if value_target == null:
		Log.error("No target value was provided!", animate)
		return
	
	var tween_is_available: bool = _tween != null
	
	if restart_on_animation_request:
		if tween_is_available:
			_tween.kill()
			_tween = null
	
	else:
		if tween_is_available:
			return
	
	var func_on_tween_finished: Callable = func() -> void:
		_tween = null
		finished.emit()
	
	started.emit()
	
	_tween = node.create_tween()
	_tween.finished.connect(func_on_tween_finished)
	
	if parallel:
		_tween.parallel()
	
	_animate_with_custom_tween(_tween)


func animate_from_parent() -> void:
	var quick_tween_player: QuickTweenPlayer = get_quick_tween_player()
	
	if quick_tween_player != null:
		quick_tween_player.animate()


func get_quick_tween_player() -> QuickTweenPlayer:
	var parent: Node = get_parent()
	
	return (parent as QuickTweenPlayer) if parent is QuickTweenPlayer else null


func is_animating() -> bool:
	return _tween != null
#endregion

#region Private Methods
func _animate_with_custom_tween(tween: Tween) -> void:
	if tween == null:
		Log.error("The provided Tween reference is null!", _animate_with_custom_tween)
		return
	
	if node == null:
		Log.error("Node reference not provided!", _animate_with_custom_tween)
		return
	
	property = property.strip_edges()
	
	if property.is_empty():
		Log.error("No property was provided!", _animate_with_custom_tween)
		return
	
	if value_target == null:
		Log.error("No target value was provided!", _animate_with_custom_tween)
		return
	
	var tweener: PropertyTweener = tween.tween_property(
		node, NodePath(property), value_target, duration
		).set_trans(transition_type).set_ease(ease_type)
	
	if value_from != null:
		tweener.from(value_from)
	
	if delay > 0.0:
		tweener.set_delay(delay)
	
	if as_relative:
		tweener.as_relative()
#endregion
