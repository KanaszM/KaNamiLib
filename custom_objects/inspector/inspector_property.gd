class_name InspectorProperty extends HBoxContainer

#region Constants
const GROUP: StringName = &"--InspectorProperty--"
#endregion

#region Signals
signal changed
signal reseted
#endregion

#region Public Variables
var property: String
var initial_value: Variant
var default_value: Variant
var control_node: Control
var options: InspectorPropertyOptions

var is_valid: bool
var initial_value_type: int
var new_value: Variant: set = _set_new_value
var section: String: get = _get_section
#endregion

#region Private Variables
var _reset_button: Button
#endregion

#region Constructor
func _init(
	property_arg: String,
	initial_value_arg: Variant,
	default_value_arg: Variant,
	control_node_arg: Control,
	options_arg: InspectorPropertyOptions = null,
	) -> void:
		if initial_value_arg == null:
			Log.error("The initial value cannot be null!", _init)
			return
		
		if control_node_arg == null:
			Log.error("No control reference was provided!", _init)
			return
		
		if default_value_arg == null:
			Log.warning(
				"The provided default value is null. Replacing it with the initial value: '%s'..." % initial_value_arg,
				_init
				)
			default_value_arg = initial_value_arg
		
		if options_arg == null:
			Log.warning("The provided options reference is null. Replacing it with a default one...", _init)
			options_arg = InspectorPropertyOptions.new()
		
		property = property_arg
		initial_value = initial_value_arg
		default_value = default_value_arg
		control_node = control_node_arg
		options = options_arg
		
		is_valid = true
		initial_value_type = typeof(initial_value_arg)
		new_value = initial_value_arg
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		add_to_group(GROUP)


func _ready() -> void:
	if not is_valid:
		queue_free()
		return
	
	#region Control:
	add_child(control_node)
	#endregion
	
	#region Label:
	if options.label_enabled:
		var label: Label
		
		label = Label.new()
		label.custom_minimum_size.x = options.label_min_width
		label.text = get_property_title(property, options.section_divider, options.section_index)
		
		add_child(label)
		move_child(label, int(options.label_position_to_right))
	#endregion
	
	#region Reset button:
	if options.reset_button_enabled:
		_reset_button = Button.new()
		
		_reset_button.text = options.reset_button_text
		_reset_button.visible = new_value != default_value
		_reset_button.pressed.connect(reset_to_default_value)
		
		add_child(_reset_button)
	#endregion
#endregion

#region Public Methods
func reset_to_default_value() -> void:
	new_value = default_value
	reseted.emit()
#endregion

#region Static Methods
static func get_all_inspector_properties(origin: Node) -> Array[InspectorProperty]:
	return Array(
		origin.get_tree().get_nodes_in_group(GROUP), TYPE_OBJECT, &"HBoxContainer", InspectorProperty
		) as Array[InspectorProperty]


static func get_property_title(property_name: String, divider: String, index: int) -> String:
	return " ".join(property_name.split(divider).slice(index + 1)).capitalize()
#endregion

#region Private Methods
func _to_string() -> String:
	return "<Inspector%sProperty[%s][%s]>" % [type_string(initial_value_type).capitalize(), property, new_value]
#endregion

#region Setter Methods
func _set_new_value(arg: Variant) -> void:
	var previous_new_value: Variant = new_value
	
	new_value = arg
	
	if previous_new_value != null and previous_new_value != new_value:
		changed.emit()
	
	if _reset_button != null:
		_reset_button.visible = new_value != default_value
#endregion

#region Getter Methods
func _get_section() -> String:
	return property.get_slice(options.section_divider, options.section_index)
#endregion
