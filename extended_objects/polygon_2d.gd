@tool
class_name ExtendedPolygon2D extends Polygon2D

#region Signals
signal polygon_changed
signal color_changed
#endregion

#region Enums
enum CollisionType {NONE, AREA, BODY}
enum ShaperType {NONE, CIRCLE, RECTANGLE}
#endregion

#region Constants
const TOOL_STORE_FILE_NAME: String = "_poly_store.cfg"
const TOOL_STORE_DEFAULT_SECTION: String = "1"
const TOOL_STORE_DEFAULT_KEY: String = "1"
#endregion

#region Export Variables
@export_group("Collision", "collision_")
@export var collision_type: CollisionType = CollisionType.NONE: set = _set_collision_type

@export_category("Tools")

@export_group("General", "tool_general_")
@export_tool_button("Reset") var tool_general_reset: Callable = _execute_tool_reset
@export_tool_button("Print") var tool_general_print: Callable = _execute_tool_print

@export_group("Offset", "tool_offset_")
@export var tool_offset_delta: float = 8.0
@export var tool_offset_join_type: Geometry2D.PolyJoinType = Geometry2D.PolyJoinType.JOIN_MITER
@export_tool_button("Expand") var tool_offset_expand: Callable = _execute_tool_offset.bind(true)
@export_tool_button("Shrink") var tool_offset_shrink: Callable = _execute_tool_offset.bind(false)

@export_group("Flip", "tool_flip_")
@export_tool_button("Horizontally") var tool_flip_horizontally: Callable = _execute_tool_flip.bind(true)
@export_tool_button("Vertically") var tool_flip_vertically: Callable = _execute_tool_flip.bind(false)

@export_group("Store", "tool_store_")
@export var tool_store_section: String = TOOL_STORE_DEFAULT_SECTION
@export var tool_store_key: String = TOOL_STORE_DEFAULT_KEY
@export var tool_store_save_overwrite: bool
@export_tool_button("Save") var tool_store_save: Callable = _execute_tool_store.bind(true)
@export_tool_button("Load") var tool_store_load: Callable = _execute_tool_store.bind(false)

@export_group("Shaper", "tool_shaper_")
@export var tool_shaper_type: ShaperType
@export var tool_shaper_center_point: Vector2
@export_tool_button("Apply") var tool_shaper_apply: Callable = _execute_tool_shaper
@export_subgroup("Circle Properties", "tool_shaper_circle_")
@export var tool_shaper_circle_radius: float
@export var tool_shaper_circle_angle_to: float = TAU
@export var tool_shaper_circle_angle_from: float
@export_range(3, 128, 1) var tool_shaper_circle_detail: int = 64
@export_subgroup("Rectangle Properties", "tool_shaper_rectangle_")
@export var tool_shaper_rectangle_size: Vector2
@export var tool_shaper_rectangle_corner_radius: float
@export var tool_shaper_rectangle_corner_segments: int

@export_group("Drawing", "tool_draw_")
@export var tool_draw_enabled: bool: set = _set_tool_draw_enabled
@export var tool_draw_editor_only: bool = true
@export_subgroup("Rect", "tool_draw_rect_")
@export var tool_draw_rect_enabled: bool: set = _set_tool_draw_rect_enabled
@export var tool_draw_rect_color: Color = Color.RED: set = _set_tool_draw_rect_color
@export var tool_draw_rect_width: int = 2: set = _set_tool_draw_rect_width
@export_subgroup("Label", "tool_draw_label_")
@export var tool_draw_label_enabled: bool: set = _set_tool_draw_label_enabled
@export var tool_draw_label_centered: bool: set = _set_tool_draw_label_centered
@export var tool_draw_label_text: String: set = _set_tool_draw_label_text
@export var tool_draw_label_size: int = 16: set = _set_tool_draw_label_size
@export var tool_draw_label_color: Color = Color.WHITE: set = _set_tool_draw_label_color
@export var tool_draw_label_shadow_color: Color = Color.BLACK: set = _set_tool_draw_label_shadow_color
@export var tool_draw_label_shadow_offset: Vector2 = Vector2.ONE: set = _set_tool_draw_label_shadow_offset
@export var tool_draw_label_shadow_size: int: set = _set_tool_draw_label_shadow_size
#endregion

#region Public Variables
var collision_object: CollisionObject2D
#endregion

#region Private Variables
var _tool_draw_queue_enabled: bool
var _update_collision_enabled: bool

var _collision_area: Area2D
var _collision_body: StaticBody2D
var _collision_polygon: CollisionPolygon2D

var _triangles: PackedInt32Array
var _triangle_areas: PackedInt32Array
#endregion

#region Public Methods
func set_collision_layer_value(layer_number: int, value: bool) -> void:
	if collision_object != null:
		collision_object.set_collision_layer_value(layer_number, value)


