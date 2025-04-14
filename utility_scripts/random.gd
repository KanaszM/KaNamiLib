class_name UtilsRandom


static func get_bool() -> bool:
	return bool(randi_range(0, 1))


static func get_color(hue_strength: float = 12.0) -> Color:
	return Color.from_hsv((randi() % int(hue_strength)) / hue_strength, 1.0, 1.0)


static func get_float_from_vector_range(vector: Vector2) -> float:
	return randf_range(minf(vector.x, vector.y), maxf(vector.x, vector.y))


static func get_float_from_float_range(float_value: float) -> float:
	float_value = absf(float_value)
	
	return randf_range(-float_value, float_value)


static func get_enum_flag(enum_arg: Dictionary, start_idx: int = 0) -> int:
	var enum_dict: Dictionary[String, int] = UtilsDictionary.enum_to_typed_dict(enum_arg)
	var enum_values := Array(enum_dict.values(), TYPE_INT, &"", null) as Array[int]
	
	return enum_values[randi_range(clampi(start_idx, 0, enum_dict.size() - 1), enum_dict.size() - 1)]


static func execute_callback(callbacks: Array[Callable], args: Array = []) -> Variant:
	return callbacks[randi_range(0, callbacks.size() - 1)].callv(args)
