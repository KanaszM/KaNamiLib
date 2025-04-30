@tool
class_name PropertyPanelContainer
extends BoxContainer

#region Signals
#endregion

#region Enums
#endregion

#region Constants
const PANEL_PACKS: Dictionary[Property.Type, PackedScene] = {
	Property.Type.BOOL: preload("uid://d2v60saou2ms8"),
	Property.Type.COLOR: preload("uid://bemvjreg8ctkl"),
	Property.Type.FLOAT: preload("uid://dlbbdyjawb1iu"),
	}
#endregion

#region Export Variables
@export var options: PropertyPanelOptions: set = _set_options
@export var auto_resize_labels: bool: set = _set_auto_resize_labels
#endregion

#region Public Variables
#endregion

#region Private Variables
var _update_enabled: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _ready() -> void:
	vertical = true
	child_order_changed.connect(update)
	
	_set_options(options)
	_set_auto_resize_labels(auto_resize_labels)
	
	_update_enabled = true
	update()
#endregion

#region Public Methods
func update() -> void:
	if not _update_enabled:
		return
	
	var property_panels: Array[PropertyPanel] = get_property_panels()
	
	property_panels.map(func(property_panel: PropertyPanel) -> void:
		property_panel._panel_width_resize_blocked = auto_resize_labels
		property_panel.update()
		)
	
	if auto_resize_labels:
		var max_text_width: float
		
		for property_panel: PropertyPanel in property_panels:
			var text_size: Vector2 = property_panel.LabelName.get_font_text_size()
			
			max_text_width = maxf(max_text_width, text_size.x)
			
		for property_panel: PropertyPanel in property_panels:
			property_panel.LabelName.custom_minimum_size.x = max_text_width


func add_property_panel(property: Property) -> void:
	if property == null:
		Logger.error(add_property_panel, "The provided Property is null!")
		return
	
	if not property.type in PANEL_PACKS:
		if options != null and options.debug_log_warnings:
			Logger.warning(
				add_property_panel, "The provided Property type: %s, is not implemented yet" % property.type_to_str()
				)
		return
	
	var property_panel := PANEL_PACKS[property.type].instantiate() as PropertyPanel
	
	property_panel.set(&"property", property)
	
	add_child(property_panel)


func get_property_panels() -> Array[PropertyPanel]:
	return Array(
		get_children().filter(func(child: Node) -> bool: return child is PropertyPanel),
		TYPE_OBJECT, &"PanelContainer", PropertyPanel
		)
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
func _set_options(arg: PropertyPanelOptions) -> void:
	options = arg
	
	if options != null:
		UtilsSignal.connect_safe(options.changed, update)
	
	update()


func _set_auto_resize_labels(arg: bool) -> void:
	auto_resize_labels = arg
	update()
#endregion

#region Getter Methods
#endregion
