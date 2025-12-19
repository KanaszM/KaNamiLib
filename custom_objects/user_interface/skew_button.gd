@tool
class_name SkewButton extends Control

#region Enums
enum SkewPosition {NONE, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}
enum LabelPosition {LEFT, RIGHT, TOP, BOTTOM}
#endregion

#region Signals
signal pressed
signal pressed_up
signal pressed_down
#endregion

#region Exports
@export_group("Background", "background_")
@export var background_color: Color = Color.DARK_GRAY: set = _set_background_color
@export var background_texture: CompressedTexture2D: set = _set_background_texture
@export var background_texture_flip_h: bool: set = _set_background_texture_flip_h
@export var background_texture_flip_v: bool: set = _set_background_texture_flip_v
@export var background_texture_filtering: bool: set = _set_background_texture_filtering
@export_range(0.0, 50.0, 0.01, "suffix:%") var background_texture_margin: float: set = _set_background_texture_margin
@export_range(0, 100, 1) var background_separation: int: set = _set_background_separation

@export_group("Border", "border_")
@export var border_blend: bool = true: set = _set_border_blend
@export var border_color: Color = Color.BLACK: set = _set_border_color
@export_range(0, 100, 1, "or_greater") var border_width: int = 4: set = _set_border_width

@export_group("Label", "label_")
@export var label_text: String: set = _set_label_text
@export_range(0.0, 10.0, 0.001, "or_greater") var label_stretch_ratio: float = 1.0: set = _set_label_stretch_ratio
@export var label_position: LabelPosition = LabelPosition.RIGHT: set = _set_label_position

@export_group("Timers", "timer_")
@export_range(0.01, 10.0, 0.001, "or_greater") var timer_hold_interval: float = 0.1
@export_range(0.01, 10.0, 0.001, "or_greater") var timer_presses_interval: float = 0.175

@export_group("Press Skew", "skew_")
@export var skew_enabled: bool = true
@export_range(0.0, 1.0, 0.001) var skew_weight: float = 0.25
@export_range(0.0, 1.0, 0.001, "or_greater") var skew_limit: float = 0.15
@export_range(0.0, 1.0, 0.001, "or_greater") var skew_threshold: float = 0.5
@export_range(0.0, 2.0, 0.001, "or_greater") var skew_border_tween_duration: float = 0.075
@export_range(1, 100, 1) var skew_border_width_modifier: int = 16

@export_group("Press Scale", "scale_")
@export var scale_enabled: bool = true
@export_range(0.1, 1.0, 0.001, "or_greater") var scale_ratio: float = 0.85
@export_range(0.0, 10.0, 0.001, "or_greater") var scale_weight: float = 0.15
#endregion

#region Private Variables
var _lmb_is_pressed: bool

var _box: ExtendedBoxContainer
var _panel: ExtendedPanelContainer
var _style: StyleBoxFlat
var _label: ExtendedLabel
var _texture: TextureRect
var _texture_margin: ExtendedMarginContainer
var _tween_scale: Tween
var _timer_hold: Timer
var _timer_presses: Timer

var _current_skew: Vector2
var _current_skew_position: SkewPosition

var _timer_hold_count_current: int = 0
var _timer_presses_count_current: int = 0

var _callbacks_regular: Dictionary[int, CallbackArray]
var _callbacks_hold: Dictionary[float, CallbackArray]
#endregion

#region Virtual Methods
func _ready() -> void:
	set_process(false)
	update()


func _input(event: InputEvent) -> void:
	_input_handler_base(event)


func _process(_delta: float) -> void:
	_style.skew = _style.skew.lerp(_current_skew, skew_weight)
#endregion

