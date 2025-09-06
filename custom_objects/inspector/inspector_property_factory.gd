class_name InspectorPropertyFactory

#region Public Static Methods
static func new_bool(
	property_name: StringName,
	value: bool,
	default_value: bool,
	options_arg: InspectorPropertyOptionsBool = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsBool.new()
		
		options_arg.label_enabled = false
		
		var control: CheckButton = CheckButton.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.button_pressed = default_value)
		
		control.text = InspectorProperty.get_property_title(
			property_name, options_arg.section_divider, options_arg.section_index
			)
		control.button_pressed = value
		control.alignment = (
			HORIZONTAL_ALIGNMENT_RIGHT if options_arg.label_position_to_right else HORIZONTAL_ALIGNMENT_LEFT
			)
		control.pressed.connect(func() -> void: instance.new_value = control.button_pressed)
		
		return instance


static func new_color(
	property_name: StringName,
	value: Color,
	default_value: Color,
	options_arg: InspectorPropertyOptionsColor = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsColor.new()
		
		var control: ColorPickerButton = ColorPickerButton.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.color = default_value)
		
		control.color = value
		control.custom_minimum_size = Vector2.ONE * options_arg.min_width
		control.edit_alpha = options_arg.edit_alpha
		control.edit_intensity = options_arg.edit_intensity
		control.alignment = (
			HORIZONTAL_ALIGNMENT_RIGHT if options_arg.label_position_to_right else HORIZONTAL_ALIGNMENT_LEFT
			)
		control.color_changed.connect(func(changed_color: Color) -> void: instance.new_value = changed_color)
		
		return instance


static func new_enum(
	property_name: StringName,
	value: int,
	default_value: int,
	enum_reference: Dictionary,
	options_arg: InspectorPropertyOptionsEnum = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsEnum.new()
		
		var control: OptionButton = OptionButton.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.selected = default_value)
		
		for enum_idx: int in enum_reference.size():
			control.add_item(str(enum_reference.keys()[enum_idx]).capitalize(), enum_idx)
		
		control.selected = value
		control.item_selected.connect(func(index: int) -> void: instance.new_value = index)
		
		return instance


static func new_float(
	property_name: StringName,
	value: float,
	default_value: float,
	options_arg: InspectorPropertyOptionsFloat = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsFloat.new()
		
		var control: SpinBox = SpinBox.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.value = default_value)
		
		control.alignment = options_arg.alignment
		
		if options_arg.min_value > 0.0:
			control.min_value = options_arg.min_value
		
		if options_arg.max_value > 0.0:
			control.max_value = options_arg.max_value
		
		control.step = options_arg.step
		control.value = value
		
		control.value_changed.connect(func(new_value: float) -> void: instance.new_value = new_value)
		control.changed.connect(func() -> void: instance.new_value = control.value)
		control.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value = float(text))
		
		return instance


static func new_int(
	property_name: StringName,
	value: int,
	default_value: int,
	options_arg: InspectorPropertyOptionsInt = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsInt.new()
		
		var control: SpinBox = SpinBox.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.value = default_value)
		
		control.custom_arrow_step = 1.0
		control.step = 1.0
		control.rounded = true
		control.alignment = options_arg.alignment
		
		if options_arg.min_value > 0.0:
			control.min_value = options_arg.min_value
		
		if options_arg.max_value > 0.0:
			control.max_value = options_arg.max_value
		
		control.value = value
		
		control.value_changed.connect(func(new_value: float) -> void: instance.new_value = int(new_value))
		control.changed.connect(func() -> void: instance.new_value = int(control.value))
		control.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value = int(text))
		
		return instance


static func new_string(
	property_name: StringName,
	value: String,
	default_value: String,
	options_arg: InspectorPropertyOptionsString = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsString.new()
		
		var control: LineEdit = LineEdit.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void: control.text = default_value)
		
		if options_arg.min_width <= 0.0:
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		else:
			control.custom_minimum_size.x = options_arg.min_width
		
		control.text = value
		control.alignment = options_arg.alignment
		control.clear_button_enabled = options_arg.clear_button_enabled
		control.max_length = options_arg.max_length
		control.text_changed.connect(func(new_text: String) -> void: instance.new_value = new_text.strip_edges())
		
		return instance


