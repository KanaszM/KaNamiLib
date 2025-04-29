class_name UtilsControl


static func set_rect(control: Control, rect: Rect2, include_minimum_size: bool = false, deferred: bool = true) -> void:
	control.position = rect.position
	
	if include_minimum_size:
		set_size(control, rect.size, deferred)
	
	else:
		if deferred:
			control.set_deferred(&"size", rect.size)
		
		else:
			control.set(&"size", rect.size)


static func set_size(control: Control, size: Vector2, deferred: bool = true) -> void:
	set_size_x(control, size.x, deferred)
	set_size_y(control, size.y, deferred)


static func set_size_percent(control: Control, size: Vector2, deferred: bool = true) -> void:
	set_size_percent_x(control, size.x, deferred)
	set_size_percent_y(control, size.y, deferred)


static func set_size_x(control: Control, size: float, deferred: bool = true) -> void:
	control.custom_minimum_size.x = size
	
	if deferred:
		control.set_deferred(&"size:x", size)
	
	else:
		control.set(&"size:x", size)


static func set_size_y(control: Control, size: float, deferred: bool = true) -> void:
	control.custom_minimum_size.y = size
	
	if deferred:
		control.set_deferred(&"size:y", size)
	
	else:
		control.set(&"size:y", size)


static func set_size_percent_x(control: Control, size: float, deferred: bool = true) -> void:
	set_size_x(control, UtilsWindow.get_window().size.x * (clampf(size, 0.0, 100.0) / 100.0), deferred)


static func set_size_percent_y(control: Control, size: float, deferred: bool = true) -> void:
	set_size_y(control, UtilsWindow.get_window().size.y * (clampf(size, 0.0, 100.0) / 100.0), deferred)


static func release_focus_recursive(control: Control) -> void:
	control.release_focus()
	
	for child: Node in control.get_children():
		if child is Control:
			release_focus_recursive(child as Control)


static func convert_text_direction_flag(flag: Control.TextDirection) -> TextServer.Direction:
	match flag:
		Control.TextDirection.TEXT_DIRECTION_LTR: return TextServer.Direction.DIRECTION_LTR
		Control.TextDirection.TEXT_DIRECTION_RTL: return TextServer.Direction.DIRECTION_RTL
		Control.TextDirection.TEXT_DIRECTION_INHERITED: return TextServer.Direction.DIRECTION_INHERITED
		_: return TextServer.Direction.DIRECTION_AUTO


static func convert_horizontal_alignment_to_size_flags(flag: HorizontalAlignment) -> Control.SizeFlags:
	match flag:
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER: return Control.SizeFlags.SIZE_SHRINK_CENTER
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT: return Control.SizeFlags.SIZE_SHRINK_END
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_FILL: return Control.SizeFlags.SIZE_EXPAND_FILL
		_: return Control.SizeFlags.SIZE_SHRINK_BEGIN


static func convert_vertical_alignment_to_size_flags(flag: VerticalAlignment) -> Control.SizeFlags:
	match flag:
		VerticalAlignment.VERTICAL_ALIGNMENT_CENTER: return Control.SizeFlags.SIZE_SHRINK_CENTER
		VerticalAlignment.VERTICAL_ALIGNMENT_BOTTOM: return Control.SizeFlags.SIZE_SHRINK_END
		VerticalAlignment.VERTICAL_ALIGNMENT_FILL: return Control.SizeFlags.SIZE_EXPAND_FILL
		_: return Control.SizeFlags.SIZE_SHRINK_BEGIN


static func bind_callback(
	control: Control,
	callback: Callable,
	mouse_button: MouseButton = MOUSE_BUTTON_LEFT,
	use_pointing_hand_cursor: bool = true
	) -> void:
		if not callback.is_valid():
			return
		
		control.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if use_pointing_hand_cursor:
			control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if control is BaseButton:
			var button_control := control as BaseButton
			
			button_control.pressed.connect(callback)
		
		else:
			var func_on_control_gui_input: Callable = func(event: InputEvent) -> void:
				if event is InputEventMouseButton:
					var mouse_button_event := event as InputEventMouseButton
					
					if mouse_button_event.pressed and mouse_button_event.button_index == mouse_button:
						callback.call()
			
			control.gui_input.connect(func_on_control_gui_input)


static func bind_keys(control: Control, keys: Array[Key], callback: Callable) -> void:
	if not callback.is_valid():
		return
	
	control.focus_mode = Control.FOCUS_ALL
	
	var func_on_control_gui_input: Callable = func(event: InputEvent) -> void:
		if event is InputEventKey:
			var key_event := event as InputEventKey
			
			if key_event.pressed and key_event.keycode in keys:
				callback.call()
	
	control.gui_input.connect(func_on_control_gui_input)


static func get_layout_preset(control: Control) -> Control.LayoutPreset:
	const PRESET_MAP: Dictionary[Vector4, Control.LayoutPreset] = {
		Vector4(0.0, 0.0, 0.0, 0.0): Control.PRESET_TOP_LEFT,
		Vector4(1.0, 0.0, 1.0, 0.0): Control.PRESET_TOP_RIGHT,
		Vector4(0.0, 1.0, 0.0, 1.0): Control.PRESET_BOTTOM_LEFT,
		Vector4(1.0, 1.0, 1.0, 1.0): Control.PRESET_BOTTOM_RIGHT,
		Vector4(0.0, 0.5, 0.0, 0.5): Control.PRESET_CENTER_LEFT,
		Vector4(0.5, 0.0, 0.5, 0.0): Control.PRESET_CENTER_TOP,
		Vector4(1.0, 0.5, 1.0, 0.5): Control.PRESET_CENTER_RIGHT,
		Vector4(0.5, 1.0, 0.5, 1.0): Control.PRESET_CENTER_BOTTOM,
		Vector4(0.5, 0.5, 0.5, 0.5): Control.PRESET_CENTER,
		Vector4(0.0, 0.0, 0.0, 1.0): Control.PRESET_LEFT_WIDE,
		Vector4(0.0, 0.0, 1.0, 0.0): Control.PRESET_TOP_WIDE,
		Vector4(1.0, 0.0, 1.0, 1.0): Control.PRESET_RIGHT_WIDE,
		Vector4(0.0, 1.0, 1.0, 1.0): Control.PRESET_BOTTOM_WIDE,
		Vector4(0.5, 0.0, 0.5, 1.0): Control.PRESET_VCENTER_WIDE,
		Vector4(0.0, 0.5, 1.0, 0.5): Control.PRESET_HCENTER_WIDE,
		Vector4(0.0, 0.0, 1.0, 1.0): Control.PRESET_FULL_RECT,
	}
	
	var control_anchors: Vector4 = Vector4(
		control.anchor_left, control.anchor_top, control.anchor_right, control.anchor_bottom
		)
	
	return PRESET_MAP[control_anchors] if control_anchors in PRESET_MAP else -1
