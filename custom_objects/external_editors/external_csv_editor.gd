class_name ExternalCSVEditor extends Object

#region Signals
signal finished(results: Array[Dictionary], error_message: String)
#endregion

#region Private Variables
var _tree: SceneTree
var _processing_wait_time: float
var _active_instance_path: String
var _active_instance_pid: int
var _results: PackedStringArray
var _headers: PackedStringArray
var _headers_size: int
var _divider: String
#endregion

#region Constructor
func _init(
	headers: PackedStringArray,
	rows: Array[PackedStringArray] = [],
	text_editor_path: String = r"C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE",
	processing_wait_time: float = 0.5,
	divider: String = "\t",
	) -> void:
		text_editor_path = UtilsText.strip(text_editor_path)
		
		if not FileAccess.file_exists(text_editor_path):
			_reset("The povided text editor at path: '%s', does not exist" % text_editor_path)
			return
		
		if headers.is_empty():
			_reset("Headers are required!")
			return
		
		if divider.is_empty():
			_reset("A divider text is required!")
			return
		
		_tree = UtilsEngine.get_tree()
		
		if _tree == null:
			_reset("The SceneTree could not be detected")
			return
		
		var active_instance_file: FileAccess = FileAccess.create_temp(FileAccess.WRITE, "_", "tsv")
		
		if active_instance_file == null:
			_reset("Could not create a temporary file")
			return
		
		_divider = divider
		_headers = headers
		_headers_size = headers.size()
		
		active_instance_file.store_csv_line(_headers, divider)
		
		for row: PackedStringArray in rows:
			if row.size() == _headers_size:
				active_instance_file.store_csv_line(row, divider)
		
		active_instance_file.close()
		
		_active_instance_path = active_instance_file.get_path()
		_active_instance_pid = OS.create_process(text_editor_path, [_active_instance_path])
		
		if _active_instance_pid <= 0:
			_reset("Could not create the text editor OS process")
			return
		
		_processing_wait_time = maxf(0.1, processing_wait_time)
		
		_tree.create_timer(_processing_wait_time).timeout.connect(_on_tree_timer_timeout)
#endregion

#region Private Methods
func _read() -> void:
	var file: FileAccess = FileAccess.open(_active_instance_path, FileAccess.READ)
	
	if file == null:
		_reset("The output file at path: '%s', could not be read!" % _active_instance_path)
		return
	
	var results: Array[Dictionary]
	var line: PackedStringArray
	
	while not file.eof_reached():
		line = file.get_csv_line(_divider)
		
		if line == _headers or line.is_empty():
			continue
		
		var result: Dictionary[String, String]
		
		if line.size() == _headers_size:
			print(line)
			for idx: int in _headers_size:
				var entry_text: String = UtilsText.strip(line[idx])
				
				if not entry_text.is_empty():
					result[_headers[idx]] = entry_text
			
			if result.size() == _headers_size:
				results.append(result)
	
	_results = results
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
