class_name Collection
extends Resource

#region Private Variables
var _items: Dictionary[Variant, int]
#endregion

#region Virtual Methods
func _to_string() -> String:
	return "<Collection:%s>" % str(items())
#endregion

#region Public Methods
func add(item: Variant) -> Collection:
	_items[item] = 0
	
	return self


func add_incremented(item: Variant) -> Collection:
	if has(item):
		_items[item] += 1
	
	else:
		_items[item] = 1
	
	return self


func add_array(array: Array) -> Collection:
	for item: Variant in array:
		add(item)
	
	return self


func add_array_incremented(array: Array) -> Collection:
	for item: Variant in array:
		add_incremented(item)
	
	return self


func remove(item: Variant) -> Collection:
	_items.erase(item)
	
	return self


func clear() -> Collection:
	_items.clear()
	
	return self


func items() -> Array:
	return _items.keys()


func items_sorted() -> Array:
	var result: Array = _items.keys()
	
	result.sort()
	
	return result


func items_sorted_custom(callable: Callable) -> Array:
	var result: Array = _items.keys()
	
	result.sort_custom(callable)
	
	return result


func has(item: Variant) -> bool:
	return item in _items


func size() -> int:
	return _items.size()


func is_empty() -> bool:
	return _items.is_empty()


func duplicate_collection() -> Collection:
	return Collection.new_from_array(items().duplicate(true))


func equals(other_collection: Collection) -> bool:
	return _items == other_collection._items


func merge(other_collection: Collection) -> Collection:
	add_array(other_collection.items())
	
	return self


func intersection(other_collection: Collection) -> Collection:
	return Collection.new_from_array(other_collection.items().filter(func(item: Variant) -> bool: return has(item)))


func difference(other_collection: Collection) -> Collection:
	return Collection.new_from_array(items().filter(func(item: Variant) -> bool: return not other_collection.has(item)))


func dump_to_file(file: FileAccess, close_on_finished: bool = true) -> void:
	if file == null:
		return
	
	for entry: Variant in items():
		file.store_line(str(entry))
	
	if close_on_finished:
		file.close()
#endregion

#region Static Methods
static func new_from_array(array: Array) -> Collection:
	return Collection.new().add_array(array)


static func new_from_collection(collection: Collection) -> Collection:
	return Collection.new().merge(collection)
#endregion