#region Public Methods
func update() -> void:
	#region Panel
	if _panel == null:
		_panel = ExtendedPanelContainer.new()
		_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_panel.gui_input.connect(_input_handler_background)
		add_child(_panel, false, Node.INTERNAL_MODE_BACK)
	#endregion
	
	#region Box
	if _box == null:
		_box = ExtendedBoxContainer.new()
		_panel.add_child(_box, false, Node.INTERNAL_MODE_BACK)
	
	_box.set_separation(background_separation)
	#endregion
	
	#region Timers
	if _timer_hold == null:
		_timer_hold = Timer.new()
		_timer_hold.timeout.connect(_on_timer_hold_timeout)
		add_child(_timer_hold, false, Node.INTERNAL_MODE_BACK)
	
	if _timer_presses == null:
		_timer_presses = Timer.new()
		_timer_presses.one_shot = true
		_timer_presses.timeout.connect(_on_timer_presses_timeout)
		add_child(_timer_presses, false, Node.INTERNAL_MODE_BACK)
	#endregion
	
	#region Stylebox
	if _style == null:
		_style = StyleBoxFlat.new()
		_panel.set_style(_style)
	
	_style.bg_color = background_color
	_style.border_blend = border_blend
	_style.border_color = border_color
	_style.set_border_width_all(border_width)
	#endregion
	
	#region Texture
	if background_texture != null:
		if _texture_margin == null:
			_texture_margin = ExtendedMarginContainer.new()
			_texture_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_texture_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_texture_margin.mode = ExtendedMarginContainer.Mode.PERCENTAGE
			_box.add_child(_texture_margin, false, Node.INTERNAL_MODE_BACK)
			
			_texture = TextureRect.new()
			_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_texture_margin.add_child(_texture, false, Node.INTERNAL_MODE_BACK)
		
		_texture_margin.percent_margin_all = background_texture_margin
		_texture_margin.texture_filter = (
			TEXTURE_FILTER_LINEAR if background_texture_filtering else TEXTURE_FILTER_NEAREST
			)
		
		_texture.texture = background_texture
		_texture.flip_h = background_texture_flip_h
		_texture.flip_v = background_texture_flip_v
	
	else:
		if _texture_margin != null:
			_texture_margin.queue_free()
			_texture = null
			_texture_margin = null
	#endregion
	
	#region Label
	var label_text_sanitized: String = label_text.strip_edges()
	
	if not label_text_sanitized.is_empty():
		if _label == null:
			_label = ExtendedLabel.new()
			_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
			_label.clip_text = true
			_box.add_child(_label, false, Node.INTERNAL_MODE_BACK)
			
		_label.text = label_text_sanitized
		_label.size_flags_stretch_ratio = label_stretch_ratio
		
		if background_texture != null:
			_box.vertical = label_position in [LabelPosition.TOP, LabelPosition.BOTTOM]
			_box.move_child(_label, int(label_position in [LabelPosition.BOTTOM, LabelPosition.RIGHT]))
	
	else:
		if _label != null:
			_label.queue_free()
			_label = null
	#endregion
	
	#region Self
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(skew_enabled)
	#endregion


func add_regular_callback(callback: Callable, count: int = 1) -> SkewButton:
	if not count in _callbacks_regular:
		_callbacks_regular[count] = CallbackArray.new()
	
	_callbacks_regular[count].append(Callback.new(callback))
	return self


func add_hold_callback(callback: Callable, interval: float = 0.01) -> SkewButton:
	if not interval in _callbacks_hold:
		_callbacks_hold[interval] = CallbackArray.new()
	
	_callbacks_hold[interval].append(Callback.new(callback))
	return self
#endregion

