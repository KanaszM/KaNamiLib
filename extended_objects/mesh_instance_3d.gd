@tool
class_name ExtendedMeshInstance3D extends MeshInstance3D

#region Constants
const NAME_STATIC_COLLISION_BODY: StringName = &"StaticCollisionBody"
const NAME_STATIC_COLLISION_AREA: StringName = &"StaticCollisionArea"
const NAME_COLLISION_SHAPE: StringName = &"CollisionShape"
#endregion

#region Enums
enum CollisionType {STATIC, AREA}
enum AddCollisionMode {REGULAR, DEFERRED, EDITOR}
#endregion

#region Public Methods
func get_collision(type: CollisionType) -> CollisionObject3D:
	match type:
		CollisionType.STATIC: return get_static_collision()
		CollisionType.AREA: return get_area_collision()
		_: return null


func get_static_collision() -> StaticBody3D:
	return get_node_or_null(NodePath(NAME_STATIC_COLLISION_BODY)) as StaticBody3D


func get_area_collision() -> Area3D:
	return get_node_or_null(NodePath(NAME_STATIC_COLLISION_AREA)) as Area3D


func set_collision(
	state: bool,
	type: CollisionType, add_mode: AddCollisionMode = AddCollisionMode.REGULAR,
	layer: int = 1, mask: int = 1
	) -> void:
		match type:
			CollisionType.STATIC: set_static_collision(state, add_mode, layer, mask)
			CollisionType.AREA: set_area_collision(state, add_mode, layer, mask)


func set_static_collision(
	state: bool, add_mode: AddCollisionMode = AddCollisionMode.REGULAR, layer: int = 1, mask: int = 1
	) -> void:
		var body: StaticBody3D = get_static_collision()
		var shape: CollisionShape3D = _get_collision_shape(body)
		
		if state:
			var area: Area3D = get_area_collision()
			
			if area != null:
				area.queue_free()
			
			if body == null:
				body = StaticBody3D.new()
				body.name = NAME_STATIC_COLLISION_BODY
				
				match add_mode:
					AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(self, body)
					AddCollisionMode.DEFERRED: add_child.call_deferred(body)
					_: add_child(body)
			
			if shape == null:
				shape = CollisionShape3D.new()
				shape.name = NAME_COLLISION_SHAPE
				
				match add_mode:
					AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(body, shape)
					AddCollisionMode.DEFERRED: body.add_child.call_deferred(shape)
					_: body.add_child(shape)
			
			body.collision_layer = layer
			body.collision_mask = mask
			shape.shape = mesh.create_trimesh_shape()
		
		else:
			if body != null:
				body.queue_free()


func set_area_collision(
	state: bool, add_mode: AddCollisionMode = AddCollisionMode.REGULAR, layer: int = 1, mask: int = 1
	) -> void:
		var area: Area3D = get_area_collision()
		var shape: CollisionShape3D = _get_collision_shape(area)
		
		if state:
			var body: StaticBody3D = get_static_collision()
			
			if body != null:
				body.queue_free()
			
			if area == null:
				area = Area3D.new()
				area.name = NAME_STATIC_COLLISION_AREA
				
				match add_mode:
					AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(self, area)
					AddCollisionMode.DEFERRED: add_child.call_deferred(area)
					_: add_child(area)
			
			if shape == null:
				shape = CollisionShape3D.new()
				shape.name = NAME_COLLISION_SHAPE
				
				match add_mode:
					AddCollisionMode.EDITOR: UtilsNode.add_child_in_editor(area, shape)
					AddCollisionMode.DEFERRED: area.add_child.call_deferred(shape)
					_: area.add_child(shape)
			
			area.collision_layer = layer
			area.collision_mask = mask
			shape.shape = mesh.create_convex_shape()
		
		else:
			if area != null:
				area.queue_free()
#endregion

#region Private Methods
func _get_collision_shape(origin: CollisionObject3D) -> CollisionShape3D:
	return null if origin == null else origin.get_node_or_null(NodePath(NAME_COLLISION_SHAPE)) as CollisionShape3D
#endregion
