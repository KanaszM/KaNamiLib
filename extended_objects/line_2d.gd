@tool
class_name ExtendedLine2D
extends Line2D

#region Signals
#endregion

#region Enums
enum SyncColorMode {DEFAULT, SYNCED, BLENDED}
#endregion

#region Constants
#endregion

#region Export Variables
@export_group("Polygon Sync", "sync_")
@export var sync_polygon: ExtendedPolygon2D: set = _set_sync_polygon
@export var sync_color_mode: SyncColorMode = SyncColorMode.DEFAULT: set = _set_sync_color_mode
#endregion

#region Public Variables
#endregion

#region Private Variables
var _update_synced_polygon_enabled: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _ready() -> void:
	_set_sync_polygon(sync_polygon)
	_set_sync_color_mode(sync_color_mode)
	
	_update_synced_polygon_enabled = true
	_update_synced_polygon()
#endregion

#region Public Methods
func get_synced_polygon() -> PackedVector2Array:
	if sync_polygon == null:
		return PackedVector2Array([])
	
	if sync_polygon.polygon.size() < 2:
		return PackedVector2Array([])
	
	var result: PackedVector2Array = sync_polygon.polygon.duplicate()
	var first_point: Vector2 = sync_polygon.polygon[0]
	var middle_point: Vector2 = first_point + (sync_polygon.polygon[1] - first_point) * 0.5

	result[0] = middle_point
	result.append(first_point)
	result.append(middle_point)
	
	return result


func get_synced_color() -> Color:
	var result: Color
	var polygon_is_available: bool = sync_polygon != null
	
	match sync_color_mode:
		SyncColorMode.SYNCED when polygon_is_available: result = sync_polygon.color
		SyncColorMode.BLENDED when polygon_is_available: result = default_color.blend(sync_polygon.color)
		_: result = default_color
	
	return result
#endregion

#region Private Methods
func _update_synced_polygon() -> void:
	if not _update_synced_polygon_enabled:
		return
	
	if sync_polygon != null:
		for signal_reference: Signal in [sync_polygon.polygon_changed, sync_polygon.color_changed]:
			UtilsSignal.connect_safe(signal_reference, _update_synced_polygon)
		
		points = get_synced_polygon()
		default_color = get_synced_color()
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
# Polygon Sync
func _set_sync_polygon(arg: ExtendedPolygon2D) -> void:
	sync_polygon = arg
	_update_synced_polygon()


func _set_sync_color_mode(arg: SyncColorMode) -> void:
	sync_color_mode = arg
	_update_synced_polygon()
#endregion

#region Getter Methods
#endregion