#region Private Methods
func _input_handler_base(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		
		match mouse_button_event.button_index:
			MOUSE_BUTTON_LEFT:
				if not mouse_button_event.pressed:
					if _lmb_is_pressed:
						pressed_up.emit()
						_timer_hold.stop()
						_set_scale(false)
					
					_timer_hold_count_current = 0
					_lmb_is_pressed = false
					_process_mouse_motion(Vector2.ZERO)


func _input_handler_background(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		
		match mouse_button_event.button_index:
			MOUSE_BUTTON_LEFT:
				if mouse_button_event.pressed:
					_lmb_is_pressed = true
					_timer_presses_count_current += 1
					_timer_hold.start(timer_hold_interval)
					_timer_presses.start(timer_presses_interval)
					
					pressed_down.emit()
					_set_scale(true)
					
					if _has_cursor_point():
						_process_mouse_motion(get_local_mouse_position())
	
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		
		if _lmb_is_pressed:
			_process_mouse_motion(mouse_motion_event.position)


func _process_mouse_motion(mouse_position: Vector2) -> void:
	if not skew_enabled:
		return
	
	var local_skew_position: SkewPosition
	
	var border_width_left: int = border_width
	var border_width_right: int = border_width
	var border_width_top: int = border_width
	var border_width_bottom: int = border_width
	
	if mouse_position == Vector2.ZERO:
		_current_skew = Vector2.ZERO
		local_skew_position = SkewPosition.NONE
	
	else:
		var normalized: Vector2 = mouse_position / size
		var clamped: Vector2 = normalized.clamp(Vector2.ZERO, Vector2.ONE * skew_limit)
		
		var half_x: bool = normalized.x >= skew_threshold
		var half_y: bool = normalized.y >= skew_threshold
		var top_left: bool = not half_x and not half_y
		var top_right: bool = half_x and not half_y
		var bottom_left: bool = not half_x and half_y
		var bottom_right: bool = half_x and half_y
		
		if top_left:
			_current_skew.x = clamped.x
			_current_skew.y = clamped.y
			local_skew_position = SkewPosition.TOP_LEFT
			border_width_right += skew_border_width_modifier
			border_width_bottom += skew_border_width_modifier
		
		elif top_right:
			_current_skew.x = -clamped.x
			_current_skew.y = -clamped.y
			local_skew_position = SkewPosition.TOP_RIGHT
			border_width_left += skew_border_width_modifier
			border_width_bottom += skew_border_width_modifier
		
		elif bottom_left:
			_current_skew.x = -clamped.x
			_current_skew.y = -clamped.y
			local_skew_position = SkewPosition.BOTTOM_LEFT
			border_width_right += skew_border_width_modifier
			border_width_top += skew_border_width_modifier
		
		elif bottom_right:
			_current_skew.x = clamped.x
			_current_skew.y = clamped.y
			local_skew_position = SkewPosition.BOTTOM_RIGHT
			border_width_left += skew_border_width_modifier
			border_width_top += skew_border_width_modifier
	
	if local_skew_position != _current_skew_position:
		_current_skew_position = local_skew_position
		
		var tween: Tween = create_tween().set_parallel()
		
		tween.tween_property(_style, ^"border_width_left", border_width_left, skew_border_tween_duration)
		tween.tween_property(_style, ^"border_width_right", border_width_right, skew_border_tween_duration)
		tween.tween_property(_style, ^"border_width_top", border_width_top, skew_border_tween_duration)
		tween.tween_property(_style, ^"border_width_bottom", border_width_bottom, skew_border_tween_duration)


func _set_scale(state: bool) -> void:
	if not scale_enabled:
		return
	
	if _tween_scale != null:
		_tween_scale.kill()
	
	var func_on_tween_finished: Callable = func() -> void:
		_tween_scale = null
	
	var target: Vector2 = (Vector2.ONE * scale_ratio) if state else Vector2.ONE
	
	_panel.pivot_offset = size / 2.0
	
	_tween_scale = create_tween()
	_tween_scale.finished.connect(func_on_tween_finished)
	_tween_scale.tween_property(_panel, ^"scale", target, scale_weight)


func _has_cursor_point() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())
#endregion

#region Signal Callbacks
func _on_timer_hold_timeout() -> void:
	_timer_hold_count_current += 1


func _on_timer_presses_timeout() -> void:
	if _has_cursor_point():
		for interval: float in _callbacks_hold:
			var executed: bool
			
			if _timer_hold_count_current >= interval:
				for callback: Callback in _callbacks_hold[interval].get_callbacks():
					callback.execute()
					executed = true
				
				if executed:
					pressed.emit()
					_timer_presses_count_current = 0
					return
		
		for count: int in _callbacks_regular:
			if _timer_presses_count_current == count:
				for callback: Callback in _callbacks_regular[count].get_callbacks():
					callback.execute()
				
				pressed.emit()
				_timer_presses_count_current = 0
#endregion

#region Setter Methods
# Background:
func _set_background_color(arg: Color) -> void:
	background_color = arg
	update()


func _set_background_texture(arg: CompressedTexture2D) -> void:
	background_texture = arg
	update()


func _set_background_texture_flip_h(arg: bool) -> void:
	background_texture_flip_h = arg
	update()


func _set_background_texture_flip_v(arg: bool) -> void:
	background_texture_flip_v = arg
	update()


func _set_background_texture_filtering(arg: bool) -> void:
	background_texture_filtering = arg
	update()


func _set_background_texture_margin(arg: float) -> void:
	background_texture_margin = clampf(arg, 0.0, 50.0)
	update()


func _set_background_separation(arg: int) -> void:
	background_separation = maxi(0, arg)
	update()

# Border:
func _set_border_blend(arg: bool) -> void:
	border_blend = arg
	update()


func _set_border_color(arg: Color) -> void:
	border_color = arg
	update()


func _set_border_width(arg: int) -> void:
	border_width = maxi(0, arg)
	update()

# Label:
func _set_label_text(arg: String) -> void:
	label_text = arg
	update()


func _set_label_stretch_ratio(arg: float) -> void:
	label_stretch_ratio = maxf(0.0, arg)
	update()


func _set_label_position(arg: LabelPosition) -> void:
	label_position = arg
	update()
#endregion

#region SubClasses
class Callback:
	#region Private Variables
	var _callback: Callable
	#endregion
	
	#region Virtual Methods
	func _init(callback: Callable) -> void:
		_callback = callback
	#endregion
	
	#region Public Methods
	func get_callback() -> Callable:
		return _callback
	
	
	func is_valid() -> bool:
		return not _callback.is_null() and _callback.is_valid()
	
	
	func execute() -> void:
		if is_valid():
			_callback.call()
	
	
	func execute_deferred() -> void:
		if is_valid():
			_callback.call_deferred()
	#endregion


class CallbackArray:
	#region Private Variables
	var _callbacks: Array[Callback]
	#endregion
	
	#region Public Methods
	func get_callbacks() -> Array[Callback]:
		return _callbacks
	
	
	func append(callback: Callback) -> CallbackArray:
		_callbacks.append(callback)
		return self
	#endregion
#endregion
