"""
# Version 1.0.0 (03-Apr-2025):
	- Reviewed release;
"""

#@tool
class_name DebugToolsPing
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
const DEFAULT_MICROSECONDS_PER_SECOND: float = 1000000.0
const DEFAULT_PREFIX: String = "Time spent: "
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
var _start_value: float
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
func start() -> void:
	_start_value = Time.get_ticks_usec()


func stop(
	print_result: bool = true,
	print_ping_value_only: bool = false,
	prefix: String = DEFAULT_PREFIX,
	microseconds_per_second: float = DEFAULT_MICROSECONDS_PER_SECOND,
	) -> float:
		if _start_value == 0.0:
			return 0.0
		
		var end_value: float = Time.get_ticks_usec()
		var result: float = (end_value - _start_value) / microseconds_per_second
		
		if print_result:
			print(str(result) if print_ping_value_only else ("%s%f" % [prefix, result]))
		
		return result
#endregion

#region Private Methods
#endregion

#region Static Methods
static func measure_callback(
	callback: Callable,
	print_callback_result: bool = false,
	print_ping_result: bool = true,
	print_ping_value_only: bool = false,
	prefix: String = DEFAULT_PREFIX,
	microseconds_per_second: float = DEFAULT_MICROSECONDS_PER_SECOND,
	) -> float:
		var ping: DebugToolsPing = DebugToolsPing.new()
		
		ping.start()
		
		if print_callback_result:
			print(callback.call())
		
		else:
			callback.call()
		
		return ping.stop(print_ping_result, print_ping_value_only, prefix, microseconds_per_second)


static func measure_callback_result_average(
	callback: Callable,
	iteration_count: int,
	print_measure_result: bool = true,
	prefix: String = DEFAULT_PREFIX,
	microseconds_per_second: float = DEFAULT_MICROSECONDS_PER_SECOND,
	) -> float:
		var ping: DebugToolsPing = DebugToolsPing.new()
		var results: PackedFloat32Array
		
		for __: int in iteration_count:
			ping.start()
			callback.call()
			results.append(ping.stop(false, false, prefix, microseconds_per_second))
		
		var result: float = UtilsNumeric.float_get_average_32(results)
		
		if print_measure_result:
			print("%s%f" % [prefix, result])
		
		return result
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
