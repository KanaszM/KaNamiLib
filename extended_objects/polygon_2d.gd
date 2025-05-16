@tool
class_name ExtendedPolygon2D
extends Polygon2D

#region Signals
signal polygon_changed
signal color_changed
#endregion

#region Enums
enum BorderColorMode {DEFAULT, SYNCED, BLENDED}
#endregion

#region Constants
#endregion

#region Export Variables
@export_group("Border", "border_")
@export var border_enabled: bool: set = _set_border_enabled
@export var border_width: int = 4: set = _set_border_width
@export var border_joint_mode: Line2D.LineJointMode = Line2D.LINE_JOINT_SHARP: set = _set_border_joint_mode
@export var border_antialiased: bool: set = _set_border_antialiased
@export_subgroup("Color", "border_color_")
@export var border_color_value: Color: set = _set_border_color_value
@export var border_color_mode: BorderColorMode = BorderColorMode.SYNCED: set = _set_border_color_mode
@export_subgroup("Texture", "border_texture_")
@export var border_texture: CompressedTexture2D = CustomAssets.IMG_GRADIENT_BAR_HORIZONTAL: set = _set_border_texture
@export var border_texture_show_behind_parent: bool: set = _set_border_texture_show_behind_parent

@export_group("Drawing", "draw_")
@export var draw_enabled: bool: set = _set_draw_enabled
@export var draw_editor_only: bool = true
@export_subgroup("Rect", "draw_rect_")
@export var draw_rect_enabled: bool: set = _set_draw_rect_enabled
@export var draw_rect_color: Color = Color.RED: set = _set_draw_rect_color
@export var draw_rect_width: int = 2: set = _set_draw_rect_width
@export_subgroup("Label", "draw_label_")
@export var draw_label_enabled: bool: set = _set_draw_label_enabled
@export var draw_label_size: int = 16: set = _set_draw_label_size
@export var draw_label_color: Color = Color.WHITE: set = _set_draw_label_color
#endregion

#region Public Variables
var border_line: Line2D
#endregion

#region Private Variables
var _update_enabled: bool
var _draw_queue_enabled: bool
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _set(property: StringName, value: Variant) -> bool:
	var is_handled: bool = true
	
	match property:
		&"polygon":
			polygon = value
			polygon_changed.emit()
		
		&"color":
			color = value
			color_changed.emit()
		
		_:
			is_handled = false
	
	return is_handled


func _ready() -> void:
	_set_border_enabled(border_enabled)
	_set_border_width(border_width)
	_set_border_joint_mode(border_joint_mode)
	_set_border_antialiased(border_antialiased)
	_set_border_color_value(border_color_value)
	_set_border_color_mode(border_color_mode)
	_set_border_texture(border_texture)
	_set_border_texture_show_behind_parent(border_texture_show_behind_parent)
	
	_set_draw_enabled(draw_enabled)
	_set_draw_rect_enabled(draw_rect_enabled)
	_set_draw_rect_color(draw_rect_color)
	_set_draw_rect_width(draw_rect_width)
	_set_draw_label_enabled(draw_label_enabled)
	_set_draw_label_size(draw_label_size)
	_set_draw_label_color(draw_label_color)
	
	_update_enabled = true
	_draw_queue_enabled = true
	
	update()
	queue_redraw()
	
	polygon_changed.connect(update)
	color_changed.connect(update)


func _draw() -> void:
	if not _draw_queue_enabled or not draw_enabled or (not Engine.is_editor_hint() and draw_editor_only):
		return
	
	var rect: Rect2
	
	if draw_rect_enabled or draw_label_enabled:
		rect = PolyTools.get_rect(self)
		
		if rect.size == Vector2.ZERO:
			return
	
	if draw_rect_enabled:
		draw_rect(rect, draw_rect_color, false, draw_rect_width)
	
	if draw_label_enabled:
		var label_font: Font = ThemeDB.fallback_font
		var text: String = str(self)
		var text_string_size: Vector2 = label_font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, draw_label_size)
		var label_position_x: float = (rect.position.x + rect.size.x / 2.0) - text_string_size.x / 2.0
		var label_position_y: float = rect.position.y - (text_string_size.y + float(draw_rect_width)) / 2.0
		var label_position: Vector2 = Vector2(label_position_x, label_position_y)
		
		draw_string(label_font, label_position, text, HORIZONTAL_ALIGNMENT_CENTER, -1, draw_label_size, draw_label_color)
#endregion

#region Public Methods
func update() -> void:
	#region Border
	if border_enabled:
		if border_line == null:
			border_line = Line2D.new()
			border_line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
			add_child(border_line, false, Node.INTERNAL_MODE_BACK)
		
		border_line.points = get_border_polygon()
		border_line.default_color = get_border_color()
		border_line.width = border_width
		border_line.joint_mode = border_joint_mode
		border_line.antialiased = border_antialiased
		border_line.texture = border_texture
		border_line.show_behind_parent = border_texture_show_behind_parent
	
	else:
		if border_line != null:
			border_line.queue_free()
			border_line = null
	#endregion


func get_border_polygon() -> PackedVector2Array:
	if polygon.is_empty():
		return PackedVector2Array([])
	
	var result: PackedVector2Array = polygon.duplicate()
	var first_point: Vector2 = polygon[0]
	var middle_point: Vector2 = first_point + (polygon[1] - first_point) * 0.5

	result[0] = middle_point
	result.append(first_point)
	result.append(middle_point)
	
	return result


func get_border_color() -> Color:
	var result: Color
	
	match border_color_mode:
		BorderColorMode.SYNCED: result = color
		BorderColorMode.BLENDED: result = border_color_value.blend(color)
		_: result = border_color_value
	
	return result
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
# Border
func _set_border_enabled(arg: bool) -> void:
	border_enabled = arg
	update()


func _set_border_color_value(arg: Color) -> void:
	border_color_value = arg
	update()


func _set_border_joint_mode(arg: Line2D.LineJointMode) -> void:
	border_joint_mode = arg
	update()


func _set_border_antialiased(arg: bool) -> void:
	border_antialiased = arg
	update()

# Border Color
func _set_border_color_mode(arg: BorderColorMode) -> void:
	border_color_mode = arg
	update()


func _set_border_width(arg: int) -> void:
	border_width = maxi(0, arg)
	update()

# Border Texture
func _set_border_texture(arg: CompressedTexture2D) -> void:
	border_texture = arg
	update()


func _set_border_texture_show_behind_parent(arg: bool) -> void:
	border_texture_show_behind_parent = arg
	update()

# Draw
func _set_draw_enabled(arg: bool) -> void:
	draw_enabled = arg
	queue_redraw()

# Draw Rect
func _set_draw_rect_enabled(arg: bool) -> void:
	draw_rect_enabled = arg
	queue_redraw()


func _set_draw_rect_color(arg: Color) -> void:
	draw_rect_color = arg
	queue_redraw()


func _set_draw_rect_width(arg: int) -> void:
	draw_rect_width = arg
	queue_redraw()

# Draw Label
func _set_draw_label_enabled(arg: bool) -> void:
	draw_label_enabled = arg
	queue_redraw()


func _set_draw_label_size(arg: int) -> void:
	draw_label_size = arg
	queue_redraw()


func _set_draw_label_color(arg: Color) -> void:
	draw_label_color = arg
	queue_redraw()
#endregion

#region Getter Methods
#endregion
