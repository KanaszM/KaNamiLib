@tool
class_name ExtendedStandardMaterial3D extends StandardMaterial3D

#region Private Methods
func _set(property: StringName, value: Variant) -> bool:
	var is_handled: bool = true
	
	match property:
		&"albedo_texture":
			albedo_texture = value
			emit_changed()
		
		&"albedo_color":
			albedo_color = value
			emit_changed()
		
		_:
			is_handled = false
	
	return is_handled
#endregion
