class_name UtilsInput


static func move_mouse_cursor(origin: CanvasItem, factor: float = 0.0001) -> void:
	Input.warp_mouse(origin.get_global_mouse_position() + Vector2.ONE * factor)


static func event_keys_press_callback(
	event: InputEvent, keys: Array[Key], callback: Callable, deferred: bool = false
	) -> void:
		if event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode in keys:
			if deferred:
				callback.call_deferred()
			
			else:
				callback.call()


static func event_mouse_button_callback(
	event: InputEvent, mouse_button: MouseButton, callback: Callable, deferred: bool = false
	) -> void:
		if (
			event is InputEventMouseButton
			and (event as InputEventMouseButton).pressed
			and (event as InputEventMouseButton).button_index == mouse_button
			):
				if deferred:
					callback.call_deferred()
				
				else:
					callback.call()
