@tool
class_name Icon
extends CompressedTexture2D

#region Export Variables
@export var modulate: Color = Color.WHITE: set = _set_modulate
@export var size: Vector2: set = _set_size
#endregion

#region Setter Methods
func _set_modulate(arg: Color) -> void:
	modulate = arg
	emit_changed()


func _set_size(arg: Vector2) -> void:
	size = arg.max(Vector2.ZERO)
	emit_changed()
#endregion