static func new_vector2(
	property_name: StringName,
	value: Vector2,
	default_value: Vector2,
	options_arg: InspectorPropertyOptionsVector2 = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsVector2.new()
		
		var control: HBoxContainer = HBoxContainer.new()
		var control_x: SpinBox = SpinBox.new()
		var control_y: SpinBox = SpinBox.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void:
			control_x.value = default_value.x
			control_y.value = default_value.y
			)
		
		control_x.prefix = "X"
		control_y.prefix = "Y"
		
		control.add_theme_constant_override(&"separation", options_arg.separation)
		control_x.alignment = options_arg.alignment
		control_y.alignment = options_arg.alignment
		
		if options_arg.min_value.x > 0.0:
			control_x.min_value = options_arg.min_value.x
		
		if options_arg.max_value.x > 0.0:
			control_x.max_value = options_arg.max_value.x
		
		if options_arg.min_value.y > 0.0:
			control_y.min_value = options_arg.min_value.y
		
		if options_arg.max_value.y > 0.0:
			control_y.max_value = options_arg.max_value.y
		
		control_x.step = options_arg.step.x
		control_y.step = options_arg.step.y
		
		control_x.value = value.x
		control_y.value = value.y
		
		control_x.value_changed.connect(func(new_value: float) -> void: instance.new_value.x = new_value)
		control_x.changed.connect(func() -> void: instance.new_value.x = control_x.value)
		control_x.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value.x = float(text))
		
		control_y.value_changed.connect(func(new_value: float) -> void: instance.new_value.y = new_value)
		control_y.changed.connect(func() -> void: instance.new_value.y = control_y.value)
		control_y.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value.y = float(text))
		
		control.add_child(control_x)
		control.add_child(control_y)
		
		return instance


static func new_vector3(
	property_name: StringName,
	value: Vector3,
	default_value: Vector3,
	options_arg: InspectorPropertyOptionsVector3 = null,
	) -> InspectorProperty:
		if options_arg == null:
			options_arg = InspectorPropertyOptionsVector3.new()
		
		var control: HBoxContainer = HBoxContainer.new()
		var control_x: SpinBox = SpinBox.new()
		var control_y: SpinBox = SpinBox.new()
		var control_z: SpinBox = SpinBox.new()
		var instance: InspectorProperty = InspectorProperty.new(
			property_name, value, default_value, control, options_arg
			)
		
		instance.reseted.connect(func() -> void:
			control_x.value = default_value.x
			control_y.value = default_value.y
			control_z.value = default_value.z
			)
		
		control_x.prefix = "X"
		control_y.prefix = "Y"
		control_z.prefix = "Z"
		
		control.add_theme_constant_override(&"separation", options_arg.separation)
		control_x.alignment = options_arg.alignment
		control_y.alignment = options_arg.alignment
		control_z.alignment = options_arg.alignment
		
		if options_arg.min_value.x > 0.0:
			control_x.min_value = options_arg.min_value.x
		
		if options_arg.max_value.x > 0.0:
			control_x.max_value = options_arg.max_value.x
		
		if options_arg.min_value.y > 0.0:
			control_y.min_value = options_arg.min_value.y
		
		if options_arg.max_value.y > 0.0:
			control_y.max_value = options_arg.max_value.y
		
		if options_arg.min_value.z > 0.0:
			control_z.min_value = options_arg.min_value.z
		
		if options_arg.max_value.z > 0.0:
			control_z.max_value = options_arg.max_value.z
		
		control_x.step = options_arg.step.x
		control_y.step = options_arg.step.y
		control_z.step = options_arg.step.z
		
		control_x.value = value.x
		control_y.value = value.y
		control_z.value = value.z
		
		control_x.value_changed.connect(func(new_value: float) -> void: instance.new_value.x = new_value)
		control_x.changed.connect(func() -> void: instance.new_value.x = control_x.value)
		control_x.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value.x = float(text))
		
		control_y.value_changed.connect(func(new_value: float) -> void: instance.new_value.y = new_value)
		control_y.changed.connect(func() -> void: instance.new_value.y = control_y.value)
		control_y.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value.y = float(text))
		
		control_z.value_changed.connect(func(new_value: float) -> void: instance.new_value.z = new_value)
		control_z.changed.connect(func() -> void: instance.new_value.z = control_z.value)
		control_z.get_line_edit().text_changed.connect(func(text: String) -> void: instance.new_value.z = float(text))
		
		control.add_child(control_x)
		control.add_child(control_y)
		control.add_child(control_z)
		
		return instance
#endregion
