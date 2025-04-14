"""
# Version 1.0.0 (02-Apr-2025):
	- Initial release;
"""


class_name UtilsNode


static func add_to_group_safe(node: Node, group: StringName) -> void:
	if node != null and not group.is_empty() and not node.is_in_group(group):
		node.add_to_group(group)


static func reparent_all_children(from: Node, to: Node, ignore: Array[Node] = []) -> void:
	for child: Node in from.get_children():
		if not child in ignore:
			child.reparent(to)


static func free_children_and_wait(parent: Node) -> void:
	while parent.get_child_count() > 0:
		var child: Node = parent.get_child(0)
		
		child.queue_free()
		
		await child.tree_exited


static func set_process(node: Node, mode: bool) -> void:
	node.set_process(mode)
	node.set_process_input(mode)
	node.set_physics_process(mode)
