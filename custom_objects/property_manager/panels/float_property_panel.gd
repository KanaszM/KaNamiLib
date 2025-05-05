@tool
class_name FloatPropertyPanel
extends PropertyPanel

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var property: FloatProperty: set = _set_property
#endregion

#region Public Variables
var button_step_increment: ExtendedButton
var button_step_decrement: ExtendedButton

var value_bounds: Vector2
#endregion

#region Private Variables
var _percentage_menu_items: Array[ExtendedPopupMenu.Item]
var _vbox_step_buttons_side: ExtendedVBoxContainer
#endregion

#region OnReady Variables
@onready var HBoxBackground := %HBoxBackground as ExtendedHBoxContainer
@onready var LineEditInput := %LineEditInput as ExtendedLineEdit
#endregion

#region Virtual Methods
func _ready() -> void:
	_set_property(property)
	
	super._ready()
#endregion

#region Public Methods
func update() -> bool:
	if not super.update():
		return false
	
	#region Property
	var is_percentage_mode: bool = property.input_edit_mode == FloatProperty.InputEditMode.PERCENTAGE_MENU
	
	value_bounds = UtilsVector.sorted_vector2(property.value_bounds)
	_percentage_menu_items.clear()
	
	if is_percentage_mode:
		var percentage_menu_bounds: Vector2i = UtilsVector.sorted_vector2i(property.percentage_menu_bounds)
		
		for count: int in range(percentage_menu_bounds.x, percentage_menu_bounds.y + 1, property.percentage_menu_step):
			_percentage_menu_items.append(
				ExtendedPopupMenu.Item.new("%d%%" % count, set_percent_value.bind(float(count * 0.01)))
				)
	
	set_value(property.value)
	#endregion
	
	#region Input
	LineEditInput.clear_button_enabled = property.input_clear_button_enabled
	LineEditInput.editable = not is_percentage_mode
	LineEditInput.alignment = property.input_alignment
	LineEditInput.max_length = property.input_max_length
	LineEditInput.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if is_percentage_mode else Control.CURSOR_ARROW
		)
	LineEditInput.set_font_size(property.input_font_size)
	UtilsSignal.connect_safe_if(LineEditInput.gui_input, _on_LineEditInput_gui_input, is_percentage_mode)
	#endregion
	
	#region Step Buttons
	match property.step_buttons_type:
		FloatProperty.StepButtonsType.SIDE, FloatProperty.StepButtonsType.BETWEEN:
			# Buttons
			var new_increment_button_created: bool
			var new_decrement_button_created: bool
			
			if button_step_increment == null:
				button_step_increment = ExtendedButton.new()
				button_step_increment.add_callback(increment)
				button_step_increment.size_flags_vertical = Control.SIZE_EXPAND_FILL
				new_increment_button_created = true
			
			if button_step_decrement == null:
				button_step_decrement = ExtendedButton.new()
				button_step_decrement.add_callback(decrement)
				button_step_decrement.size_flags_vertical = Control.SIZE_EXPAND_FILL
				new_decrement_button_created = true
			
			button_step_increment.text = property.step_buttons_increment_text
			button_step_increment.icon = property.step_buttons_increment_icon
			button_step_increment.custom_minimum_size = property.step_buttons_min_size
			button_step_increment.set_font_size(property.step_buttons_font_size)
			
			button_step_decrement.text = property.step_buttons_decrement_text
			button_step_decrement.icon = property.step_buttons_decrement_icon
			button_step_decrement.custom_minimum_size = property.step_buttons_min_size
			button_step_decrement.set_font_size(property.step_buttons_font_size)
			
			# Containers
			match property.step_buttons_type:
				FloatProperty.StepButtonsType.SIDE:
					if _vbox_step_buttons_side == null:
						_vbox_step_buttons_side = ExtendedVBoxContainer.new()
						HBoxBackground.add_child(_vbox_step_buttons_side)
						
						if new_increment_button_created:
							_vbox_step_buttons_side.add_child(button_step_increment)
						
						if new_decrement_button_created:
							_vbox_step_buttons_side.add_child(button_step_decrement)
					
					_vbox_step_buttons_side.set_separation(property.step_buttons_side_spacing)
				
				FloatProperty.StepButtonsType.BETWEEN:
					if new_increment_button_created:
						HBoxBackground.add_child(button_step_increment)
						HBoxBackground.move_child(button_step_increment, 0)
					
					if new_decrement_button_created:
						HBoxBackground.add_child(button_step_decrement)
					
			HBoxBackground.set_separation(property.step_buttons_separation)
		
		FloatProperty.StepButtonsType.NONE:
			if button_step_increment != null:
				button_step_increment.queue_free()
				button_step_increment = null
			
			if button_step_decrement != null:
				button_step_decrement.queue_free()
				button_step_decrement = null
			
			if _vbox_step_buttons_side != null:
				_vbox_step_buttons_side.queue_free()
				_vbox_step_buttons_side = null
	#endregion
	
	return true


func set_value(value: float) -> void:
	value = clampf(value, value_bounds.x, value_bounds.y)
	
	LineEditInput.text = str(value)
	
	if value != property.value:
		property.value = value


func set_percent_value(percent: float) -> void:
	set_value(lerpf(value_bounds.x, value_bounds.y, percent))


func increment() -> void:
	_adjust_value(true)


func decrement() -> void:
	_adjust_value(false)
#endregion

#region Private Methods
func _adjust_value(mode: bool) -> void:
	var multiply: float = 1.0
	
	if Input.is_key_pressed(property.step_1_key):
		multiply = property.step_1_multiply
	
	elif Input.is_key_pressed(property.step_2_key):
		multiply = property.step_2_multiply
	
	elif Input.is_key_pressed(property.step_3_key):
		multiply = property.step_3_multiply
	
	set_value(property.value + (property.step_value if mode else -property.step_value) * multiply)


func _show_percentage_menu() -> void:
	if not _percentage_menu_items.is_empty():
		ExtendedPopupMenu.static_context_menu_from_object(LineEditInput, _percentage_menu_items)
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
func _on_LineEditInput_gui_input(event: InputEvent) -> void:
	UtilsInput.event_mouse_button_callback(event, property.percentage_menu_button_index, _show_percentage_menu)
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_property(arg: FloatProperty) -> void:
	property = arg
	base_property = property
	
	if property != null:
		UtilsSignal.connect_safe(property.changed, update)
	
	update()
#endregion

#region Getter Methods
#endregion
