@tool
class_name ExtendedCamera2D extends Camera2D

#region Signals
signal target_reached
#endregion

#region Enums
enum TargetType {NONE, POINT, NODE, INPUT}
#endregion

#region Constants
const DEFAULT_LIMIT: int = 10000000
#endregion

#region Export Variables
@export_group("Move", "move_")
@export var move_enabled: bool = true
@export var move_speed: float = 1000.0: set = _set_move_speed

@export_group("Zoom", "zoom_")
@export var zoom_enabled: bool = true
@export var zoom_increment: float = 0.1: set = _set_zoom_increment
@export var zoom_min: float = 0.5: set = _set_zoom_min
@export var zoom_max: float = 2.0: set = _set_zoom_max

@export_group("Limits", "limits_")
@export var limits_offset_horizontal: Vector2i
@export var limits_offset_vertical: Vector2i

@export_group("Target", "target_")
@export var target_type: TargetType
@export var target_threshold: float = 32.0: set = _set_target_threshold
@export_subgroup("Point", "target_point_")
@export var target_point_position: Vector2
@export var target_point_instant: bool
@export_subgroup("Follow", "target_follow_")
@export var target_follow_node: Node2D

@export_group("Input", "input_")
@export_subgroup("Mouse", "input_mouse_")
@export var input_mouse_zoom_enabled: bool = false
@export var input_mouse_zoom_reversed: bool = false
@export_subgroup("Keyboard", "input_keyboard_")
@export var input_keyboard_move_action_left: StringName = &"ui_left"
@export var input_keyboard_move_action_right: StringName = &"ui_right"
@export var input_keyboard_move_action_up: StringName = &"ui_up"
@export var input_keyboard_move_action_down: StringName = &"ui_down"
@export_subgroup("Accelerate", "input_accelerate_")
@export var input_accelerate_enabled: bool = true
@export var input_accelerate_ratio: float = 2.0: set = _set_input_accelerate_ratio
@export var input_accelerate_action: StringName = &"ui_select"
#endregion

#region Private Variables
var _input_acceleration: float: get = _get_input_acceleration
var _cached_limit_bounds: Vector2
var _can_move_horizontally: bool = true
var _can_move_vertically: bool = true
#endregion

#region Virtual Methods
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and input_mouse_zoom_enabled:
		var mouse_button_event := event as InputEventMouseButton
		
		if mouse_button_event.pressed:
			match mouse_button_event.button_index:
				MOUSE_BUTTON_WHEEL_UP: apply_incremented_zoom(not input_mouse_zoom_reversed)
				MOUSE_BUTTON_WHEEL_DOWN: apply_incremented_zoom(input_mouse_zoom_reversed)


func _physics_process(delta: float) -> void:
	if not move_enabled:
		return
	
	var move_direction: Vector2
	
	match target_type:
		TargetType.POINT:
			var func_set_reached: Callable = func() -> void:
				target_point_position = Vector2.ZERO
				target_reached.emit()
			
			if target_point_instant:
				position = target_point_position
				func_set_reached.call()
				reset_smoothing()
				return
			
			var difference: Vector2 = target_point_position - global_position
			var destination_reached: bool = difference.length() <= target_threshold
			
			move_direction = Vector2.ZERO if destination_reached else difference
			
			if destination_reached:
				func_set_reached.call()
		
		TargetType.NODE:
			if target_follow_node == null:
				return
			
			var difference: Vector2 = target_follow_node.global_position - global_position
			
			move_direction = difference if difference.length() > target_threshold else Vector2.ZERO
		
		TargetType.INPUT:
			move_direction = Input.get_vector(
				input_keyboard_move_action_left, input_keyboard_move_action_right,
				input_keyboard_move_action_up, input_keyboard_move_action_down
				)
	
	if move_direction != Vector2.ZERO:
		var speed: float = move_speed * _input_acceleration
		var direction: Vector2 = move_direction.normalized() * speed * delta
		var new_position: Vector2 = position + direction
		
		_apply_clamped_position(new_position)
#endregion

#region Public Methods
func get_rect() -> Rect2:
	var viewport: Viewport = get_viewport()
	
	return (viewport.global_canvas_transform * get_canvas_transform()).affine_inverse() * viewport.get_visible_rect()


func apply_incremented_zoom(mode: bool) -> void:
	var increment: Vector2 = Vector2.ONE * (zoom_increment * _input_acceleration)
	var new_zoom: Vector2 = (zoom + increment) if mode else (zoom - increment)
	
	_apply_clamped_zoom(new_zoom)
	_apply_limit_bounds(_cached_limit_bounds)
#endregion

#region Private Methods
func _apply_limit_bounds(new_bounds: Vector2) -> void:
	if new_bounds == Vector2.ZERO:
		return
	
	if _cached_limit_bounds != new_bounds:
		_cached_limit_bounds = new_bounds
	
	var viewport_size: Vector2 = get_viewport_rect().size
	
	_can_move_horizontally = new_bounds.x * zoom.x > viewport_size.x
	_can_move_vertically = new_bounds.y * zoom.y > viewport_size.y
	
	limit_left = (0 if _can_move_horizontally else -DEFAULT_LIMIT) - limits_offset_horizontal.x
	limit_right = (int(new_bounds.x) if _can_move_horizontally else DEFAULT_LIMIT) + limits_offset_horizontal.y
	limit_top = (0 if _can_move_vertically else -DEFAULT_LIMIT) - limits_offset_vertical.x
	limit_bottom = (int(new_bounds.y) if _can_move_vertically else DEFAULT_LIMIT) + limits_offset_vertical.y
	
	if not _can_move_horizontally:
		position.x = new_bounds.x / 2.0
		reset_smoothing()
	
	if not _can_move_vertically:
		position.y = (new_bounds.y / 2.0) + (limits_offset_vertical.y - limits_offset_vertical.x) / 2.0
		reset_smoothing()
	
	_apply_clamped_position(position)


func _apply_clamped_zoom(new_zoom: Vector2) -> void:
	zoom.x = clampf(new_zoom.x, zoom_min, zoom_max)
	zoom.y = clampf(new_zoom.y, zoom_min, zoom_max)


func _apply_clamped_position(new_position: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size / (zoom * 2.0)
	
	if _can_move_horizontally:
		position.x = clampf(new_position.x, (float(limit_left) + viewport_size.x) , float(limit_right) - viewport_size.x)
	
	if _can_move_vertically:
		position.y = clampf(new_position.y, (float(limit_top) + viewport_size.y), float(limit_bottom) - viewport_size.y)
#endregion

#region Setter Methods
# Move
func _set_move_speed(arg: float) -> void:
	move_speed = maxf(0.0, arg)

# Zoom
func _set_zoom_increment(arg: float) -> void:
	zoom_increment = clampf(arg, 0.0, 1.0)


func _set_zoom_min(arg: float) -> void:
	zoom_min = clampf(arg, 0.0, 1.0)


func _set_zoom_max(arg: float) -> void:
	zoom_max = clampf(arg, 1.0, 5.0)

# Target
func _set_target_threshold(arg: float) -> void:
	target_threshold = maxf(1.0, arg)

# Input
func _set_input_accelerate_ratio(arg: float) -> void:
	input_accelerate_ratio = maxf(1.0, arg)
#endregion

#region Getter Methods
func _get_input_acceleration() -> float:
	return input_accelerate_ratio if Input.is_action_pressed(input_accelerate_action) else 1.0
#endregion
