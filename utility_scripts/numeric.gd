class_name UtilsNumeric


#region Numeric Bounds
const UINT8_MAX: int = (1 << 8)  - 1 # 255
const UINT16_MAX: int = (1 << 16) - 1 # 65535
const UINT32_MAX: int = (1 << 32) - 1 # 4294967295

const INT8_MIN: int = -(1 << 7)  # -128
const INT16_MIN: int = -(1 << 15) # -32768
const INT32_MIN: int = -(1 << 31) # -2147483648
const INT64_MIN: int = -(1 << 63) # -9223372036854775808

const INT8_MAX: int = (1 << 7)  - 1 # 127
const INT16_MAX: int = (1 << 15) - 1 # 32767
const INT32_MAX: int = (1 << 31) - 1 # 2147483647
const INT64_MAX: int = (1 << 63) - 1 # 9223372036854775807

const UFLOAT8_MAX: float = float(UINT8_MAX)
const UFLOAT16_MAX: float = float(UINT16_MAX)
const UFLOAT32_MAX: float = float(UINT32_MAX)

const FLOAT8_MIN: float = float(INT8_MIN)
const FLOAT16_MIN: float = float(INT16_MIN)
const FLOAT32_MIN: float = float(INT32_MIN)
const FLOAT64_MIN: float = float(INT64_MIN)

const FLOAT8_MAX: float = float(INT8_MAX)
const FLOAT16_MAX: float = float(INT16_MAX)
const FLOAT32_MAX: float = float(INT32_MAX)
const FLOAT64_MAX: float = float(INT64_MAX)

const VECTOR_MAX_COORD: int = int(pow(2.0, 31.0)) - 1
const VECTOR_MIN_COORD: int = -VECTOR_MAX_COORD
#endregion

#region Public Static Methods [Float]
static func float_is_power_of_two(value: float) -> bool:
	return value > 0.0 and (value == pow(2.0, floorf(log(value) / log(2.0))))


static func float_get_normalized(value: float) -> float:
	return clampf(value, 0.0, 1.0)


static func float_get_average_32(values: PackedFloat32Array) -> float:
	var sum: float = 0.0
	
	for value: float in values:
		sum += value
	
	return sum / values.size()


static func float_get_average_64(values: PackedFloat64Array) -> float:
	var sum: float = 0.0
	
	for value: float in values:
		sum += value
	
	return sum / values.size()
#endregion

#region Public Static Methods [Int]
static func int_is_between(value: int, first_value: int, second_value: int) -> bool:
	return mini(first_value, second_value) <= value and value <= maxi(first_value, second_value)


static func int_get_squared(size: int) -> int:
	var square_value: int = int(ceili(sqrt(size)))
	
	return square_value * square_value


static func int_get_average_32(values: PackedInt32Array) -> int:
	var sum: int = 0
	
	for value: int in values:
		sum += value
	
	return int(sum / float(values.size()))


static func int_get_average_64(values: PackedInt64Array) -> int:
	var sum: int = 0
	
	for value: int in values:
		sum += value
	
	return int(sum / float(values.size()))
#endregion
