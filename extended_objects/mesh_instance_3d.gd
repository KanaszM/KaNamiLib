@tool
class_name ExtendedMeshInstance3D extends MeshInstance3D

#region Constants
const NAME_STATIC_COLLISION_BODY: StringName = &"StaticCollisionBody"
const NAME_STATIC_COLLISION_AREA: StringName = &"StaticCollisionArea"
#endregion

#region Enums
enum AddCollisionMode {REGULAR, DEFERRED, EDITOR}
#endregion

#region Public Methods
func set_static_collision(state: bool, add_mode: AddCollisionMode = AddCollisionMode.REGULAR) -> void:
	var body: StaticBody3D = get_node_or_null(NodePath(NAME_STATIC_COLLISION_BODY))
	var shape: CollisionShape3D = null if body == null else body.get_node_or_null(NodePath(NAME_STATIC_COLLISION_AREA))
	
	if state:
		if body == null:
			body = StaticBody3D.new()
			body.name = NAME_STATIC_COLLISION_BODY
			
			match add_mode:
				AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(self, body)
				AddCollisionMode.DEFERRED: add_child.call_deferred(body)
				_: add_child(body)
		
		if shape == null:
			shape = CollisionShape3D.new()
			shape.name = NAME_STATIC_COLLISION_AREA
			
			match add_mode:
				AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(body, shape)
				AddCollisionMode.DEFERRED: body.add_child.call_deferred(shape)
				_: body.add_child(shape)
		
		shape.shape = mesh.create_trimesh_shape()
	
	else:
		if body != null:
			body.queue_free()
#endregion
