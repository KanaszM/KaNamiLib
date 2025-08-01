class_name UtilsPhysics


static func is_surface_too_steep(origin: CharacterBody3D, normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > origin.floor_max_angle


static func run_body_test_motion(
	origin: CharacterBody3D,
	from: Transform3D,
	motion: Vector3,
	result: PhysicsTestMotionResult3D = null
	) -> bool:
		if result == null:
			result = PhysicsTestMotionResult3D.new()
		
		var parameters: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		
		parameters.from = from
		parameters.motion = motion
		
		return PhysicsServer3D.body_test_motion(origin.get_rid(), parameters, result)
