#@tool
class_name _DebugToolsInputKeyMap
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
var _map: Dictionary[Callable, bool]
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
func add(callback: Callable, deferred: bool) -> void:
	_map[callback] = deferred


func remove(callback: Callable) -> void:
	_map.erase(callback)


func is_empty() -> bool:
	return _map.is_empty()


func execute() -> void:
	for callback: Callable in _map:
		if _map[callback]:
			callback.call_deferred()
		
		else:
			callback.call()
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
