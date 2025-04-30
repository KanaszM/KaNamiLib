@tool
class_name PropertySection
extends Resource

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var name: String: set = _set_name, get = _get_name
@export_multiline var description: String: set = _set_description, get = _get_description
@export var enabled: bool = true: set = _set_enabled
@export var parent: PropertySection: set = set_parent

@export_group("Icon", "icon_")
@export var icon_texture: CompressedTexture2D: set = _set_icon_texture
@export var icon_size: Vector2: set = _set_icon_size
@export var icon_modulate: Color = Color.WHITE: set = _set_icon_modulate
#endregion

#region Public Variables
var id: int = -1
var properties: Array[Property]: set = set_properties
#endregion

#region Private Variables
var _structure_changed_emission_blocked: bool
var _icon_changed_emission_blocked: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	name = name_arg


func _to_string() -> String:
	return (
		"<PropertySection#%d[%s][%s][%s][%d]>"
		% [
			id,
			name,
			enabled,
			"NULL" if parent == null else parent.name,
			properties.size(),
			]
		)
#endregion

#region Public Methods
func is_valid() -> bool:
	if id == -1:
		Logger.error(is_valid, "Invalid ID!")
		return false
	
	return true


func set_structure(parent_arg: PropertySection = null, properties_arg: Array[Property] = []) -> PropertySection:
	_structure_changed_emission_blocked = true
	
	parent = parent_arg
	properties = properties_arg
	
	_structure_changed_emission_blocked = false
	emit_changed()
	
	return self


func set_parent(parent_arg: PropertySection) -> PropertySection:
	if parent_arg == self:
		Logger.error(set_parent, "The section parent must be different than self!")
	
	else:
		parent = parent_arg
		
		if parent != null:
			UtilsSignal.connect_safe(parent.changed, emit_changed)
		
		emit_changed()
	
	return self


func set_properties(properties_arg: Array[Property]) -> PropertySection:
	var unique_properties: Array[Property]
	
	for property: Property in properties_arg:
		if property == null:
			continue
		
		if property in unique_properties:
			Logger.error(set_properties, "Duplicate property found: %s!" % property)
		
		else:
			property.section = self
			unique_properties.append(property)
	
	properties = unique_properties
	
	if not _structure_changed_emission_blocked:
		emit_changed()
	
	return self


func set_icon(texture: CompressedTexture2D, size: Vector2, color: Color = Color.WHITE) -> PropertySection:
	_icon_changed_emission_blocked = true
	
	icon_texture = texture
	icon_size = size
	icon_modulate = color
	
	_icon_changed_emission_blocked = false
	emit_changed()
	
	return self
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
func _set_name(arg: String) -> void:
	name = arg
	id = hash(name)
	emit_changed()


func _set_description(arg: String) -> void:
	description = arg
	emit_changed()


func _set_enabled(arg: bool) -> void:
	enabled = arg
	emit_changed()

# Icon
func _set_icon_texture(arg: CompressedTexture2D) -> void:
	icon_texture = arg
	
	if not _icon_changed_emission_blocked:
		emit_changed()


func _set_icon_size(arg: Vector2) -> void:
	icon_size = arg.max(Vector2.ZERO)
	
	if not _icon_changed_emission_blocked:
		emit_changed()


func _set_icon_modulate(arg: Color) -> void:
	icon_modulate = arg
	
	if not _icon_changed_emission_blocked:
		emit_changed()
#endregion

#region Getter Methods
func _get_name() -> String:
	return UtilsText.strip(name)


func _get_description() -> String:
	return description.strip_edges()
#endregion
