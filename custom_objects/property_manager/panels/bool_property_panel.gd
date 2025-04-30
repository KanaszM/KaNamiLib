@tool
class_name BoolPropertyPanel
extends PropertyPanel

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var property: BoolProperty: set = _set_property
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
@onready var InputContainer := %InputContainer as Control
@onready var ButtonInput := %ButtonInput as ExtendedCheckBox
#endregion

#region Virtual Methods
func _ready() -> void:
	InputContainer.gui_input.connect(_on_InputContainer_gui_input)
	
	_set_property(property)
	
	super._ready()
#endregion

#region Public Methods
func update() -> bool:
	if not super.update():
		return false
	
	set_pressed(property.value, false)
	
	return true


func is_pressed() -> bool:
	return ButtonInput.button_pressed


func set_pressed(state: bool, grab_focus_enabled: bool = true) -> void:
	ButtonInput.button_pressed = state
	
	if grab_focus_enabled:
		ButtonInput.grab_focus()


func toggle_pressed(grab_focus_enabled: bool = true) -> void:
	set_pressed(not is_pressed(), grab_focus_enabled)
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
func _on_InputContainer_gui_input(event: InputEvent) -> void:
	UtilsInput.event_mouse_button_callback(event, MOUSE_BUTTON_LEFT, toggle_pressed)
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_property(arg: BoolProperty) -> void:
	property = arg
	base_property = property
	
	if property != null:
		UtilsSignal.connect_safe(property.changed, update)
	
	update()
#endregion

#region Getter Methods
#endregion