func set_collision_mask_value(layer_number: int, value: bool) -> void:
	if collision_object != null:
		collision_object.set_collision_mask_value(layer_number, value)


func get_random_point() -> Vector2:
	if _triangle_areas.is_empty():
		return Vector2.ZERO
	
	var idx: int = _triangle_areas.bsearch(int(randf() * _triangle_areas[-1]))
	var point_a: Vector2 = polygon[_triangles[3 * idx + 0]]
	var point_b: Vector2 = polygon[_triangles[3 * idx + 1]]
	var point_c: Vector2 = polygon[_triangles[3 * idx + 2]]
	
	return UtilsRandom.get_triangle_point(point_a, point_b, point_c)
#endregion

#region Private Methods
func _set(property: StringName, value: Variant) -> bool:
	var is_handled: bool = true
	
	match property:
		&"polygon":
			polygon = value
			_update_collision()
			_update_triangles()
			polygon_changed.emit()
		
		&"color":
			color = value
			color_changed.emit()
		
		_:
			is_handled = false
	
	return is_handled


func _ready() -> void:
	_set_collision_type(collision_type)
	
	_set_tool_draw_enabled(tool_draw_enabled)
	_set_tool_draw_rect_enabled(tool_draw_rect_enabled)
	_set_tool_draw_rect_color(tool_draw_rect_color)
	_set_tool_draw_rect_width(tool_draw_rect_width)
	_set_tool_draw_label_enabled(tool_draw_label_enabled)
	_set_tool_draw_label_centered(tool_draw_label_centered)
	_set_tool_draw_label_size(tool_draw_label_size)
	_set_tool_draw_label_color(tool_draw_label_color)
	_set_tool_draw_label_shadow_color(tool_draw_label_shadow_color)
	_set_tool_draw_label_shadow_offset(tool_draw_label_shadow_offset)
	_set_tool_draw_label_shadow_size(tool_draw_label_shadow_size)
	
	_tool_draw_queue_enabled = true
	_update_collision_enabled = true
	
	_update_collision()
	_update_triangles()
	
	queue_redraw()


func _draw() -> void:
	if (
		not _tool_draw_queue_enabled
		or not tool_draw_enabled
		or (not Engine.is_editor_hint() and tool_draw_editor_only)
		):
			return
	
	var rect: Rect2
	var rect_half_size: Vector2
	
	if tool_draw_rect_enabled or tool_draw_label_enabled:
		rect = UtilsGeometry.get_polygon_rect(polygon)
		rect_half_size = rect.size / 2.0
		
		if rect.size == Vector2.ZERO:
			return
	
	if tool_draw_rect_enabled:
		draw_rect(rect, tool_draw_rect_color, false, tool_draw_rect_width)
	
	if tool_draw_label_enabled:
		var text: String = str(self) if tool_draw_label_text.is_empty() else tool_draw_label_text
		var text_font: Font = ThemeDB.fallback_font
		var text_size: Vector2 = text_font.get_string_size(
			text, HORIZONTAL_ALIGNMENT_CENTER, -1, tool_draw_label_size
			)
		var label_initial_position: Vector2 = rect.position
		
		if tool_draw_label_centered:
			label_initial_position += Vector2.DOWN * rect_half_size.y
		
		var label_position: Vector2 = Vector2(
				(label_initial_position.x + rect_half_size.x) - text_size.x / 2.0,
				label_initial_position.y - (text_size.y + float(tool_draw_rect_width)) / 2.0
				) 
		
		draw_string(
			text_font, 
			label_position + tool_draw_label_shadow_offset, 
			text, 
			HORIZONTAL_ALIGNMENT_CENTER, 
			-1, 
			tool_draw_label_size + tool_draw_label_shadow_size, 
			tool_draw_label_shadow_color
			)
		
		draw_string(
			text_font, 
			label_position, 
			text, 
			HORIZONTAL_ALIGNMENT_CENTER, 
			-1, 
			tool_draw_label_size, 
			tool_draw_label_color
			)


func _update_collision() -> void:
	if not _update_collision_enabled:
		return
	
	match collision_type:
		CollisionType.AREA, CollisionType.BODY:
			match collision_type:
				CollisionType.AREA:
					if _collision_body != null:
						_collision_body.queue_free()
						_collision_body = null
						_collision_polygon = null
					
					if _collision_area == null:
						_collision_area = Area2D.new()
						add_child(_collision_area, false, Node.INTERNAL_MODE_BACK)
					
					collision_object = _collision_area
				
				CollisionType.BODY:
					if _collision_area != null:
						_collision_area.queue_free()
						_collision_area = null
						_collision_polygon = null
					
					if _collision_body == null:
						_collision_body = StaticBody2D.new()
						add_child(_collision_body, false, Node.INTERNAL_MODE_BACK)
					
					collision_object = _collision_body
			
			if _collision_polygon == null:
				_collision_polygon = CollisionPolygon2D.new()
				_collision_polygon.self_modulate.a = 0.0
				collision_object.add_child(_collision_polygon, false, Node.INTERNAL_MODE_BACK)
			
			_collision_polygon.polygon = polygon
		
		_:
			if _collision_area != null:
				_collision_area.queue_free()
				_collision_area = null
			
			if _collision_body != null:
				_collision_body.queue_free()
				_collision_body = null
			
			_collision_polygon = null
			collision_object = null


