@tool
class_name DebugToolsTileMap
extends Node2D

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var tile_map_layer: TileMapLayer
@export var persistent_mode: bool
@export var continuous_update_mode: bool: set = _set_continuous_update_mode
@export var draw_only_on_existing_cells: bool

@export_group("Text", "text_")
@export var text_enabled: bool
@export var text_coordinates_mode: bool
@export var text_start_from_one: bool
@export var text_color_start: Color = Color.WHITE
@export var text_color_end: Color = Color.WHITE

@export_group("Grid", "grid_")
@export var grid_enabled: bool
@export var grid_width: int: set = _set_grid_width
@export var grid_color: Color
@export var grid_background_color: Color = Color.TRANSPARENT

@export_group("Border", "border_")
@export var border_enabled: bool
@export var border_width: int = 4: set = _set_border_width
@export var border_color: Color = Color("a34b96")

@export_group("Axis", "axis_")
@export var axis_vertical_enabled: bool
@export var axis_vertical_width: int = 2: set = _set_axis_vertical_width
@export var axis_vertical_color: Color = Color("719573")
@export var axis_horizontal_enabled: bool
@export var axis_horizontal_width: int = 2: set = _set_axis_horizontal_width
@export var axis_horizontal_color: Color = Color("cb3950")

@export_group("Labels", "label_")
@export_subgroup("Title", "label_title_")
@export var label_title_text: String
@export var label_title_text_size: int = 24: set = _set_label_title_text_size
@export_subgroup("Stats", "label_stats_")
@export var label_stats_enabled: bool
@export var label_stats_text_size: int = 12: set = _set_label_stats_text_size
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _ready() -> void:
	set_process(false)
	
	if not Engine.is_editor_hint() and not persistent_mode:
		queue_free()
		return
	
	if continuous_update_mode:
		set_process(true)
	
	else:
		queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw.call_deferred()


