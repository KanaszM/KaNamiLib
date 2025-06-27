@tool
class_name ExtendedLabel
extends Label

#region Signals
signal text_changed(new_text: String)
signal font_size_changed(font_size: int)
#endregion

#region Constants
const MIN_RECT_SIZE_ON_DYNAMIC_FONT_RESIZE: Vector2 = Vector2.ONE * 4.0
#endregion

#region Export Variables
@export var change_visibility_on_text_changed: bool: set = _set_change_visibility_on_text_changed

@export_group("Dynamic Font Size", "dynamic_font_size_")
@export var dynamic_font_size_enabled: bool: set = _set_dynamic_font_size_enabled
@export var dynamic_font_size_bounds: Vector2i = Vector2i(14, 56): set = _set_dynamic_font_size_bounds
@export var dynamic_font_size_sync: Array[Control]: set = _set_dynamic_font_size_sync
#endregion

#region Public Variables
var asynchronous: bool
#endregion

#region Private Variables
var _previous_visibility_state: bool = true
var _previous_font_size: int
var _previous_clip_text: bool

var _callbacks: Array[Callable]
var _signals: Array[Signal]
#endregion

#region Virtual Methods
func _set(property: StringName, value: Variant) -> bool:
	var is_changed: bool = true
	
	match property:
		&"text":
			var new_value := value as String
			
			if text != new_value:
				text = new_value
				text_changed.emit(new_value)
			
			if change_visibility_on_text_changed:
				visible = not text.is_empty()
		
		_:
			is_changed = false
	
	return is_changed


func _ready() -> void:
	_set_change_visibility_on_text_changed(change_visibility_on_text_changed)
	_set_dynamic_font_size_enabled(dynamic_font_size_enabled)
	_update_mouse_properties()
#endregion

#region Public Methods
func append_text(new_text: String, skip_if_empty: bool = false, new_lines_count: int = 1) -> void:
	if skip_if_empty and new_text.is_empty():
		return
	
	text += "%s%s" % ["\n".repeat(new_lines_count), new_text]


func append_text_array(text_array: Array[String], skip_if_empty: bool = false, new_lines_count: int = 1) -> void:
	for new_text: String in text_array:
		append_text(new_text, skip_if_empty, new_lines_count)


func is_empty() -> bool:
	return text.is_empty()


func clear() -> void:
	text = ""


func execute_everything() -> void:
	execute_callbacks()
	execute_signals()


func reeverything() -> void:
	reall_callbacks()
	reall_signals()
#endregion

#region Callback Methods
func callback_exists(callback: Callable) -> bool:
	return callback in _callbacks


func add_callback(callback: Callable, unique: bool = true) -> void:
	if unique and callback_exists(callback):
		return
	
	_callbacks.append(callback)
	_update_mouse_properties()


func readd_callback(callback: Callable, unique: bool = true) -> void:
	if callback_exists(callback):
		recallback(callback)
	
	add_callback(callback, unique)


func recallback(callback: Callable) -> void:
	if callback_exists(callback):
		Log.warning(recallback, "The callback: '%s' is not registered." % callback)
		return
	
	_callbacks.erase(callback)
	_update_mouse_properties()


func reall_callbacks() -> void:
	_callbacks.clear()
	_update_mouse_properties()


func execute_callbacks() -> void:
	for callback: Callable in _callbacks:
		if not callback.is_null():
			if asynchronous:
				await callback.call()
			
			else:
				callback.call()


func remove_callback(callback: Callable) -> void:
	if callback_exists(callback):
		_callbacks.erase(callback)
		_update_mouse_properties()
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
		Log.warning(resignal, "The signal: '%s' is not registered." % signal_param)
		return
	
	_signals.erase(signal_param)


func reall_signals() -> void:
	_signals.clear()


func execute_signals() -> void:
	for signal_param: Signal in _signals:
		signal_param.emit()
#endregion

#region Theme Methods
func set_font_size(value: int) -> void:
	add_theme_font_size_override(&"font_size", value)


