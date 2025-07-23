class_name DateTime extends Resource

#region Enums
enum Language {EN}
enum DateNameType {DAYS_SHORT, DAYS_LONG, MONTHS_SHORT, MONTHS_LONG}
#endregion

#region Constants
const MIN_YEAR: int = 1000
const MAX_YEAR: int = 9999

const CALENDAR_DAYS_COUNT: int = 42
const ZELLER_CONGRUENCE: Array[int] = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]

const DATE_NAMES_EN: Dictionary[DateNameType, Array] = {
	DateNameType.DAYS_SHORT: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
	DateNameType.DAYS_LONG: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
	DateNameType.MONTHS_SHORT: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
	DateNameType.MONTHS_LONG: [
		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November",
		"December"
		],
}
#endregion

#region Export Variables
@export var language: Language = Language.EN
@export var day: int: set = _set_day
@export var month: int: set = _set_month
@export var year: int: set = _set_year
#endregion

#region Constructor
func _init(d: int = 0, m: int = 0, y: int = 0) -> void:
	var today_dict: Dictionary[String, int] = get_today_dict()
	
	day = d if d > 0 else today_dict.day
	month = m if m > 0 else today_dict.month
	year = y if y > 0 else today_dict.year
#endregion

#region Increment Methods
func increment_day(mode: bool, max_iteration: int = 1) -> void:
	var current_iteration: int = 0
	
	while current_iteration < max_iteration:
		day += 1 if mode else -1
		
		if day > get_days_in_month():
			increment_month(true)
			day = 1
		
		elif day < 1:
			increment_month(false)
			day = get_days_in_month()
		
		current_iteration += 1
	
	emit_changed()


func increment_month(mode: bool, max_iteration: int = 1) -> void:
	var current_iteration: int = 0
	
	while current_iteration < max_iteration:
		month += 1 if mode else -1
		
		if month > 12:
			month = 1
			year += 1
		
		elif month < 1:
			month = 12
			year -= 1
		
		current_iteration += 1
	
	emit_changed()


func increment_year(mode: bool, max_iteration: int = 1) -> void:
	year = (year + max_iteration) if mode else (year - max_iteration)
	day = day
	emit_changed()
#endregion

#region Format Methods
func format_date(
	format_d: Variant = null,
	format_m: Variant = null,
	format_y: Variant = null,
	delimiter: String = "-"
	) -> String:
		var formats: PackedStringArray
		
		if format_d != null:
			formats.append(format_day(format_d))
		
		if format_m != null:
			formats.append(format_month(format_m))
		
		if format_y != null:
			formats.append(format_year(format_y))
		
		return join_formats(formats, delimiter)


func format_day(format: int = 0, d: int = day, m: int = month, y: int = year) -> String:
	match format:
		1: return str(d)
		2: return str(d).pad_zeros(2)
		3: return get_date_names(language, DateNameType.DAYS_LONG)[get_weekday(d, m, y)].left(2)
		4: return get_date_names(language, DateNameType.DAYS_LONG)[get_weekday(d, m, y)].left(3)
		_: return get_date_names(language, DateNameType.DAYS_LONG)[get_weekday(d, m, y)]


func format_month(format: int = 0, m: int = month) -> String:
	match format:
		1: return str(m)
		2: return str(m).pad_zeros(2)
		3: return get_date_names(language, DateNameType.MONTHS_LONG)[m - 1].left(3)
		_: return get_date_names(language, DateNameType.MONTHS_LONG)[m - 1]


func format_year(format: int = 0, y: int = year) -> String:
	return str(y) if format >= 4 else str(y).right(2)


func join_formats(formatted_strings: PackedStringArray, delimiter: String = "-") -> String:
	return delimiter.join(formatted_strings)
#endregion