func _draw() -> void:
	if tile_map_layer == null:
		return
	
	var tile_map_layer_rect: Rect2i = tile_map_layer.get_used_rect()
	
	if not tile_map_layer.enabled or tile_map_layer_rect.size == Vector2i.ZERO:
		return
	
	var value_offset: int = int(text_start_from_one)
	var text_font: Font = ThemeDB.fallback_font
	var max_cell_index: int = tile_map_layer_rect.size.x + tile_map_layer_rect.size.y
	var half_tile_size: Vector2 = tile_map_layer.tile_set.tile_size / 2.0
	
	var range_x: PackedInt32Array = PackedInt32Array(range(tile_map_layer_rect.position.x, tile_map_layer_rect.end.x))
	var range_y: PackedInt32Array = PackedInt32Array(range(tile_map_layer_rect.position.y, tile_map_layer_rect.end.y))
	
	var global_rect_position: Vector2 = tile_map_layer.map_to_local(Vector2i(range_x[0], range_y[0])) -half_tile_size
	var global_rect_size: Vector2 = tile_map_layer.map_to_local(tile_map_layer_rect.size) - half_tile_size
	var global_rect: Rect2 = Rect2(global_rect_position, global_rect_size)
	var global_rect_center_point: Vector2 = global_rect.position + global_rect.size / 2.0
	
	var used_cells_count: int = 0
	
	for x: int in range_x.size():
		for y: int in range_y.size():
			var cell_local_position: Vector2i = Vector2i(range_x[x], range_y[y])
			var cell_is_available: bool = tile_map_layer.get_cell_source_id(cell_local_position) >= 0
			var can_draw: bool = true if not draw_only_on_existing_cells else cell_is_available
			
			used_cells_count += int(cell_is_available)
			
			if can_draw:
				var cell_index: int = x + y + value_offset
				var cell_global_position: Vector2 = tile_map_layer.map_to_local(cell_local_position)
				
				if grid_enabled:
					var grid_rect_position: Vector2 = cell_global_position - half_tile_size
					var grid_rect: Rect2 = Rect2(grid_rect_position, tile_map_layer.tile_set.tile_size)
					
					draw_rect(grid_rect, grid_color, false, grid_width)
					draw_rect(grid_rect, grid_background_color)
				
				if text_enabled:
					var text_string: String = (
						("%d | %d" % [x + value_offset, y + value_offset])
						if text_coordinates_mode
						else str(cell_index)
						)
					var text_font_size: int = (
						int(maxf(tile_map_layer.tile_set.tile_size.x, tile_map_layer.tile_set.tile_size.y) / 2.0)
						- len(text_string)
						- 1
						)
					var text_string_size: Vector2 = text_font.get_string_size(
						text_string, HORIZONTAL_ALIGNMENT_CENTER, -1, text_font_size
						)
					var text_color: Color = text_color_start.lerp(
						text_color_end, clampf(float(cell_index) / float(max_cell_index), 0.0, 1.0)
						)
					var text_position_offset: Vector2 = (
						cell_global_position - Vector2(text_string_size.x / 2.0, -text_string_size.y / 4.0)
						)
					var text_position: Vector2 = text_position_offset
					
					draw_string(
						text_font, 
						text_position, 
						text_string, 
						HORIZONTAL_ALIGNMENT_CENTER, 
						-1, 
						text_font_size, 
						text_color
						)
	
	if border_enabled:
		draw_rect(global_rect, border_color, false, border_width)
	
	if axis_vertical_enabled:
		var start_point: Vector2 = Vector2(global_rect_center_point.x, global_rect.position.y)
		var end_point: Vector2 = Vector2(global_rect_center_point.x, global_rect.position.y + global_rect.size.y)
		
		draw_line(start_point, end_point, axis_vertical_color, axis_vertical_width) 
	
	if axis_horizontal_enabled:
		var start_point: Vector2 = Vector2(global_rect.position.x, global_rect_center_point.y)
		var end_point: Vector2 = Vector2(global_rect.position.x + global_rect.size.x, global_rect_center_point.y)
		
		draw_line(start_point, end_point, axis_horizontal_color, axis_horizontal_width)
	
	if not label_title_text.is_empty():
		var text_position: Vector2 = Vector2(
			global_rect.position.x,
			global_rect.position.y - text_font.get_height(label_title_text_size) / 4.0
			)
		
		draw_string(text_font, text_position, label_title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_title_text_size)
	
	if label_stats_enabled:
		var text_position: Vector2 = Vector2(
			global_rect.position.x,
			global_rect.end.y + text_font.get_height(label_title_text_size) / 2.0
			) 
		var text_string_parts: PackedStringArray = PackedStringArray([
			"Position = %s | Size = %s" % [global_rect.position, global_rect.size],
			"Cells count: %d" % used_cells_count,
			])
		var text_string: String = "\n".join(text_string_parts)
		
		draw_multiline_string(
			text_font, text_position, text_string, HORIZONTAL_ALIGNMENT_LEFT, -1, label_stats_text_size
			)
#endregion

#region Public Methods
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
func _set_continuous_update_mode(arg: bool) -> void:
	continuous_update_mode = arg
	set_process(arg)

# Grid
func _set_grid_width(arg: int) -> void:
	grid_width = maxi(0, arg)

# Border
func _set_border_width(arg: int) -> void:
	border_width = maxi(0, arg)

# Axis
func _set_axis_vertical_width(arg: int) -> void:
	axis_vertical_width = maxi(0, arg)


func _set_axis_horizontal_width(arg: int) -> void:
	axis_horizontal_width = maxi(0, arg)

# Labels
func _set_label_title_text_size(arg: int) -> void:
	label_title_text_size = maxi(0, arg)


func _set_label_stats_text_size(arg: int) -> void:
	label_stats_text_size = maxi(0, arg)
#endregion

#region Getter Methods
#endregion
