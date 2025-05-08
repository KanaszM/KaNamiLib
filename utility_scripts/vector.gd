class_name UtilsVector


static func sorted_vector2(vector: Vector2) -> Vector2:
	var values: Array[float] = [vector.x, vector.y]
	
	values.sort()
	
	return Vector2(values[0], values[1])


static func sorted_vector2i(vector: Vector2i) -> Vector2i:
	var values: Array[int] = [vector.x, vector.y]
	
	values.sort()
	
	return Vector2i(values[0], values[1])


static func sorted_clamped_vector2(vector: Vector2, min_value: float, max_value: float) -> Vector2:
	var sorted: Vector2 = sorted_vector2(vector)
	
	return Vector2(minf(min_value, sorted.x), maxf(max_value, sorted.x))


static func sorted_clamped_vector2i(vector: Vector2i, min_value: int, max_value: int) -> Vector2i:
	var sorted: Vector2i = sorted_vector2i(vector)
	
	return Vector2i(mini(min_value, sorted.x), maxi(max_value, sorted.x))


static func vector2_is_directional(vector: Vector2) -> bool:
	return vector in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


static func vector2i_is_directional(vector: Vector2i) -> bool:
	return vector in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]


static func calculate_vector2_travel_time(position: Vector2, destination: Vector2, speed: float) -> float:
	return (position - destination).length() / speed


static func calculate_vector2i_travel_time(position: Vector2i, destination: Vector2i, speed: float) -> float:
	return (position - destination).length() / speed
