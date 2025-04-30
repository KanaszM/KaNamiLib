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
#endregion

#region Private Variables
#endregion

#region OnReady Variables
@onready var HBoxBackground := %HBoxBackground as ExtendedHBoxContainer
@onready var VBoxBackground := %VBoxBackground as ExtendedVBoxContainer

@onready var LineEditInput := %LineEditInput as ExtendedLineEdit

@onready var ButtonIncrement := %ButtonIncrement as ExtendedButton
@onready var ButtonDecrement := %ButtonDecrement as ExtendedButton
#endregion

#region Virtual Methods
func _ready() -> void:
	ButtonIncrement.add_callback(increment)
	ButtonDecrement.add_callback(decrement)
	
	_set_property(property)
	
	super._ready()
#endregion

#region Public Methods
func update() -> bool:
	if not super.update():
		return false
	
	set_value(property.value)
	
	return true


func set_value(value: float) -> void:
	LineEditInput.text = str(value)
	
	if value != property.value:
		property.value = value


func increment() -> void:
	if property.step > 0.0:
		set_value(property.value + property.step)


func decrement() -> void:
	if property.step > 0.0:
		set_value(property.value - property.step)
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
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
