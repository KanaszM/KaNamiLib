"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsSignal


static func interrupt(signal_arg: Signal, signal_callback: Callable, callback: Callable, args: Array = []) -> void:
	var is_initially_connected: bool = signal_arg.is_connected(signal_callback)
	
	if is_initially_connected:
		signal_arg.disconnect(signal_callback)
	
	callback.callv(args)
	
	if is_initially_connected:
		signal_arg.connect(signal_callback)


static func connect_safe(signal_arg: Signal, signal_callback: Callable) -> bool:
	if not signal_arg.is_connected(signal_callback):
		return signal_arg.connect(signal_callback) == OK
	
	return true


static func connect_safe_and_call(signal_arg: Signal, signal_callback: Callable, args: Array = []) -> bool:
	if not connect_safe(signal_arg, signal_callback):
		return false
	
	signal_callback.callv(args)
	
	return true

static func connect_safe_one_shot(signal_arg: Signal, signal_callback: Callable) -> bool:
	if not signal_arg.is_connected(signal_callback):
		return signal_arg.connect(signal_callback, CONNECT_ONE_SHOT) == OK
	
	return true


static func connect_safe_toggle(signal_arg: Signal, signal_callback: Callable) -> bool:
	if not signal_arg.is_connected(signal_callback):
		return signal_arg.connect(signal_callback) == OK
	
	if signal_arg.is_connected(signal_callback):
		signal_arg.disconnect(signal_callback)
	
	return true


static func connect_safe_if(signal_arg: Signal, signal_callback: Callable, condition: bool) -> bool:
	if condition and not signal_arg.is_connected(signal_callback):
		return signal_arg.connect(signal_callback) == OK
	
	if not condition and signal_arg.is_connected(signal_callback):
		signal_arg.disconnect(signal_callback)
	
	return true


static func disconnect_safe(signal_arg: Signal, signal_callback: Callable) -> bool:
	if not signal_arg.is_connected(signal_callback):
		return false
	
	signal_arg.disconnect(signal_callback)
	
	return true


static func connect_and_call(signal_arg: Signal, signal_callback: Callable, args: Array = []) -> bool:
	if signal_arg.connect(signal_callback) != OK:
		return false
	
	signal_callback.callv(args)
	
	return true
