class_name UtilsGeometry


static func get_rect_from_circle(circle_position: Vector2, circle_radius: float) -> Rect2:
	return Rect2(circle_position - Vector2.ONE * circle_radius, Vector2.ONE * circle_radius * 2.0)


static func clamp_point_to_radius(vector: Vector2, clamp_origin: Vector2, clamp_length: float) -> Vector2:
	return clamp_origin + (vector - clamp_origin).limit_length(clamp_length)


static func get_polygon_centroid(polygon: PackedVector2Array) -> Vector2:
	var num_points: int = polygon.size()
	
	if num_points < 3:
		return Vector2.ZERO
	
	var total_points_area: float = 0.0
	var centroid_point_x: float = 0.0
	var centroid_point_y: float = 0.0
	
	for point_idx: int in range(num_points):
		var x0: float = polygon[point_idx].x
		var y0: float = polygon[point_idx].y
		var x1: float = polygon[(point_idx + 1) % num_points].x
		var y1: float = polygon[(point_idx + 1) % num_points].y
		var point_area: float = x0 * y1 - x1 * y0
		
		total_points_area += point_area
		centroid_point_x += (x0 + x1) * point_area
		centroid_point_y += (y0 + y1) * point_area
	
	total_points_area *= 0.5
	centroid_point_x /= (6.0 * total_points_area)
	centroid_point_y /= (6.0 * total_points_area)
	
	return Vector2(centroid_point_x, centroid_point_y)


static func get_offsetted_polygon(
	polygon: PackedVector2Array,
	mode: bool,
	ratio: float,
	join_type: Geometry2D.PolyJoinType = Geometry2D.PolyJoinType.JOIN_SQUARE
	) -> PackedVector2Array:
		if polygon.is_empty():
			return PackedVector2Array([])
		
		ratio = absf(ratio)
		
		var results: Array[PackedVector2Array] = Geometry2D.offset_polygon(
			polygon, ratio if mode else -ratio, join_type
			)
		
		return PackedVector2Array([]) if results.is_empty() else results[0]


static func get_flipped_polygon(polygon: PackedVector2Array, horizontally: bool) -> PackedVector2Array:
	if polygon.is_empty():
		return PackedVector2Array([])
	
	var result: PackedVector2Array = polygon.duplicate()
	var min_vertex: float = result[0].x if horizontally else result[0].y
	var max_vertex: float = result[0].x if horizontally else result[0].y
	
	for point: Vector2 in result:
		min_vertex = minf(min_vertex, point.x if horizontally else point.y)
		max_vertex = maxf(max_vertex, point.x if horizontally else point.y)
	
	var center_vertex: float = (min_vertex + max_vertex) / 2.0
	
	if horizontally:
		for point_idx: int in result.size():
			result[point_idx].x = center_vertex - (result[point_idx].x - center_vertex)
	
	else:
		for point_idx: int in result.size():
			result[point_idx].y = center_vertex - (result[point_idx].y - center_vertex)
	
	return result


static func get_polygon_rect(polygon: PackedVector2Array) -> Rect2:
	var min_point: Vector2 = Vector2(UtilsNumeric.VECTOR_MAX_COORD, UtilsNumeric.VECTOR_MAX_COORD)
	var max_point: Vector2 = Vector2(UtilsNumeric.VECTOR_MIN_COORD, UtilsNumeric.VECTOR_MIN_COORD)
	
	for point: Vector2 in polygon:
		min_point = Vector2(minf(min_point.x, point.x), minf(min_point.y, point.y))
		max_point = Vector2(maxf(max_point.x, point.x), maxf(max_point.y, point.y))
	
	return Rect2(min_point, (max_point - min_point).abs())


static func get_triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * absf((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))
