"""
# Version 1.0.0 (03-Apr-2025):
	- Reviewed release;
"""

class_name UtilsCMD


#region Constants
const PATH_POWERSHELL: String = "powershell.exe"
#endregion

#region Public Static Methods [PowerShell]
static func convert_xlsx_to_csv(path_xlsx_input: String, path_csv_output: String) -> void:
	execute(PATH_POWERSHELL, PackedStringArray([
		"$inputPath = '%s'" % path_xlsx_input,
		"$outputPath = '%s'" % path_csv_output,
		"$excel = New-Object -ComObject Excel.Application",
		"$excel.Visible = $false",
		"$workbook = $excel.Workbooks.Open($inputPath)",
		"$tempCsvPath = $outputPath + '.tmp'",
		"$workbook.Worksheets.Item(1).SaveAs($tempCsvPath, 6)",
		"$workbook.Close($false)",
		"$excel.Quit()",
		"[System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null",
		"[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null",
		"Get-Content -Path $tempCsvPath | Set-Content -Path $outputPath -Encoding UTF8",
		"Remove-Item -Path $tempCsvPath",
		"Write-Output 'File converted to UTF-8 CSV: $outputPath'"
		]))


static func get_process_id(process_name: String) -> PackedInt32Array:
	var results: PackedInt32Array
	var output: Array[String] = execute(PATH_POWERSHELL, PackedStringArray([
		"/C",
		"tasklist /v /fo csv | findstr /i \"%s\"" % process_name
		]))
	
	for result: String in output:
		if not result.is_empty():
			for slice in (result as String).split("\n"):
				if not slice.is_empty():
					results.append(int((slice as String).get_slice(SPTerm.Divider.COMMA, 1).replace("\"", "")))
	
	return results


static func get_processes_count(process_name: String) -> int:
	var result: Array[String] = execute(PATH_POWERSHELL, PackedStringArray([
		"/C",
		"get-process %s | measure-object -line | select Lines -expandproperty Lines" % process_name
		]))
	
	return 0 if result.is_empty() else result[0].to_int()


static func close_process(process_name: String) -> void:
	execute(PATH_POWERSHELL, PackedStringArray(["taskkill /f /im %s.exe" % process_name]))
#endregion

#region #region Public Static Methods
static func execute(path: String, source: PackedStringArray) -> Array[String]:
	if OS.get_name() != "Windows":
		return []
	
	var arguments: PackedStringArray
	
	for line: String in source:
		arguments.append("\n%s" % line)
	
	var output: Array[String]
	
	OS.execute(path, arguments, output)
	return output
#endregion
