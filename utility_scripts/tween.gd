class_name UtilsTween


static func kill_tween_safe(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()


static func tween_property_by_data(object: Node, data: TweenPropertyData, tween: Tween = null) -> void:
	if object == null or data == null:
		Log.error("Object or TweenPropertyData not provided!", tween_property_by_data)
		return
	
	if tween == null or not tween.is_valid():
		tween = object.create_tween()
	
	var tweener: PropertyTweener = tween.tween_property(object, data.property, data.to_value, data.duration)
	
	tweener.set_trans(data.transition_type)
	tweener.set_ease(data.ease_type)
	
	if data.delay > 0.0:
		tweener.set_delay(data.delay)
	
	if data.from_value != null:
		var to_value_type: int = typeof(data.to_value)
		var from_value_type: int = typeof(data.from_value)
		
		if to_value_type != from_value_type:
			Log.error(
				"From and to value types mismatch! From: %s | To: %s" % [
					type_string(from_value_type), type_string(to_value_type)
					],
				tween_property_by_data
				)
			return
		
		tweener.from(data.from_value)