#region Calendar Methods
func get_calendar_dict(m: int = month, y: int = year) -> Dictionary[int, Dictionary]:
	var clamped_month: int = clamp_month(m)
	var clamped_year: int = clamp_year(y)
	var calendar_dict: Dictionary[int, Dictionary]
	var day_first: int = get_weekday(1, clamped_month, clamped_year)
	var day_count: int = 1
	
	for day_idx: int in CALENDAR_DAYS_COUNT:
		calendar_dict[day_idx] = {}
		
		if day_idx in range(day_first, get_days_in_month(clamped_month, clamped_year) + day_first):
			calendar_dict[day_idx] = {
				"day": day_count,
				"row": int(day_idx / 7.0),
				"week": get_iso_week_number(day_count, clamped_month, clamped_year),
				"weekday": get_weekday(day_count, clamped_month, clamped_year)
				}
			day_count += 1
	
	return calendar_dict


func get_calendar_array2d(m: int = month, y: int = year) -> Array:
	var calendar_array2d: Array
	var calendar_dict: Dictionary[int, Dictionary] = get_calendar_dict(m, y)
	var last_day_idx: int
	
	for row_idx: int in sqrt(CALENDAR_DAYS_COUNT) - 1:
		var row: PackedStringArray
		var row_range: PackedInt32Array = PackedInt32Array(range(last_day_idx, last_day_idx + 7))
		
		row.resize(7)
		row.fill("  ")
		
		for idx: int in row_range.size():
			var day_idx: int = row_range[idx]
			
			if not calendar_dict[day_idx].is_empty():
				row[idx] = str(calendar_dict[day_idx].day).pad_zeros(2)
			
			if idx == row_range.size() - 1:
				last_day_idx = day_idx + 1
		
		calendar_array2d.append(row)
	
	return calendar_array2d


func print_calendar(m: int = month, y: int = year) -> void:
	var func_print_row: Callable = func(row: Array) -> void:
		print("\t%s" % str(row).replace("\"", "").replace(",", "").replace("[", "|").replace("]", "|"))
	
	print("\n".join([
		"\n\t%s %d (Week: %d)" % [format_month(4, m), year, get_iso_week_number()],
		"\tToday: %s (%s)\n" % [format_day(2), format_day(5)]
		]))
	
	func_print_row.call(
		get_date_names(language, DateNameType.DAYS_LONG).map(
			func substr(text: String) -> String: return text.substr(0, 2)
			)
		)
	
	get_calendar_array2d(m, y).any(func print_row(row: Array) -> void: func_print_row.call(row))
#endregion

#region General Methods
func set_today() -> void:
	var today_dict: Dictionary[String, int] = get_today_dict()
	
	day = today_dict.day
	month = today_dict.month
	year = today_dict.year
	
	emit_changed()


func get_days_in_month(m: int = month, y: int = year) -> int:
	var clamped_month: int = clamp_month(m)
	var clamped_year: int = clamp_year(y)
	
	if clamped_month in PackedInt32Array([4, 6, 9, 11]):
		return 30
	
	elif clamped_month == 2:
		if (clamped_year % 4 == 0 and clamped_year % 100 != 0) or (clamped_year % 400 == 0):
			return 29
		
		else:
			return 28
	
	return 31


func get_weekday(d: int = day, m: int = month, y: int = year) -> int:
	var clamped_day: int = clamp_day(d, m ,y)
	var clamped_month: int = clamp_month(m)
	var clamped_year: int = clamp_year(y)
	var day_value: int = ZELLER_CONGRUENCE[clamped_month - 1] + clamped_day - 1
	var year_value: int = clamped_year - 1 if clamped_month < 3 else clamped_year
	
	return ((year_value + int(year_value / 4.0) - int(year_value / 100.0) + int(year_value / 400.0) + day_value) % 7)


func get_last_week_day_of_year(y: int = year) -> int:
	var clamped_year: int = clamp_year(y)
	
	return (clamped_year + int(clamped_year / 4.0) - int(clamped_year / 100.0) + int(clamped_year / 400.0)) % 7


func get_number_of_weeks_of_year(y: int = year) -> int:
	return 52 + (1 if get_last_week_day_of_year(y) == 4 or get_last_week_day_of_year(clamp_year(y) - 1) == 3 else 0)