func _update_triangles() -> void:
	_triangles = Geometry2D.triangulate_polygon(polygon)
	_triangle_areas.clear()
	
	var triangle_count: int = int(_triangles.size() / 3.0)
	
	if triangle_count <= 0:
		return
	
	_triangle_areas.resize(triangle_count)
	_triangle_areas[-1] = 0
	
	for idx: int in triangle_count:
		var point_a: Vector2 = polygon[_triangles[3 * idx + 0]]
		var point_b: Vector2 = polygon[_triangles[3 * idx + 1]]
		var point_c: Vector2 = polygon[_triangles[3 * idx + 2]]
		var area: int = int(UtilsGeometry.get_triangle_area(point_a, point_b, point_c))
		
		_triangle_areas[idx] = _triangle_areas[idx - 1] + area


func _execute_tool_reset() -> void:
	position = Vector2.ZERO
	rotation = 0.0
	scale = Vector2.ONE
	skew = 0.0
	set(&"polygon", PackedVector2Array([]))


func _execute_tool_print() -> void:
	print(DebugToolsPrint.get_variable_value_string(polygon))


func _execute_tool_offset(mode: bool) -> void:
	set(&"polygon", UtilsGeometry.get_offsetted_polygon(polygon, mode, tool_offset_delta, tool_offset_join_type))


func _execute_tool_flip(mode: bool) -> void:
	set(&"polygon", UtilsGeometry.get_flipped_polygon(polygon, mode))


func _execute_tool_store(mode: bool) -> void:
	if not OS.is_debug_build():
		return
	
	var store_path_options: PathOptions = PathOptions.new()
	
	store_path_options.logging_type = PathOptions.LoggingType.ENGINE
	store_path_options.logging_errors_enabled = true
	store_path_options.logging_successes_enabled = true
	store_path_options.logging_warnings_enabled = true
	store_path_options.file_create_if_not_exists = true
	
	var store_path: Path = Path.new_user_data_dir(store_path_options).join(TOOL_STORE_FILE_NAME)
	var store_cfg: ConfigFile = ConfigFile.new()
	var store_tool_name: String = tool_store_key.strip_edges()
	var store_tool_section: String = tool_store_section.strip_edges()
	var store_section: String = (
		TOOL_STORE_DEFAULT_SECTION if store_tool_section.is_empty() else store_tool_section
		)
	var store_key: String = (
		TOOL_STORE_DEFAULT_KEY if store_tool_name.is_empty() else store_tool_name
		)
	var store_address: String = "[%s][%s]" % [store_section, store_key]
	
	var store_load_error_code: Error = store_cfg.load(store_path.path)
	
	if store_load_error_code != OK:
		push_error(
			"Could not load the config file at path: '%s'! Error: %s" % [
				store_path.path, error_string(store_load_error_code),
				]
			)
		return
	
	if mode:
		if not tool_store_save_overwrite and store_cfg.has_section_key(store_section, store_key):
			push_warning("The polygon is already stored at address: '%s'." % store_address)
			return
		
		store_cfg.set_value(store_section, store_key, polygon)
		
		var store_save_error_code: Error = store_cfg.save(store_path.path)
		
		if store_save_error_code != OK:
			push_error(
				"Could not store the polygon at address: '%s'! Error: %s" % [
					store_address, error_string(store_save_error_code),
					]
				)
	
	else:
		var store_value: Variant = store_cfg.get_value(TOOL_STORE_DEFAULT_SECTION, store_key)
		var store_value_type: int = typeof(store_value)
		
		if store_value_type != TYPE_PACKED_VECTOR2_ARRAY:
			push_error(
				"Invalid stored value type: '%s', on address: '%s'!" % [
					type_string(store_value_type), store_address,
					]
				)
			return
		
		set_deferred(&"polygon", store_value)


