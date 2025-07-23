class_name ExternalTextEditor extends Object

#region Signals
signal finished(results: PackedStringArray, error_message: String)
#endregion

#region Private Variables
var _tree: SceneTree
var _processing_wait_time: float
var _active_instance_path: String
var _active_instance_pid: int
var _results: PackedStringArray
var _results_skip_empty_rows: bool
#endregion

#region Constructor
func _init(
	text_editor_path: String = r"C:\windows\system32\notepad.exe",
	processing_wait_time: float = 0.5,
	results_skip_empty_rows: bool = false,
	) -> void:
		text_editor_path = UtilsText.strip(text_editor_path)
		
		if not Path.new(text_editor_path).exists():
			_reset("The povided text editor at path: '%s', does not exist" % text_editor_path)
			return
		
		_tree = UtilsEngine.get_tree()
		
		if _tree == null:
			_reset("The SceneTree could not be detected")
			return
		
		var active_instance_file: FileAccess = FileAccess.create_temp(FileAccess.WRITE, "_", "txt")
		
		if active_instance_file == null:
			_reset("Could not create a temporary file")
			return
		
		_active_instance_path = active_instance_file.get_path()
		_active_instance_pid = OS.create_process(text_editor_path, [_active_instance_path])
		
		if _active_instance_pid <= 0:
			_reset("Could not create the text editor OS process")
			return
		
		_processing_wait_time = maxf(0.1, processing_wait_time)
		_results_skip_empty_rows = results_skip_empty_rows
		
		_tree.create_timer(_processing_wait_time).timeout.connect(_on_tree_timer_timeout)
#endregion

#region Private Methods
func _read() -> void:
	_results = Path.new(_active_instance_path).file_get_contents(_results_skip_empty_rows)
	_reset("")


func _reset(error_message: String) -> void:
	finished.emit(_results, error_message)
	
	await _tree.process_frame
	free.call_deferred()
#endregion

#region Signal Callbacks
func _on_tree_timer_timeout() -> void:
	if OS.is_process_running(_active_instance_pid):
		_tree.create_timer(_processing_wait_time).timeout.connect(_on_tree_timer_timeout)
	
	else:
		_read()
#endregion
