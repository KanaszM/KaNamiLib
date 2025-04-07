"""
# Version 1.0.0 (02-Apr-2025):
	- Initial release;
"""

@tool
extends EditorScript

#region Enums
enum ResultType {NONE, DECLARED_VARIABLE, UNDECLARED_VARIABLE}
#endregion

#region Constants
const RESULT_TYPE: ResultType = ResultType.UNDECLARED_VARIABLE
const FILE_PATH: String = "res://common/editor_scripts/script_to_string_converter.gd"
const REGION_NAME: String = "Script"
const ALLOW_EMPTY_LINES: bool = false
const INDENT_ENTRIES: bool = false
const COPY_TO_CLIPBOARD: bool = true
const PRINT_RESULT: bool = false
const END_BLANK_LINES_COUNT: int = 2
#endregion

#region Virtual Methods
func _run() -> void:
	_convert_region()
#endregion

#region Script
#endregion

#region Private Methods
func _convert_region() -> String:
	if FILE_PATH.is_empty():
		printerr("No file path was provided!")
		return ""
	
	if REGION_NAME.is_empty():
		printerr("No region name was provided!")
		return ""
	
	if not FileAccess.file_exists(FILE_PATH):
		printerr("File does not exist at path: '%s'!" % FILE_PATH)
		return ""
	
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
	
	if file == null:
		printerr(
			"File at path: '%s', Could not be opened! Error: %s"
			% error_string(FileAccess.get_open_error())
			)
		return ""
	
	var file_contents: PackedStringArray = file.get_as_text().split("\n")
	
	file.close()
	
	var result_parts: PackedStringArray
	var region_begin_found: bool
	var region_end_found: bool
	
	for entry: String in file_contents:
		if region_begin_found:
			if entry.begins_with("#endregion"):
				region_end_found = true
				break
			
			var result_entry: String = entry.strip_edges(false, true)
			
			if result_entry.is_empty() and not ALLOW_EMPTY_LINES:
				continue
			
			result_entry = result_entry.replace("\t", "\\t")
			result_entry = result_entry.replace("\"", "'")
			
			result_parts.append("%s\t\"%s\"," % [
				"\t".repeat(result_entry.count("\\t")) if INDENT_ENTRIES else "",
				result_entry
				])
		
		else:
			if entry.begins_with("#region"):
				var entry_region_parts: PackedStringArray = entry.split(" ", false)
				var entry_region_parts_size: int = entry_region_parts.size()
				
				if entry_region_parts_size >= 2:
					entry_region_parts.remove_at(0)
					
					var entry_region_name: String = " ".join(entry_region_parts)
					
					if entry_region_name == REGION_NAME:
						region_begin_found = true
	
	if not region_begin_found and not region_end_found:
		printerr("Region: '%s' not found in file at path: '%s'!" % [REGION_NAME, FILE_PATH])
		return ""
	
	for __: int in END_BLANK_LINES_COUNT:
		result_parts.append("\t\"\",")
	
	var result: String
	var joined_result_parts: String = "\n".join(result_parts)
	
	match RESULT_TYPE:
		ResultType.DECLARED_VARIABLE:
			result = "var script: PackedStringArray = PackedStringArray([\n%s\n])" % joined_result_parts
		
		ResultType.UNDECLARED_VARIABLE:
			result = "PackedStringArray([\n%s\n])" % joined_result_parts
		
		_:
			result = joined_result_parts
	
	if COPY_TO_CLIPBOARD:
		DisplayServer.clipboard_set(result)
	
	if PRINT_RESULT:
		print(result)
	
	return result
#endregion