func _execute_tool_shaper() -> void:
	var points: PackedVector2Array
	
	match tool_shaper_type:
		ShaperType.CIRCLE:
			if tool_shaper_circle_radius <= 0.0:
				return
			
			if tool_shaper_circle_angle_to != TAU:
				points.append(tool_shaper_center_point)
			
			var start: float = tool_shaper_circle_angle_from - (PI / 2.0)
			var end: float = (
				(tool_shaper_circle_angle_to - tool_shaper_circle_angle_from)
				/ float(tool_shaper_circle_detail)
				)
			
			for detail_idx: int in range(tool_shaper_circle_detail + 1):
				var angle_point: float = start + float(detail_idx) * end
				var point: Vector2 = (
					tool_shaper_center_point
					+ Vector2(cos(angle_point), sin(angle_point))
					* tool_shaper_circle_radius
					)
				
				if point.distance_to(tool_shaper_center_point) > 0.001:
					points.push_back(point)
		
		ShaperType.RECTANGLE:
			if tool_shaper_rectangle_size.x <= 0.0 or tool_shaper_rectangle_size.y <= 0.0:
				return
			
			var half_size: Vector2 = tool_shaper_rectangle_size / 2.0
			
			if tool_shaper_rectangle_corner_radius > 0.0:
				var corner_limit: float = clampf(
					tool_shaper_rectangle_corner_radius, 0.0, minf(half_size.x, half_size.y)
					)
				var corner_segments: int = maxi(1, tool_shaper_rectangle_corner_segments)
				var corner_centers: PackedVector2Array = PackedVector2Array([
					Vector2(-half_size.x + corner_limit, -half_size.y + corner_limit),
					Vector2(half_size.x - corner_limit, -half_size.y + corner_limit),
					Vector2(half_size.x - corner_limit, half_size.y - corner_limit),
					Vector2(-half_size.x + corner_limit, half_size.y - corner_limit),
					])
				var corner_ranges_start: PackedFloat32Array = PackedFloat32Array([
					PI,
					PI * 1.5,
					0.0,
					PI * 0.5,
					])
				var corner_ranges_end: PackedFloat32Array = PackedFloat32Array([
					PI * 1.5,
					PI * 2.0,
					PI * 0.5,
					PI,
					])
				
				for corner_idx: int in 4:
					var corner_range: Vector2 = Vector2(
						corner_ranges_start[corner_idx], corner_ranges_end[corner_idx]
						)
					var corner_center: Vector2 = corner_centers[corner_idx]
					
					for segment_idx: int in range(corner_segments + 1):
						var x: float = float(segment_idx) / float(corner_segments)
						var y: float = lerpf(corner_range.x, corner_range.y, x)
						var z: Vector2 = corner_center + Vector2(cos(y), sin(y)) * corner_limit
						
						points.append(tool_shaper_center_point + z)
			
			else:
				points.append_array([
					tool_shaper_center_point + Vector2(-half_size.x, -half_size.y),
					tool_shaper_center_point + Vector2(half_size.x, -half_size.y),
					tool_shaper_center_point + Vector2(half_size.x, half_size.y),
					tool_shaper_center_point + Vector2(-half_size.x, half_size.y),
					])
	
	if points.size() > 2:
		set(&"polygon", points)
#endregion

#region Setter Methods
# Collision
func _set_collision_type(arg: CollisionType) -> void:
	collision_type = arg
	_update_collision()

# Draw
func _set_tool_draw_enabled(arg: bool) -> void:
	tool_draw_enabled = arg
	queue_redraw()

# Draw Rect
func _set_tool_draw_rect_enabled(arg: bool) -> void:
	tool_draw_rect_enabled = arg
	queue_redraw()


func _set_tool_draw_rect_color(arg: Color) -> void:
	tool_draw_rect_color = arg
	queue_redraw()


func _set_tool_draw_rect_width(arg: int) -> void:
	tool_draw_rect_width = arg
	queue_redraw()

# Draw Label
func _set_tool_draw_label_enabled(arg: bool) -> void:
	tool_draw_label_enabled = arg
	queue_redraw()


func _set_tool_draw_label_centered(arg: bool) -> void:
	tool_draw_label_centered = arg
	queue_redraw()


func _set_tool_draw_label_text(arg: String) -> void:
	tool_draw_label_text = arg
	queue_redraw()


func _set_tool_draw_label_size(arg: int) -> void:
	tool_draw_label_size = arg
	queue_redraw()


func _set_tool_draw_label_color(arg: Color) -> void:
	tool_draw_label_color = arg
	queue_redraw()


func _set_tool_draw_label_shadow_color(arg: Color) -> void:
	tool_draw_label_shadow_color = arg
	queue_redraw()


func _set_tool_draw_label_shadow_offset(arg: Vector2) -> void:
	tool_draw_label_shadow_offset = arg
	queue_redraw()


func _set_tool_draw_label_shadow_size(arg: int) -> void:
	tool_draw_label_shadow_size = maxi(0, arg)
	queue_redraw()
#endregion
