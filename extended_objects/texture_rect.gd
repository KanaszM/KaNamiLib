@tool
class_name ExtendedTextureRect extends TextureRect

#region Public Variables
var asynchronous: bool
#endregion

#region Private Variables
var _callbacks: Array[Callable]
#endregion

#region Public Methods
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

#region Private Methods
func _update_mouse_properties() -> void:
	var callbacks_available: bool = not _callbacks.is_empty()
	
	mouse_filter = Control.MOUSE_FILTER_PASS if callbacks_available else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if callbacks_available else Control.CURSOR_ARROW
	
	UtilsSignal.connect_safe_if(gui_input, _on_gui_input, callbacks_available)
#endregion

#region Signal Callbacks
func _on_gui_input(event: InputEvent) -> void:
	UtilsInput.event_mouse_button_callback(event, MOUSE_BUTTON_LEFT, execute_callbacks)
#endregion
