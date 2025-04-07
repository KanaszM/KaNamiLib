"""
# Version 1.0.0 (02-Apr-2025):
	- Initial release;
"""


class_name UtilsNode2D


static func rotate_towards(source: Node2D, target: Node2D, offset: float = 0.0) -> void:
	source.rotation = source.global_position.direction_to(target.global_position).angle()
	source.rotation += offset


static func has_line_of_sight_to(source: Node2D, target: Node2D) -> bool:
	var space_state: PhysicsDirectSpaceState2D = source.get_world_2d().direct_space_state
	var parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		source.global_position, target.global_position
		)
	var result := space_state.intersect_ray(parameters)
	
	return false if result.is_empty() else result.collider == target
