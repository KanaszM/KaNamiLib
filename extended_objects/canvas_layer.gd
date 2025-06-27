@tool
class_name ExtendedCanvasLayer extends CanvasLayer

#region Constants
const MAX_LAYER: int = 128
#endregion

#region Public Methods
func set_clamped_layer(new_layer_value: int, min_limit: int = 1) -> void:
	layer = clamp_layer(new_layer_value, min_limit)


func set_layer_at_max(negative_offset: int = 0) -> void:
	layer = clamp_layer(MAX_LAYER - negative_offset)


func clamp_layer(new_layer_value: int, min_limit: int = 1) -> int:
	return clampi(new_layer_value, min_limit, MAX_LAYER)
#endregion
