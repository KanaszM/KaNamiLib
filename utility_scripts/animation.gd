"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsAnimation


static func update_track_paths_from_nodes(animation: Animation, from_nodes: Array[Node]) -> void:
	for track_idx: int in animation.get_track_count():
		var track_path: NodePath = animation.track_get_path(track_idx)
		var track_path_last_name: StringName = track_path.get_name(track_path.get_name_count() - 1)
		var track_path_property: String = track_path.get_concatenated_subnames()
		var filtered_nodes := from_nodes.filter(
			func(node: Node) -> bool: return node.name == track_path_last_name
			) as Array[Node]
		
		if filtered_nodes.is_empty():
			continue
		
		var node_path: NodePath = filtered_nodes[0].get_path()
		var track_updated_path: NodePath = NodePath("%s:%s" % [node_path, track_path_property])
		
		animation.track_set_path(track_idx, track_updated_path)


static func append_delay_to_all_tracks(animation: Animation, delay_time: float) -> void:
	animation.length += delay_time
	
	for track_idx: int in animation.get_track_count():
		for key_idx: int in range(animation.track_get_key_count(track_idx) - 1, -1, -1):
			animation.track_set_key_time(
				track_idx, key_idx, animation.track_get_key_time(track_idx, key_idx) + delay_time
				)
