@tool
class_name ColorPropertyPanel
extends PropertyPanel

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var property: ColorProperty: set = _set_property
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
@onready var ButtonInput := %ButtonInput as ColorPickerButton
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
	
	ButtonInput.color = property.value
	
	return true
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
func _set_property(arg: ColorProperty) -> void:
	property = arg
	base_property = property
	
	if property != null:
		UtilsSignal.connect_safe(property.changed, update)
	
	update()
#endregion

#region Getter Methods
#endregion
