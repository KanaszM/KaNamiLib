@tool
class_name QuickTweenPlayer extends Node

#region Exports
@export var parallel: bool
@export var restart_on_animation_request: bool = true
@export_tool_button("Animate") var callback_play: Callable = play
#endregion

#region Signals
signal started
signal finished
#endregion

#region Private Variables
var _tween: Tween
#endregion

#region Public Methods
func play() -> void:
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
	
	_tween = create_tween()
	_tween.finished.connect(func_on_tween_finished)
	
	if parallel:
		_tween.set_parallel()
	
	for quick_tween: QuickTween in get_quick_tweens():
		quick_tween._play_with_custom_tween(_tween)


func get_quick_tweens() -> Array[QuickTween]:
	var quick_tweens: Array[QuickTween]
	
	for node: Node in get_children():
		if node is QuickTween:
			quick_tweens.append(node as QuickTween)
	
	return quick_tweens
#endregion
