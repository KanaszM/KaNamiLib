"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsGeometry


static func get_rect_from_circle(circle_position: Vector2, circle_radius: float) -> Rect2:
	return Rect2(circle_position - Vector2.ONE * circle_radius, Vector2.ONE * circle_radius * 2.0)


static func clamp_point_to_radius(vector: Vector2, clamp_origin: Vector2, clamp_length: float) -> Vector2:
	return clamp_origin + (vector - clamp_origin).limit_length(clamp_length)
