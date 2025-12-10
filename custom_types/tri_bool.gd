class_name TriBool

#region Enums
enum State {INVALID = -1, FALSE = 0, TRUE = 1}
#endregion

#region Private Variables
var _state: State
#endregion

#region Virtual Methods
func _init(state: State = State.INVALID) -> void:
	_state = state


func _to_string() -> String:
	return "<TriBool[%d]>" % UtilsDictionary.enum_to_str(State, _state)
#endregion

#region Public Methods
func get_state() -> State:
	return _state


func is_true() -> bool:
	return _state == State.TRUE


func is_false() -> bool:
	return _state == State.FALSE


func is_invalid() -> bool:
	return _state == State.INVALID


func set_true() -> TriBool:
	_state = State.TRUE
	return self


func set_false() -> TriBool:
	_state = State.FALSE
	return self


func set_invalid() -> TriBool:
	_state = State.INVALID
	return self


func set_bool(state: bool) -> TriBool:
	_state = State.TRUE if state else State.FALSE
	return self


func to_bool(default_invalid: bool = false) -> bool:
	if _state == State.INVALID:
		return default_invalid
	
	return _state == State.TRUE
#endregion
