#@tool
class_name Array1D
extends Resource

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var contents: Array
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(array: Array = []) -> void:
	append_array(array)


func _to_string() -> String:
	return str(contents)
#endregion

#region Public Methods
func collect(initial_idx: int, length: int, offset: int, include_initial: bool, reverse_results: bool) -> Array:
	if contents.is_empty():
		return []
	
	length = clamp_length(length)
	offset = absi(offset)
	
	var collected_contents: Array
	var contents_size: int = size()
	var initial_start: int = (initial_idx - offset) % contents_size
	
	for length_idx: int in range(length):
		var content_idx: int = (initial_start + length_idx) % contents_size
		var content: Variant = contents[content_idx]
		
		collected_contents.append(content)
	
	if not include_initial:
		collected_contents.remove_at(offset)
	
	if reverse_results:
		collected_contents.reverse()
	
	return collected_contents


func collect_filtered(
	initial_idx: int, length: int, offset: int, include_initial: bool, reverse_results: bool, filter_method: Callable
	) -> Array:
		if contents.is_empty() or filter_method.is_null():
			return []
		
		length = clamp_length(length)
		offset = absi(offset)
		
		var collected_contents: Array
		var contents_size: int = size()
		var initial_start: int = (initial_idx - offset) % contents_size
		
		for length_idx: int in range(length):
			var content_idx: int = (initial_start + length_idx) % contents_size
			var content: Variant = contents[content_idx]
			
			if filter_method.call(content):
				collected_contents.append(content)
		
		if not include_initial:
			collected_contents.remove_at(offset)
		
		if reverse_results:
			collected_contents.reverse()
		
		return collected_contents


func collect_positive(
	idx: int,
	length: int = 1,
	include_initial: bool = false,
	reverse_results: bool = false,
	filter_method: Callable = Callable()
	) -> Array:
		var result: Array = (
			collect(idx, length, 0, include_initial, reverse_results) if filter_method.is_null() else
			collect_filtered(idx, length, 0, include_initial, reverse_results, filter_method)
			)
		
		return result


func collect_negative(
	idx: int,
	length: int = 1,
	include_initial: bool = false,
	reverse_results: bool = false,
	filter_method: Callable = Callable()
	) -> Array:
		var result: Array = (
			collect(idx, length, length, include_initial, reverse_results) if filter_method.is_null() else
			collect_filtered(idx, length, length, include_initial, reverse_results, filter_method)
			)
		
		return result


func collect_centered(
	idx: int, length: int = 1, include_initial: bool = true, filter_method: Callable = Callable()
	) -> Array:
		length *= 2
		
		var half_length: int = int(length / 2.0)
		
		return (
			collect(idx, length, half_length, include_initial, false) if filter_method.is_null() else
			collect_filtered(idx, length, half_length, include_initial, false, filter_method)
			)


func cycle_next_index(idx: int, step: int = 1) -> int:
	return get_unbounded_index(clamp_index(idx) + step)


func cycle_previous_index(idx: int, step: int = 1) -> int:
	return get_unbounded_index(clamp_index(idx) - step)
#endregion

#region Helper Methods
func get_unbounded_index(idx: int) -> int:
	var result: int
	var contents_size: int = size()
	
	if contents_size > 0:
		var abs_idx: int = absi(idx)
		
		if idx < 0:
			result = abs_idx % contents_size
			
			if abs_idx >= contents_size:
				result = (abs_idx - (result * 2)) % contents_size
			
			else:
				result = absi(result - contents_size)
		
		else:
			result = idx % contents_size
	
	return result


func clamp_index(idx: int) -> int:
	return clampi(idx, 0, size())


func clamp_length(length: int) -> int:
	return clampi(length, 1, UtilsNumeric.INT32_MAX) + 1


func get_random_index() -> int:
	var contents_size: int = size()
	
	return 0 if contents_size == 0 else (randi() % size())
#endregion

#region Private Methods
#endregion

#region Static Methods
static func new_from_array_1d(array_1d: Array1D) -> Array1D:
	return Array1D.new(array_1d.contents)
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Array Shortcut Methods (Extended)
func duplicate_contents(deep: bool = true) -> Array1D:
	return Array1D.new(contents.duplicate(deep))


func filter(method: Callable) -> Array1D:
	return Array1D.new(contents.filter(method))


func find(what: Variant, from: int = 0) -> int:
	return contents.find(what, get_unbounded_index(from))


func insert(position: int, value: Variant) -> int:
	return contents.insert(get_unbounded_index(position), value)


func pop_at(position: int) -> Variant:
	return contents.pop_at(get_unbounded_index(position))


func reat(position: int) -> void:
	contents.remove_at(get_unbounded_index(position))


func rfind(what: Variant, from: int = -1) -> int:
	return contents.rfind(what, get_unbounded_index(from))


func slice(begin: int, end: int = UtilsNumeric.INT32_MAX, step: int = 1, deep: bool = false) -> Array1D:
	return Array1D.new(contents.slice(begin, end, step, deep))
#endregion

#region Array Shortcut Operators (Extended)
func op_not_equals(right: Array1D) -> bool:
	return contents != right.contents


func op_add(right: Array1D) -> Array1D:
	return Array1D.new(contents + right.contents)


func op_lesser(right: Array1D) -> bool:
	return contents < right.contents


func op_lesser_or_equal(right: Array1D) -> bool:
	return contents <= right.contents


func op_equals(right: Array1D) -> bool:
	return contents == right.contents


func op_greater(right: Array1D) -> bool:
	return contents > right.contents


func op_greater_or_equal(right: Array1D) -> bool:
	return contents >= right.contents


func op_index(index: int) -> Variant:
	return contents[index]
#endregion

#region Array Shortcut Methods (Original)
func all(method: Callable) -> bool:
	return contents.all(method)


func any(method: Callable) -> bool:
	return contents.any(method)


func append(value: Variant) -> void:
	contents.append(value)


func append_array(array: Array) -> void:
	contents.append_array(array)


func assign(array: Array) -> void:
	contents.assign(array)


func back() -> Variant:
	return contents.back()


func bsearch(value: Variant, before: bool = true) -> int:
	return contents.bsearch(value, before)


func bsearch_custom(value: Variant, method: Callable, before: bool = true) -> int:
	return contents.bsearch_custom(value, method, before)


func clear() -> void:
	contents.clear()


func count(value: Variant) -> int:
	return contents.count(value)


func erase(value: Variant) -> void:
	contents.erase(value)


func fill(value: Variant) -> void:
	contents.fill(value)


func front() -> Variant:
	return contents.front()


func has(value: Variant) -> bool:
	return contents.has(value)


func is_empty() -> bool:
	return contents.is_empty()


func map(method: Callable) -> Array1D:
	return Array1D.new(contents.map(method))


func pick_random() -> Variant:
	return contents.pick_random()


func pop_back() -> Variant:
	return contents.pop_back()


func pop_front() -> Variant:
	return contents.pop_front()


func push_back(value: Variant) -> void:
	contents.push_back(value)


func push_front(value: Variant) -> void:
	contents.push_front(value)


func reduce(method: Callable, accum: Variant = null) -> Variant:
	return contents.reduce(method, accum)


func resize(new_size: int) -> int:
	return contents.resize(new_size)


func reverse() -> void:
	contents.reverse()


func shuffle() -> void:
	contents.shuffle()


func size() -> int:
	return contents.size()


func sort() -> void:
	contents.sort()


func sort_custom(method: Callable) -> void:
	contents.sort_custom(method)
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
