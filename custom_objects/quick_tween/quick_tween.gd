@tool
class_name QuickTween extends Node

#region Enums
enum Type {VARIANT, FLOAT, INT, VECTOR_2, VECTOR_3}
#endregion

#region Exports
@export var node: Node
@export var property: StringName
@export_range(0.0, 100.0, 0.001, "or_greater") var duration: float
@export_range(0.0, 100.0, 0.001, "or_greater") var delay: float
@export var transition_type: Tween.TransitionType
@export var ease_type: Tween.EaseType
@export var parallel: bool
@export var as_relative: bool
@export var restart_on_animation_request: bool = true
@export_tool_button("Play") var callback_0: Callable = play
@export_tool_button("Play From Player") var callback_1: Callable = play_from_quick_tween_player_parent
#endregion

#region Signals
signal started
signal finished
#endregion

#region Private Variables
var _tween: Tween
var _type: Type

var _value_target: Variant: get = get_target_value
var _value_from: Variant: get = get_from_value
#endregion

#region Virtual Methods
func _to_string() -> String:
	return "QuickTween%s" % type_to_str(_type)
#endregion

#region Public Static Methods
static func get_types() -> Array[Type]:
	return Array(Type.values().slice(1), TYPE_INT, &"", null) as Array[Type]


static func type_to_str(type: Type) -> String:
	return UtilsDictionary.enum_to_str(Type, type)
#endregion

#region Public Methods
func play() -> void:
	if node == null:
		Log.error("Node reference not provided!", play)
		return
	
	property = property.strip_edges()
	
	if property.is_empty():
		Log.error("No property was provided!", play)
		return
	
	if _value_target == null:
		Log.error("No target value was provided!", play)
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
	
	_play_with_custom_tween(_tween)


func play_from_quick_tween_player_parent() -> void:
	var quick_tween_player: QuickTweenPlayer = get_quick_tween_player()
	
	if quick_tween_player != null:
		quick_tween_player.play()


func get_quick_tween_player() -> QuickTweenPlayer:
	var parent: Node = get_parent()
	
	return (parent as QuickTweenPlayer) if parent is QuickTweenPlayer else null


func is_animating() -> bool:
	return _tween != null
#endregion

#region Private Methods
func _play_with_custom_tween(tween: Tween) -> void:
	if tween == null:
		Log.error("The provided Tween reference is null!", _play_with_custom_tween)
		return
	
	if node == null:
		Log.error("Node reference not provided!", _play_with_custom_tween)
		return
	
	property = property.strip_edges()
	
	if property.is_empty():
		Log.error("No property was provided!", _play_with_custom_tween)
		return
	
	if _value_target == null:
		Log.error("No target value was provided!", _play_with_custom_tween)
		return
	
	var tweener: PropertyTweener = tween.tween_property(
		node, NodePath(property), _value_target, duration
		).set_trans(transition_type).set_ease(ease_type)
	
	if _value_from != null:
		tweener.from(_value_from)
	
	if delay > 0.0:
		tweener.set_delay(delay)
	
	if as_relative:
		tweener.as_relative()
#endregion

#region Getter Methods
func get_target_value() -> Variant:
	return _value_target


func get_from_value() -> Variant:
	return _value_from
#endregion
