"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsArray


static func is_array(what: Variant) -> bool:
	return typeof(what) in [
		TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_COLOR_ARRAY,
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY,
		TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY
		]


static func swap(array: Array, from_idx: int, to_idx: int) -> Array:
	from_idx = maxi(0, from_idx)
	to_idx = maxi(0, to_idx)
	
	if from_idx < array.size() and to_idx < array.size():
		var temp_value: Variant = array[from_idx]
		
		array.set(from_idx, array[to_idx])
		array.set(to_idx, temp_value)
	
	return array


static func new_2d_array_squared(size: int) -> Array[Array]:
	var side: int = int(sqrt(size))
	var result: Array[Array]
	var index: int = 0
	
	for __: int in side:
		var row: Array
		
		for ___: int in side:
			row.append(index)
			index += 1
		
		result.append(row)
	
	return result
