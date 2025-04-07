"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsRegex


#region Regular Expressions
const SUB_BBCODE: String = r"\[.+?\]" # Removes bbcode tags
const SUB_LETTERS: String = r"[^a-zA-Z ]+"
const SUB_ALPHANUMERIC: String = r"[^a-zA-Z0-9 ]+"

const MATCH_YYYY_MM_DD: String = r"^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$" # text == YYYY-MM-DD
const MATCH_VERSION_3DIGITS: String = r"^\d+\.\d+\.\d+$" # text == {DIGIT}.{DIGIT}.{DIGIT}
const MATCH_FILENAME_VERSION: String = r"_v\d+$" # text == {TEXT}_v{DIGITS}
const MATCH_INTEGER: String = r"^(-|\d+|-\d+)$"
const MATCH_INTEGER_POSITIVE: String = r"^(\d+)$"
const MATCH_FLOAT: String = r"^(-|-?\d+\.?\d*|-?\.\d+)$"
const MATCH_FLOAT_POSITIVE: String = r"^(\d+\.?\d*|\.\d+)$"
const MATCH_HOST_IP: String = r"^(\d{1,3}\.){3}\d{1,3}$"
const MATCH_HOST_DOMAIN: String = r"^(?:[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+)$"

const FIND_FIRST_NEGATIVE_NUMBER: String = r"-\d+"
const FIND_NON_EMPTY_TUPLE: String = r"\([^)]+\)"
#endregion

#region Public Static Methods
static func find(pattern: String, text: String, offset: int = 0, end: int = -1) -> String:
	var regex_match: RegExMatch = get_match(pattern, text, offset, end)
	
	return "" if regex_match == null else regex_match.get_string()


static func sub(
	pattern: String, text: String, replacement: String = "", all: bool = true, offset: int = 0, end: int = -1
	) -> String:
		return compile(pattern).sub(text, replacement, all, offset, end)


static func is_valid(pattern: String, text: String, offset: int = 0, end: int = -1) -> bool:
	return get_match(pattern, text, offset, end) != null


static func get_match(pattern: String, text: String, offset: int = 0, end: int = -1) -> RegExMatch:
	return compile(pattern).search(text, offset, end)


static func compile(pattern: String) -> RegEx:
	var regex: RegEx = RegEx.new()
	var error: Error = regex.compile(pattern)
	
	if error != OK:
		return null
	
	return regex
#endregion
