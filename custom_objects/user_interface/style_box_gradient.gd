@tool
class_name StyleBoxGradient
extends StyleBoxTexture

#region Enums
enum Direction {
	LEFT_TO_RIGHT, RIGHT_TO_LEFT, TOP_TO_BOTTOM, BOTTOM_TO_TOP,
	TOP_LEFT_TO_BOTTOM_RIGHT, TOP_RIGHT_TO_LEFT_BOTTOM,
	BOTTOM_LEFT_TO_TOP_RIGHT, BOTTOM_RIGHT_TO_TOP_LEFT,
	CENTERED
	}
#endregion

#region Constants
var DIRECTIONS_MAP: Dictionary[Direction, PackedVector2Array] = {
	Direction.LEFT_TO_RIGHT: PackedVector2Array([Vector2(0.0, 0.0), Vector2(1.0, 0.0)]),
	Direction.RIGHT_TO_LEFT: PackedVector2Array([Vector2(1.0, 0.0), Vector2(0.0, 0.0)]),
	Direction.TOP_TO_BOTTOM: PackedVector2Array([Vector2(0.5, 0.0), Vector2(0.5, 1.0)]),
	Direction.BOTTOM_TO_TOP: PackedVector2Array([Vector2(0.5, 1.0), Vector2(0.5, 0.0)]),
	Direction.TOP_LEFT_TO_BOTTOM_RIGHT: PackedVector2Array([Vector2(0.0, 0.0), Vector2(1.0, 1.0)]),
	Direction.TOP_RIGHT_TO_LEFT_BOTTOM: PackedVector2Array([Vector2(1.0, 0.0), Vector2(0.0, 1.0)]),
	Direction.BOTTOM_LEFT_TO_TOP_RIGHT: PackedVector2Array([Vector2(0.0, 1.0), Vector2(1.0, 0.0)]),
	Direction.BOTTOM_RIGHT_TO_TOP_LEFT: PackedVector2Array([Vector2(1.0, 1.0), Vector2(0.0, 0.0)]),
	Direction.CENTERED: PackedVector2Array([Vector2(0.5, 0.5), Vector2(0.0, 0.0)]),
}
#endregion

#region Export Variables
@export var fill: GradientTexture2D.Fill = GradientTexture2D.Fill.FILL_LINEAR: set = _set_fill
@export var direction: Direction = Direction.LEFT_TO_RIGHT: set = _set_direction
@export var invert_colors: bool: set = _set_invert_colors

@export var bg_color_1: Shade.Type = Shade.Type.GRAY: set = _set_bg_color_1
@export_range(0, 9, 1) var bg_color_1_idx: int: set = _set_bg_color_1_idx
@export_range(0.0, 1.0, 0.001) var bg_color_1_alpha: float = 1.0: set = _set_bg_color_1_alpha
@export_range(0.0, 1.0, 0.001) var bg_color_1_offset: float = 0.0: set = _set_bg_color_1_offset

@export var bg_color_2: Shade.Type = Shade.Type.GRAY: set = _set_bg_color_2
@export_range(0, 9, 1) var bg_color_2_idx: int: set = _set_bg_color_2_idx
@export_range(0.0, 1.0, 0.001) var bg_color_2_alpha: float = 1.0: set = _set_bg_color_2_alpha
@export_range(0.0, 1.0, 0.001) var bg_color_2_offset: float = 1.0: set = _set_bg_color_2_offset
#endregion

#region Public Variables
var update_enabled: bool = false

var gradient: Gradient
var gradient_texture: GradientTexture2D
#endregion

#region Private Variables
var _custom_color_bg_1: Color = Color.TRANSPARENT
var _custom_color_bg_2: Color = Color.TRANSPARENT
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init() -> void:
	gradient = Gradient.new()
	gradient_texture = GradientTexture2D.new()
	
	gradient_texture.gradient = gradient
	texture = gradient_texture
	
	update_enabled = true
	update()
#endregion

#region Public Methods
func update() -> void:
	if not update_enabled:
		return
	
	gradient_texture.fill = fill
	gradient_texture.fill_from = DIRECTIONS_MAP[direction][0]
	gradient_texture.fill_to = DIRECTIONS_MAP[direction][1]
	
	if invert_colors:
		gradient.colors[0] = (
			Shade.get_opposite_color(bg_color_1, bg_color_1_idx) if _custom_color_bg_1 == Color.TRANSPARENT
			else _custom_color_bg_1
		)
		gradient.colors[1] = (
			Shade.get_opposite_color(bg_color_2, bg_color_2_idx) if _custom_color_bg_2 == Color.TRANSPARENT
			else _custom_color_bg_2
		)
	
	else:
		gradient.colors[0] = (
			Shade.get_color(bg_color_1, bg_color_1_idx) if _custom_color_bg_1 == Color.TRANSPARENT
			else _custom_color_bg_1
		)
		gradient.colors[1] = (
			Shade.get_color(bg_color_2, bg_color_2_idx) if _custom_color_bg_2 == Color.TRANSPARENT
			else _custom_color_bg_2
		)
	
	gradient.colors[0].a = bg_color_1_alpha
	gradient.colors[1].a = bg_color_2_alpha
	
	gradient.offsets[0] = bg_color_1_offset
	gradient.offsets[1] = bg_color_2_offset


func set_custom_bg_color_1(color: Color) -> void:
	_custom_color_bg_1 = color
	
	changed.emit()
	update()


func set_custom_bg_color_2(color: Color) -> void:
	_custom_color_bg_2 = color
	
	changed.emit()
	update()
#endregion

#region Setter Methods
func _set_fill(arg: GradientTexture2D.Fill) -> void:
	fill = arg
	
	changed.emit()
	update()


func _set_direction(arg: Direction) -> void:
	direction = arg
	
	changed.emit()
	update()


func _set_invert_colors(arg: bool) -> void:
	invert_colors = arg
	
	changed.emit()
	update()


func _set_bg_color_1(arg: Shade.Type) -> void:
	bg_color_1 = arg
	
	changed.emit()
	update()


func _set_bg_color_1_idx(arg: int) -> void:
	bg_color_1_idx = arg
	
	changed.emit()
	update()


func _set_bg_color_1_alpha(arg: float) -> void:
	bg_color_1_alpha = arg
	
	changed.emit()
	update()


func _set_bg_color_1_offset(arg: float) -> void:
	bg_color_1_offset = arg
	
	changed.emit()
	update()


func _set_bg_color_2(arg: Shade.Type) -> void:
	bg_color_2 = arg
	
	changed.emit()
	update()


func _set_bg_color_2_idx(arg: int) -> void:
	bg_color_2_idx = arg
	
	changed.emit()
	update()


func _set_bg_color_2_alpha(arg: float) -> void:
	bg_color_2_alpha = arg
	
	changed.emit()
	update()


func _set_bg_color_2_offset(arg: float) -> void:
	bg_color_2_offset = arg
	
	changed.emit()
	update()
#endregion
