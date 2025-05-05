#@tool
class_name PropertyUtils
extends RefCounted

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion

#region Static Methods
static func validate_sections_array(sections_arg: Array[PropertySection]) -> bool:
	var valid_section_ids: Collection = Collection.new()
	
	for section: PropertySection in sections_arg:
		if section.is_valid():
			if valid_section_ids.has(section.id):
				Logger.error(validate_sections_array, "Found duplicate section: %s!" % section)
				continue
			
			valid_section_ids.add(section.id)
	
	return valid_section_ids.size() == sections_arg.size()


static func group_properties_by_sections(sections: Array[PropertySection]) -> Dictionary[PropertySection, Variant]:
	var tree: Dictionary[PropertySection, Variant] = {}
	var section_tree_map: Dictionary[PropertySection, Array] = {}
	
	for section: PropertySection in sections:
		section_tree_map[section] = []
	
	for section: PropertySection in sections:
		if section.parent != null and section.parent in section_tree_map:
			section_tree_map[section.parent].append(section)
	
	for section: PropertySection in sections:
		if section.parent == null:
			tree[section] = _build_grouped_properties_by_sections_tree(section, section_tree_map)

	return tree


static func _build_grouped_properties_by_sections_tree(
	section: PropertySection, section_tree_map: Dictionary[PropertySection, Array]
	) -> Variant: # Array[Property] or Dictionary[PropertySection, Variant]
		var child_sections: Array = section_tree_map[section]
		
		if child_sections.is_empty():
			return section.properties
		
		else:
			var branch: Dictionary[PropertySection, Variant] = {}
			
			for child_section: PropertySection in child_sections:
				branch[child_section] = _build_grouped_properties_by_sections_tree(child_section, section_tree_map)
			
			return branch
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
