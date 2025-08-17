class_name UtilsInput


static func move_mouse_cursor(origin: CanvasItem, factor: float = 0.0001) -> void:
	Input.warp_mouse(origin.get_global_mouse_position() + Vector2.ONE * factor)


static func event_action_press_callback(
	event: InputEvent, action: StringName, callback: Callable, deferred: bool = false
	) -> void:
		if event.is_action_pressed(action):
			UtilsCallback.call_safe(callback, deferred)


static func event_key_press_callback(
	event: InputEvent, key: Key, callback: Callable, deferred: bool = false
	) -> void:
		if event is InputEventKey:
			var input_key_event := event as InputEventKey
			
			if input_key_event.pressed and input_key_event.keycode == key:
				UtilsCallback.call_safe(callback, deferred)


static func event_keys_press_callback(
	event: InputEvent, keys: Array[Key], callback: Callable, deferred: bool = false
	) -> void:
		if event is InputEventKey:
			var input_key_event := event as InputEventKey
			
			if input_key_event.pressed and input_key_event.keycode in keys:
				UtilsCallback.call_safe(callback, deferred)


static func event_mouse_button_callback(
	event: InputEvent, mouse_button: MouseButton, callback: Callable, deferred: bool = false
	) -> void:
		if event is InputEventMouseButton:
			var mouse_button_event := event as InputEventMouseButton
		
			if mouse_button_event.pressed and mouse_button_event.button_index == mouse_button:
				UtilsCallback.call_safe(callback, deferred)


static func action_pressed_callback(action: StringName, callback: Callable, deferred: bool = false) -> void:
	if Input.is_action_pressed(action):
		UtilsCallback.call_safe(callback, deferred)


static func action_just_pressed_callback(action: StringName, callback: Callable, deferred: bool = false) -> void:
	if Input.is_action_just_pressed(action):
		UtilsCallback.call_safe(callback, deferred)


static func action_just_released_callback(action: StringName, callback: Callable, deferred: bool = false) -> void:
	if Input.is_action_just_released(action):
		UtilsCallback.call_safe(callback, deferred)


static func int_to_number_key(value: int) -> Key:
	match value:
		0: return KEY_0
		1: return KEY_1
		2: return KEY_2
		3: return KEY_3
		4: return KEY_4
		5: return KEY_5
		6: return KEY_6
		7: return KEY_7
		8: return KEY_8
		9: return KEY_9
		_: return KEY_NONE


static func int_to_numpad_key(value: int) -> Key:
	match value:
		0: return KEY_KP_0
		1: return KEY_KP_1
		2: return KEY_KP_2
		3: return KEY_KP_3
		4: return KEY_KP_4
		5: return KEY_KP_5
		6: return KEY_KP_6
		7: return KEY_KP_7
		8: return KEY_KP_8
		9: return KEY_KP_9
		_: return KEY_NONE


static func int_to_functional_key(value: int) -> Key:
	match value:
		1: return KEY_F1
		2: return KEY_F2
		3: return KEY_F3
		4: return KEY_F4
		5: return KEY_F5
		6: return KEY_F6
		7: return KEY_F7
		8: return KEY_F8
		9: return KEY_F9
		10: return KEY_F10
		11: return KEY_F11
		12: return KEY_F12
		_: return KEY_NONE
