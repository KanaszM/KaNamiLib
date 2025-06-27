class_name DebugToolsDraw3D extends Node

#region Public Methods
func line(
	point_a: Vector3, point_b: Vector3, color: Color = Color.WHITE, duration: float = 0.0
	) -> MeshInstance3D:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		var immediate_mesh: ImmediateMesh = ImmediateMesh.new()
		var material: ORMMaterial3D = ORMMaterial3D.new()
		
		mesh_instance.mesh = immediate_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		immediate_mesh.surface_add_vertex(point_a)
		immediate_mesh.surface_add_vertex(point_b)
		immediate_mesh.surface_end()
		
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		
		get_tree().get_root().add_child(mesh_instance)
		
		return await _final_cleanup(mesh_instance, duration)


func point(
	position: Vector3, radius: float = 0.05, color: Color = Color.WHITE, duration: float = 0.0
	) -> MeshInstance3D:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		var sphere_mesh: SphereMesh = SphereMesh.new()
		var material: ORMMaterial3D = ORMMaterial3D.new()
		
		mesh_instance.mesh = sphere_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.position = position
		
		sphere_mesh.radius = radius
		sphere_mesh.height = radius * 2.0
		sphere_mesh.material = material
		
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		
		get_tree().get_root().add_child(mesh_instance)
		
		return await _final_cleanup(mesh_instance, duration)


func square(
	position: Vector3, size: Vector2, color: Color = Color.WHITE, duration: float = 0.0
	) -> MeshInstance3D:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		var box_mesh: BoxMesh = BoxMesh.new()
		var material: ORMMaterial3D = ORMMaterial3D.new()
		
		mesh_instance.mesh = box_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.position = position
		
		box_mesh.size = Vector3(size.x, size.y, 1.0)
		box_mesh.material = material
		
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		
		get_tree().get_root().add_child(mesh_instance)
		
		return await _final_cleanup(mesh_instance, duration)
#endregion

#region Private Methods
func _final_cleanup(mesh_instance: MeshInstance3D, duration: float) -> MeshInstance3D:
	if duration == 1.0:
		await get_tree().physics_frame
		mesh_instance.queue_free()
		return null
	
	elif duration > 0.0:
		await get_tree().create_timer(duration).timeout
		mesh_instance.queue_free()
		return null
	
	return mesh_instance
#endregion
