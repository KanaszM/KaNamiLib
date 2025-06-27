@tool
class_name ExtendedCheckBox extends CheckBox

#region Private Variables
var _signals: Array[Signal]
#endregion

#region Virtual Methods
func _init() -> void:
	pressed.connect(execute_signals)
#endregion

#region Public Methods
func signal_exists(signal_param: Signal) -> bool:
	return signal_param in _signals


func add_signal(signal_param: Signal, unique: bool = true) -> void:
	if unique and signal_exists(signal_param):
		return
	
	_signals.append(signal_param)


func readd_signal(signal_param: Signal) -> void:
	if signal_exists(signal_param):
		resignal(signal_param)
	
	_signals.append(signal_param)


func resignal(signal_param: Signal) -> void:
	if signal_exists(signal_param):
		Log.warning(resignal, "The signal: '%s' is not registered." % signal_param)
		return
	
	_signals.erase(signal_param)


func reall_signals() -> void:
	_signals.clear()


func execute_signals() -> void:
	for signal_param: Signal in _signals:
		signal_param.emit()
#endregion