func get_iso_day_of_year(d: int = day, m: int = month, y: int = year) -> int:
	return int((get_unix(d, m, y) - get_unix_first_day_of_year(y)) / 86400.0) + 1


func get_iso_week_number(d: int = day, m: int = month, y: int = year) -> int:
	var iso_day_of_year: int = get_iso_day_of_year(d, m, y) - 1
	var iso_weekday: int = (get_last_week_day_of_year(y - 1) + iso_day_of_year) % 7 + 1
	var iso_week_number: int = int(float(iso_day_of_year + 1 - iso_weekday + 10) / 7.0)
	
	if iso_week_number < 1:
		return get_number_of_weeks_of_year(y - 1)
	
	elif iso_week_number > get_number_of_weeks_of_year(y):
		return 1
	
	return iso_week_number


func get_unix(d: int = day, m: int = month, y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict(
		{"day": clamp_day(d, m, y), "month": clamp_month(m), "year": clamp_year(y)}
		)


func get_unix_first_day_of_year(y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": clamp_year(y), "month": 1, "day": 1})


func to_dict() -> Dictionary[String, int]:
	return {"day": day, "month": month, "year": year}


func get_today_dict(utc: bool = false) -> Dictionary[String, int]:
	var system_date := Dictionary(
		Time.get_date_dict_from_system(utc), TYPE_STRING, &"", null, TYPE_INT, &"", null
		) as Dictionary[String, int]
	
	return {"day": system_date.day, "month": system_date.month, "year": system_date.year}
#endregion

#region Helper Methods
func clamp_day(d: int = day, m: int = month, y: int = year) -> int:
	return clampi(d, 1, get_days_in_month(m, y))


func clamp_month(m: int = month) -> int:
	return clampi(m, 1, 12)


func clamp_year(y: int = year) -> int:
	return clampi(y, MIN_YEAR, MAX_YEAR)
#endregion

#region Static Methods
static func month_name_to_number(month_name: String, language_param: Language = Language.EN) -> int:
	return get_date_names(language_param, DateNameType.MONTHS_LONG).find(month_name.strip_edges().capitalize()) + 1


static func get_date_names(language_flag: Language, name_type_flag: DateNameType) -> Array[String]:
	match language_flag:
		Language.EN: return Array(DATE_NAMES_EN[name_type_flag], TYPE_STRING, &"", null) as Array[String]
		_: return []


static func format_system_datetime_stamp(
	datetime_stamp: String,
	date_format: String,
	time_format: String,
	date_separator: String = "-",
	time_separator: String = ":",
	between_separator: String = " ",
	language_flag: Language = Language.EN,
	) -> String:
		return "" if datetime_stamp.length() < 14 else format_system_datetime(
			date_format,
			time_format,
			split_system_stamp(datetime_stamp),
			date_separator,
			time_separator,
			between_separator,
			language_flag,
			)


static func format_system_datetime(
	date_format: String,
	time_format: String,
	custom_system_datetime: Dictionary[String, int] = {},
	date_separator: String = "-",
	time_separator: String = ":",
	between_separator: String = " ",
	language_flag: Language = Language.EN,
	) -> String:
		return "%s%s%s" % [
			format_system_date(date_format, custom_system_datetime, date_separator, language_flag),
			"" if time_format.is_empty() else between_separator,
			format_system_time(time_format, custom_system_datetime, time_separator),
			]


static func format_system_time(
	format: String, custom_system_time: Dictionary[String, int] = {}, separator: String = ":"
	) -> String:
		var time_dict := Dictionary(
			Time.get_time_dict_from_system() if custom_system_time.is_empty() else custom_system_time,
			TYPE_STRING, &"", null, TYPE_INT, &"", null
			) as Dictionary[String, int]
		var formats: Dictionary[String, int]
		
		for chr: String in format:
			if not chr in formats:
				chr = chr.to_lower()
				formats[chr] = 0
			
			formats[chr] += 1
		
		var result: String = ""
		
		for chr: String in formats:
			var time_value: int
			
			match chr:
				"h": time_value = time_dict.hour
				"m": time_value = time_dict.minute
				"s": time_value = time_dict.second
			
			result += ("%02d" if formats[chr] >= 2 else "%d") % time_value
			result += separator
		
		return result if separator.is_empty() else UtilsRegex.sub("%s+$" % separator, result)


static func format_system_date(
	format: String,
	custom_system_date: Dictionary[String, int] = {},
	separator: String = "-",
	language_flag: Language = Language.EN,
	) -> String:
		var date_dict := Dictionary(
			Time.get_date_dict_from_system() if custom_system_date.is_empty() else custom_system_date,
			TYPE_STRING, &"", null, TYPE_INT, &"", null
			) as Dictionary[String, int]
		var formats: Dictionary[String, int]
		
		for chr: String in format:
			if not chr in formats:
				chr = chr.to_lower()
				formats[chr] = 0
			
			formats[chr] += 1
		
		var result: String = ""
		
		for chr: String in formats:
			match chr:
				"d":
					match formats[chr]:
						0: pass
						1: result += "%d" % date_dict.day
						2: result += "%02d" % date_dict.day
						3: result += get_date_names(language_flag, DateNameType.DAYS_SHORT)[date_dict.day - 1]
						_: result += get_date_names(language_flag, DateNameType.DAYS_LONG)[date_dict.day - 1]
				
				"m":
					match formats[chr]:
						0: pass
						1: result += "%d" % date_dict.month
						2: result += "%02d" % date_dict.month
						3: result += get_date_names(language_flag, DateNameType.MONTHS_SHORT)[date_dict.month - 1]
						_: result += get_date_names(language_flag, DateNameType.MONTHS_SHORT)[date_dict.month - 1]
				
				"y":
					if formats[chr] >= 4:
						result += str(date_dict.year)
					
					else:
						result += str((date_dict.year))[-2] + str((date_dict.year))[-1]
			
			result += separator
		
		return result if separator.is_empty() else UtilsRegex.sub("%s+$" % separator, result)


static func stamp(separator: String = "") -> String:
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	
	return separator.join(PackedStringArray([
		str(datetime.year),
		"%02d" % datetime.month,
		"%02d" % datetime.day,
		"%02d" % datetime.hour,
		"%02d" % datetime.minute,
		"%02d" % datetime.second,
		]))


static func destamp(
	datetime_stamp: String, date_separator: String = "-", time_separator: String = ":", between_separator: String = " "
	) -> String:
		if datetime_stamp.length() < 14:
			return datetime_stamp
		
		var indices: PackedInt32Array = PackedInt32Array([4, 7, 10, 13, 16])
		
		for idx: int in indices:
			var separator: String = between_separator
			
			if idx < indices[2]:
				separator = date_separator
			
			elif idx > indices[2]:
				separator = time_separator
			
			datetime_stamp = datetime_stamp.insert(idx, separator)
		
		return datetime_stamp


static func split_system_stamp(datetime_stamp: String) -> Dictionary[String, int]:
	return {} if datetime_stamp.length() < 14 else {
		"year": int(datetime_stamp.substr(0, 4)),
		"month": int(datetime_stamp.substr(4, 2)),
		"day": int(datetime_stamp.substr(6, 2)),
		"hour": int(datetime_stamp.substr(8, 2)),
		"minute": int(datetime_stamp.substr(10, 2)),
		"second": int(datetime_stamp.substr(12, 2)),
	}
#endregion

#region Private Methods
func _to_string() -> String:
	return format_date(2, 4, 4)
#endregion

#region Setter Methods
func _set_day(arg: int) -> void:
	day = clamp_day(arg, month, year)
	emit_changed()


func _set_month(arg: int) -> void:
	month = clamp_month(arg)
	emit_changed()


func _set_year(arg: int) -> void:
	year = clamp_year(arg)
	emit_changed()
#endregion
