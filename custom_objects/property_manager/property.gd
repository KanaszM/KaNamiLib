@tool
class_name Property
extends Resource

#region Signals
#endregion

#region Enums
enum Type {NONE, BOOL, COLOR, ENUM_BOX_ALIGN, ENUM_H_ALIGN, ENUM_V_ALIGN, FLOAT, INT, STRING}
#endregion

#region Constants
#endregion

#region Export Variables
@export var name: String: set = _set_name, get = _get_name
@export_multiline var description: String: set = _set_description, get = _get_description
@export var section: PropertySection: set = _set_section

@export_group("Icon", "icon_")
@export var icon_texture: CompressedTexture2D: set = _set_icon_texture
@export var icon_size: Vector2: set = _set_icon_size
@export var icon_modulate: Color = Color.WHITE: set = _set_icon_modulate
#endregion

#region Public Variables
var type: Type = Type.NONE
var id: int = -1
#endregion

#region Private Variables
@warning_ignore("unused_private_class_variable")
var _default_value_set: bool
var _icon_changed_emission_blocked: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(type_arg: Type = Type.NONE, name_arg: String = "") -> void:
	type = type_arg
	name = name_arg


func _to_string() -> String:
	return "<Property#%d[%s][%s]>" % [id, type_to_str(), name]
#endregion

#region Public Methods
func is_valid() -> bool:
	if id == -1:
		Logger.error(is_valid, "Invalid ID!")
		return false
	
	return true


func set_icon(texture: CompressedTexture2D, size: Vector2, color: Color = Color.WHITE) -> Property:
	_icon_changed_emission_blocked = true
	
	icon_texture = texture
	icon_size = size
	icon_modulate = color
	
	_icon_changed_emission_blocked = false
	emit_changed()
	
	return self


func get_address(delimiter: String = "_", to_lower: bool = true) -> String:
	var address_parts: PackedStringArray
	
	if section != null:
		address_parts.append_array(get_section_names(section, delimiter, to_lower))
	
	address_parts.append(_name_to_lower(name, delimiter) if to_lower else name)
	
	return delimiter.join(address_parts)


func get_section_names(
	current_section: PropertySection, delimiter: String = "_", to_lower: bool = true
	) -> PackedStringArray:
		var section_names: PackedStringArray
		
		if section_names != null:
			section_names.append(_name_to_lower(current_section.name, delimiter) if to_lower else current_section.name)
			
			if current_section.parent != null:
				section_names.append_array(get_section_names(current_section.parent, delimiter, to_lower))
		
		return section_names


func type_to_str() -> String:
	return UtilsDictionary.enum_to_str_capizalized(Type, type)
#endregion

#region Private Methods
func _name_to_lower(text: String, delimiter: String = "_") -> String:
	return text.to_lower().replace(" ", delimiter)
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


func _set_section(arg: PropertySection) -> void:
	section = arg
	
	if section != null:
		UtilsSignal.connect_safe(section.changed, emit_changed)
	
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
