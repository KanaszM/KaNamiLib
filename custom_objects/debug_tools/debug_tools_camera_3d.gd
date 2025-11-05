class_name DebugToolsCamera3D extends Camera3D

#region Constants
const VELOCITY_LENGTH_LIMIT: float = 0.001
const PITCH_DEGREES_LIMIT: float = 89.0
#endregion

#region Exports
@export var remove_on_ready: bool

@export_group("Look", "look_")
@export_range(0.0, 2.0, 0.001, "or_greater") var look_sensitivity: float = 0.12
@export var look_capture_on_ready: bool = true

@export_group("Move", "move_")
@export_range(0.0, 10.0, 0.001, "or_greater") var move_speed: float = 8.0
@export_range(0.001, 10.0, 0.001, "or_greater") var move_speed_increase_multiplier: float = 3.0
@export_range(0.001, 10.0, 0.001, "or_greater") var move_speed_decrease_multiplier: float = 0.25
@export_range(0.1, 10.0, 0.001, "or_greater") var move_acceleration: float = 12.0
@export_range(0.0, 10.0, 0.001, "or_greater") var move_smoothing: float = 8.0

@export_group("Inputs", "input_")
@export var input_move_left: StringName = &"ffc_move_left"
@export var input_move_right: StringName = &"ffc_move_right"
@export var input_move_up: StringName = &"ffc_move_up"
@export var input_move_down: StringName = &"ffc_move_down"
@export var input_move_forward: StringName = &"ffc_move_forward"
@export var input_move_backward: StringName = &"ffc_move_backward"
@export var input_increase_speed: StringName = &"ffc_increase_speed"
@export var input_decrease_speed: StringName = &"ffc_decrease_speed"
@export var input_key_mouse_capture_on: Key = Key.KEY_M
@export var input_key_mouse_capture_off: Key = Key.KEY_ESCAPE
#endregion

#region Private Variables
var _velocity: Vector3
var _yaw_degrees: float
var _pitch_degrees: float
var _mouse_is_captured: bool
#endregion

#region Virtual Methods
func _ready() -> void:
	if not Engine.is_editor_hint() and remove_on_ready:
		queue_free()
		return
	
	UtilsNode.set_process(self, false)
	
	if not _check_inputs():
		return
	
	_yaw_degrees = rotation_degrees.y
	_pitch_degrees = rotation_degrees.x
	
	_set_mouse_capture(look_capture_on_ready)
	UtilsNode.set_process(self, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		
		if key_event.keycode == input_key_mouse_capture_on:
			_toggle_mouse_capture()
			return
		
		if key_event.keycode == input_key_mouse_capture_off:
			if _mouse_is_captured:
				_set_mouse_capture(false)
			
			return
	
	if event is InputEventMouseMotion and _mouse_is_captured:
		var mouse_motion_event := event as InputEventMouseMotion
		
		_yaw_degrees -= mouse_motion_event.relative.x * look_sensitivity
		_pitch_degrees -= mouse_motion_event.relative.y * look_sensitivity
		_pitch_degrees = clamp(_pitch_degrees, -PITCH_DEGREES_LIMIT, PITCH_DEGREES_LIMIT)
		rotation_degrees = Vector3(_pitch_degrees, _yaw_degrees, 0.0)


func _process(delta: float) -> void:
	#region Direction Processing
	var direction: Vector3
	
	if Input.is_action_pressed(input_move_forward):
		direction.z -= 1
	
	if Input.is_action_pressed(input_move_backward):
		direction.z += 1
	
	if Input.is_action_pressed(input_move_left):
		direction.x -= 1
	
	if Input.is_action_pressed(input_move_right):
		direction.x += 1
	
	if Input.is_action_pressed(input_move_up):
		direction.y -= 1
	
	if Input.is_action_pressed(input_move_down):
		direction.y += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	#endregion
	
	#region Speed Processing
	var current_speed: float = move_speed
	
	if Input.is_action_pressed(input_increase_speed):
		current_speed *= move_speed_increase_multiplier
	
	if Input.is_action_pressed(input_decrease_speed):
		current_speed *= move_speed_decrease_multiplier
	#endregion
	
	#region Velocity Processing
	var desired_velocity: Vector3 = direction * current_speed
	
	_velocity = _velocity.lerp(desired_velocity, clampf(move_acceleration * delta, 0.0, 1.0))
	
	if _velocity.length() > VELOCITY_LENGTH_LIMIT:
		translate_object_local(_velocity * delta)
	
	else:
		_velocity = _velocity.lerp(Vector3.ZERO, clampf(move_smoothing * delta, 0.0, 1.0))
	#endregion
#endregion

#region Private Methods
func _toggle_mouse_capture() -> void:
	_set_mouse_capture(not _mouse_is_captured)


func _set_mouse_capture(state: bool) -> void:
	_mouse_is_captured = state
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if state else Input.MOUSE_MODE_VISIBLE


func _check_inputs() -> bool:
	var input_action_types: Array[StringName] = [
		&"input_move_left", &"input_move_right", &"input_move_up", &"input_move_down", &"input_move_forward",
		&"input_move_backward", &"input_increase_speed", &"input_decrease_speed"
	]
	
	var is_valid: bool = true
	
	for input_action_type: StringName in input_action_types:
		var actual_input_action := get(input_action_type) as StringName
		
		if not InputMap.has_action(actual_input_action):
			Log.error("Action: '%s' does not exist!" % actual_input_action)
			is_valid = false
	
	return is_valid
#endregion
