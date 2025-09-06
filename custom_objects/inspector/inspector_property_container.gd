class_name InspectorPropertyContainer extends ScrollContainer

#region Signals
signal section_folded(section_title: String, is_folded: bool)
#endregion

#region Properties
@export var use_foldable_group: bool
@export var collapsed_as_default: bool
#endregion

#region Private Variables
var _vbox_sections: VBoxContainer
var _sections_cache: Dictionary[String, InspectorPropertySection]
var _foldable_group: FoldableGroup
#endregion

#region Constructor
func _ready() -> void:
	_vbox_sections = VBoxContainer.new()
	_vbox_sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox_sections.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_vbox_sections, false, Node.INTERNAL_MODE_BACK)
	
	_foldable_group = FoldableGroup.new() if use_foldable_group else null
#endregion

#region Public Methods
func add(property: InspectorProperty) -> void:
	if property == null:
		Log.error("The provided property reference is null!", add)
		return
	
	var property_section: String = property.section
	var section: InspectorPropertySection
	
	if property_section in _sections_cache:
		section = _sections_cache[property_section]
	
	else:
		section = InspectorPropertySection.new(property_section, _foldable_group)
		
		if collapsed_as_default:
			section.fold()
		
		section.folding_changed.connect(_on_section_folding_changed.bind(section))
		
		_sections_cache[property_section] = section
		_vbox_sections.add_child(section)
	
	if section == null:
		Log.error("Could not find or create a section for property: '%s'!" % property, add)
		return
	
	section.add(property)


func add_array(properties: Array[InspectorProperty]) -> void:
	for property: InspectorProperty in properties:
		add(property)


func clear() -> void:
	_sections_cache.clear()
	
	for child: Node in _vbox_sections.get_children():
		child.queue_free()


func fold_all_sections(state: bool) -> void:
	for section: InspectorPropertySection in get_sections():
		var section_is_folded: bool = section.folded
		
		if state and not section_is_folded:
			section.fold()
		
		elif not state and section_is_folded:
			section.expand()


func get_sections() -> Array[InspectorPropertySection]:
	return Array(
		_sections_cache.values(), TYPE_OBJECT, &"FoldableContainer", InspectorPropertySection
		) as Array[InspectorPropertySection]


func get_section_titles() -> PackedStringArray:
	return PackedStringArray(_sections_cache.keys())


func get_section_by_title(section_title: String) -> InspectorPropertySection:
	return _sections_cache[section_title] if section_title in _sections_cache else null
#endregion

#region Signal Callbacks
func _on_section_folding_changed(is_folded: bool, section: InspectorPropertySection) -> void:
	section_folded.emit(section.title_raw, is_folded)
#endregion
