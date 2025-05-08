@tool
class_name ExtendedButton
extends Button

#region Signals
signal disabled_set(mode: bool)
#endregion

#region Enums
#endregion

#region Constants
const DEFAULT_TOOLTIP: String = "N/A"
#endregion

#region Export Variables
@export var active_cursor_shape: Control.CursorShape = Control.CURSOR_POINTING_HAND
@export var disabled_cursor_shape: Control.CursorShape = Control.CURSOR_ARROW
@export var block_time: float: set = _set_block_time
@export var continuous: bool: set = _set_continuous
@export var continuous_delay: float = 0.1
#endregion

#region Public Variables
var is_blocked: bool
var asynchronous: bool
var rmb_menu_items: Array[ExtendedPopupMenu.Item]: set = _set_rmb_menu_items
#endregion

#region Private Variables
var _block_timer: Timer
var _block_time_was_set: bool

var _continuous_timer: Timer

var _previous_tooltip: String = DEFAULT_TOOLTIP

var _callbacks: Array[Callable]
var _signals: Array[Signal]
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"disabled":
			disabled = value as bool
			mouse_default_cursor_shape = disabled_cursor_shape if disabled else active_cursor_shape
			
			disabled_set.emit(disabled)
			return true
	
	return false


func _ready() -> void:
	_set_block_time(block_time)
	_set_continuous(continuous)
	
	focus_mode = Control.FOCUS_NONE
	
	set(&"disabled", disabled)
	
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if button_pressed:
		if _continuous_timer.is_stopped():
			execute_everything()
			
			if continuous_delay > 0.0:
				_continuous_timer.start(continuous_delay)
#endregion

#region Public Methods
func set_blocked(mode: bool) -> void:
	if block_time <= 0.0 or _block_timer == null:
		is_blocked = false
		
		if _block_time_was_set:
			set(&"disabled", false)
		
		_block_time_was_set = false
		
		return
	
	is_blocked = mode
	set(&"disabled", mode)
	
	if mode:
		if _previous_tooltip == DEFAULT_TOOLTIP:
			_previous_tooltip = tooltip_text
		
		tooltip_text = "\n".join(PackedStringArray([
			"The button activation remains disabled for %d seconds" % block_time,
			"after it's initially pressed, as a measure to deter spamming"
		]))
		
		_block_timer.start(block_time)
		
	else:
		if _previous_tooltip != DEFAULT_TOOLTIP:
			tooltip_text = _previous_tooltip


func execute_everything() -> void:
	execute_callbacks()
	execute_signals()


func reeverything() -> void:
	reall_callbacks()
	reall_signals()
#endregion

#region Theme Methods
func set_all_colors_icon(color: Color) -> void:
	for color_type: StringName in [
		&"icon_normal_color", &"icon_pressed_color", &"icon_hover_color", &"icon_hover_pressed_color",
		] as Array[StringName]:
			add_theme_color_override(color_type, color)


func set_all_colors_text(color: Color) -> void:
	for color_type: StringName in [
		&"font_color", &"font_pressed_color", &"font_hover_color", &"font_hover_pressed_color",
		] as Array[StringName]:
			add_theme_color_override(color_type, color)


func set_icon_separation(value: int) -> void:
	add_theme_constant_override(&"h_separation", value)


func set_font_size(value: int) -> void:
	add_theme_font_size_override(&"font_size", value)


func get_font_size() -> int:
	return get_theme_font_size(&"font_size")
#endregion

#region Callback Methods
func callback_exists(callback: Callable) -> bool:
	return callback in _callbacks


func add_callback(callback: Callable, unique: bool = true) -> void:
	if unique and callback_exists(callback):
		return
	
	if callback.is_valid():
		_callbacks.append(callback)


func readd_callback(callback: Callable, unique: bool = true) -> void:
	if callback_exists(callback):
		recallback(callback)
	
	add_callback(callback, unique)


func recallback(callback: Callable) -> void:
	if callback_exists(callback):
		Logger.warning(recallback, "The callback: '%s' is not registered." % callback)
		return
	
	_callbacks.erase(callback)


func reall_callbacks() -> void:
	_callbacks.clear()


func execute_callbacks() -> void:
	for callback: Callable in _callbacks:
		if not callback.is_null() and callback.is_valid():
			if asynchronous:
				await callback.call()
			
			else:
				callback.call()


func remove_callbacks() -> void:
	_callbacks.clear()
#endregion

#region Signals Methods
func signal_exists(signal_param: Signal) -> bool:
	return signal_param in _signals


func add_signal(signal_param: Signal, unique: bool = true) -> void:
	if unique and signal_exists(signal_param):
		return
	
	_signals.append(signal_param)


func readd_signal(signal_param: Signal) -> void:
	if signal_exists(signal_param):
		resignal(signal_param)
	
	_signals.append(signal_param)


func resignal(signal_param: Signal) -> void:
	if signal_exists(signal_param):
		Logger.warning(resignal, "The signal: '%s' is not registered." % signal_param)
		return
	
	_signals.erase(signal_param)


func reall_signals() -> void:
	_signals.clear()


func execute_signals() -> void:
	for signal_param: Signal in _signals:
		signal_param.emit()
#endregion

#region Private Methods
#endregion

#region Signal Callbacks
func _on_block_timer_timeout() -> void:
	set_blocked(false)


func _on_pressed() -> void:
	if not is_blocked and not continuous:
		execute_everything()
		set_blocked(true)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		
		if mouse_button_event.is_pressed():
			match mouse_button_event.button_index:
				MOUSE_BUTTON_RIGHT: ExtendedPopupMenu.static_context_menu_from_object(self, rmb_menu_items)
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_block_time(arg: float) -> void:
	block_time = arg
	
	if block_time > 0.0:
		if _block_timer == null:
			_block_timer = Timer.new()
			_block_timer.one_shot = true
			_block_timer.timeout.connect(_on_block_timer_timeout)
			add_child(_block_timer, false, Node.INTERNAL_MODE_BACK)
		
		_block_time_was_set = true
	
	elif block_time <= 0.0:
		if _block_timer != null:
			_block_timer.stop()
			_block_timer.queue_free()
		
		set_blocked(false)


func _set_continuous(arg: bool) -> void:
	continuous = arg
	
	set_process(continuous)
	
	if continuous:
		if _continuous_timer == null:
			_continuous_timer = Timer.new()
			_continuous_timer.one_shot = true
			add_child(_continuous_timer, false, Node.INTERNAL_MODE_BACK)
	
	else:
		if _continuous_timer != null:
			_continuous_timer.stop()
			_continuous_timer.queue_free()


func _set_rmb_menu_items(arg: Array[ExtendedPopupMenu.Item]) -> void:
	rmb_menu_items = arg
	
	if rmb_menu_items.is_empty():
		UtilsSignal.disconnect_safe(gui_input, _on_gui_input)
	
	else:
		UtilsSignal.connect_safe(gui_input, _on_gui_input)
#endregion

#region Getter Methods
#endregion
