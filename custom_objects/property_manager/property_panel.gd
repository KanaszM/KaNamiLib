@tool
class_name PropertyPanel
extends ExtendedPanelContainer

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var options_override: PropertyPanelOptions: set = _set_options_override
#endregion

#region Public Variables
var base_property: Property
#endregion

#region Private Variables
var _update_enabled: bool
var _panel_width_resize_blocked: bool
#endregion

#region OnReady Variables
@onready var MarginBackground := %MarginBackground as ExtendedMarginContainer
@onready var GridBackground := %GridBackground as ExtendedGridContainer
@onready var LabelName := %LabelName as ExtendedLabel
@onready var PanelContents := %PanelContents as ExtendedPanelContainer
#endregion

#region Virtual Methods
func _ready() -> void:
	_update_enabled = true
	update()


func _to_string() -> String:
	return (
		"<PropertyPanel[%s]>"
		% ("NULL" if base_property == null else str(base_property).trim_prefix("<").trim_suffix(">"))
		)
#endregion

#region Public Methods
func update() -> bool:
	# Start
	if not _update_enabled or base_property == null:
		return false
	
	#region Options Setup
	var options: PropertyPanelOptions
	
	if options_override != null:
		options = options_override
	
	else:
		var parent: Node = get_parent()
		
		if not parent is PropertyPanelContainer:
			return false
		
		var panel_container := parent as PropertyPanelContainer
		
		if panel_container.options == null:
			return false
		
		options = panel_container.options
	#endregion
	
	#region Self Setup
	if not Engine.is_editor_hint():
		name = &"PropertyPanel%s%s" % [base_property.type_to_str(), base_property.name]
	#endregion
	
	#region MarginBackground Setup
	MarginBackground.margin_left_right = options.sizing_margins.x
	MarginBackground.margin_top_bottom = options.sizing_margins.y
	#endregion
	
	#region LabelName Setup
	match options.label_display_mode:
		PropertyPanelOptions.LabelDisplayMode.NAME:
			LabelName.text = base_property.name
		
		PropertyPanelOptions.LabelDisplayMode.ADDRESS_LOWERED:
			LabelName.text = base_property.get_address()
		
		PropertyPanelOptions.LabelDisplayMode.ADDRESS_CAPITALIZED:
			LabelName.text = base_property.get_address(" ", false)
		
		_:
			LabelName.text = ""
	
	LabelName.visible = not LabelName.text.is_empty()
	LabelName.horizontal_alignment = options.label_h_alignment
	LabelName.vertical_alignment = options.label_v_alignment
	LabelName.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL if options.label_position_is_horizontal else Control.SIZE_SHRINK_CENTER
		)
	
	if not _panel_width_resize_blocked:
		LabelName.custom_minimum_size = options.sizing_label_min_size
	#endregion
	
	#region GridBackground Setup
	GridBackground.columns = maxi(1, int(LabelName.visible) + int(options.label_position_is_horizontal))
	GridBackground.set_separation(options.sizing_separation)
	GridBackground.move_child(LabelName, int(options.label_position_is_bottom_or_right))
	#endregion
	
	#region PanelContents Setup
	PanelContents.visible = options.contents_position != PropertyPanelOptions.ContentsPosition.NONE
	PanelContents.custom_minimum_size = options.sizing_contents_min_size
	
	match options.contents_position:
		PropertyPanelOptions.ContentsPosition.LEFT_OR_TOP: 
			PanelContents.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
			PanelContents.size_flags_vertical = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
			
		PropertyPanelOptions.ContentsPosition.RIGHT_OR_BOTTOM: 
			PanelContents.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
			PanelContents.size_flags_vertical = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
			
		PropertyPanelOptions.ContentsPosition.CENTER: 
			PanelContents.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
			PanelContents.size_flags_vertical = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
		
		PropertyPanelOptions.ContentsPosition.FILLED:
			PanelContents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			PanelContents.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if options.theme_contents_panel_style_override == null:
		PanelContents.set_empty_style()
	
	else:
		PanelContents.set_style(options.theme_contents_panel_style_override)
	#endregion
	
	# End
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
func _set_options_override(arg: PropertyPanelOptions) -> void:
	options_override = arg
	
	if options_override != null:
		UtilsSignal.connect_safe(options_override.changed, update)
	
	update()
#endregion

#region Getter Methods
#endregion