func set_font_color(color: Color) -> void:
	add_theme_color_override(&"font_color", color)


func set_font_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_color", Shade.get_color(shade_type, shade_index, reversed))


func set_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"normal", style)


func get_font() -> Font:
	return get_theme_font(&"font")


func get_font_color() -> Color:
	return get_theme_color(&"font_color")


func get_font_size() -> int:
	return get_theme_font_size(&"font_size")


func get_font_text_size() -> Vector2:
	return get_font().get_string_size(text, horizontal_alignment, -1, get_font_size())
#endregion

#region Signal Callbacks
func _on_gui_input(event: InputEvent) -> void:
	UtilsInput.event_mouse_button_callback(event, MOUSE_BUTTON_LEFT, execute_everything)
#endregion

#region Private Methods
func _update_dynamic_font_size() -> void:
	if resized.is_connected(_update_dynamic_font_size):
		resized.disconnect(_update_dynamic_font_size)
	
	if size > MIN_RECT_SIZE_ON_DYNAMIC_FONT_RESIZE:
		var font: Font = get_font()
		var font_size: int = get_font_size()
		var text_line: TextLine = TextLine.new()
		
		text_line.direction = UtilsControl.convert_text_direction_flag(text_direction)
		text_line.flags = justification_flags
		text_line.alignment = horizontal_alignment
		
		for __: int in dynamic_font_size_bounds.y:
			text_line.clear()
			
			if text_line.add_string(text, font, font_size):
				if text_line.get_line_width() > floorf(size.x):
					font_size -= 1
				
				elif font_size < dynamic_font_size_bounds.y:
					font_size += 1
				
				else:
					break
			
			else:
				break
		
		var final_font_size: int = maxi(dynamic_font_size_bounds.x, font_size)
		
		set_font_size(final_font_size)
		
		font_size_changed.emit(final_font_size)
		
		for control: Control in dynamic_font_size_sync:
			if control != null:
				if control is RichTextLabel:
					for property: StringName in [
						&"bold_italics_font_size", &"italics_font_size", &"mono_font_size",
						&"normal_font_size", &"bold_font_size"
						] as Array[StringName]:
							control.add_theme_font_size_override(property, final_font_size)
				
				else:
					control.add_theme_font_size_override(&"font_size", final_font_size)
	
	if not resized.is_connected(_update_dynamic_font_size):
		resized.connect(_update_dynamic_font_size)


func _update_mouse_properties() -> void:
	var callbacks_available: bool = not _callbacks.is_empty()
	
	mouse_filter = Control.MOUSE_FILTER_PASS if callbacks_available else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if callbacks_available else Control.CURSOR_ARROW
	
	UtilsSignal.connect_safe_if(gui_input, _on_gui_input, callbacks_available)
#endregion

#region Setter Methods
func _set_change_visibility_on_text_changed(arg: bool) -> void:
	change_visibility_on_text_changed = arg
	
	if change_visibility_on_text_changed:
		_previous_visibility_state = visible
		visible = not text.is_empty()
	
	else:
		visible = _previous_visibility_state


func _set_dynamic_font_size_enabled(arg: bool) -> void:
	dynamic_font_size_enabled = arg
	
	if dynamic_font_size_enabled:
		_previous_font_size = get_font_size()
		_previous_clip_text = clip_text
		
		if is_node_ready():
			clip_text = true
			_update_dynamic_font_size()
	
	else:
		if resized.is_connected(_update_dynamic_font_size):
			resized.disconnect(_update_dynamic_font_size)
		
		clip_text = _previous_clip_text
		
		if _previous_font_size > 0:
			set_font_size(_previous_font_size)


func _set_dynamic_font_size_bounds(arg: Vector2i) -> void:
	dynamic_font_size_bounds = arg.max(Vector2i.ONE * 1)
	
	if dynamic_font_size_enabled:
		_update_dynamic_font_size()


func _set_dynamic_font_size_sync(arg: Array[Control]) -> void:
	dynamic_font_size_sync = arg
	
	if dynamic_font_size_enabled:
		_update_dynamic_font_size()
#endregion
