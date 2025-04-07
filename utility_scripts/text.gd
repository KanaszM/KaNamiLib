"""
# Version 1.0.0 (01-Apr-2025):
	- Initial release;
"""


class_name UtilsText


static func truncate_middle(text: String, front_length: int, back_length: int = 0, ellipsis: String = "...") -> String:
	front_length = maxi(0, front_length)
	back_length = maxi(front_length, back_length)
	
	if text.length() <= front_length + back_length + ellipsis.length():
		return text
	
	return text.substr(0, front_length) + ellipsis + text.substr(text.length() - back_length, back_length)


static func truncate(text: String, max_length: int, ellipsis: String = "...") -> String:
	return text if text.length() < max_length else ("%s%s" % [text.left(max_length + ellipsis.length()), ellipsis])


static func strip(text: String) -> String:
	return text.strip_edges().strip_escapes()


static func is_empty_or_null(text: String, null_strings: Array[String] = ["<null>", "null"]) -> bool:
	text = text.strip_edges()
	
	return text.is_empty() or text.to_lower() in null_strings
	
	
static func insert_between(text: String, with: String) -> String:
	var result: String = text[0]
	
	for idx: int in range(1, text.length()):
		result += with + text[idx]
	
	return result


static func word_wrap(text: String, max_line_length: int) -> String:
	var wrapped_text: String = ""
	var current_line: String
	
	for word: String in text.split(" "):
		if current_line.length() + word.length() + 1 > max_line_length:
			wrapped_text += current_line.strip_edges() + "\n"
			current_line = word + " "
		
		else:
			current_line += word + " "
	
	wrapped_text += current_line.strip_edges()
	
	return wrapped_text


static func capitalize(text: String) -> String:
	text = strip(text)
	
	if text.is_empty():
		return ""
	
	text = text.replace("_", " ")
	
	var first_letter: String
	var letter_count: int = 0
	
	while letter_count < text.length():
		var current_letter: String = text[letter_count]
		
		if current_letter != " ":
			first_letter = current_letter
			break
		
		letter_count += 1
	
	if first_letter.is_empty():
		return text
	
	text = text.trim_prefix(first_letter)
	
	return "%s%s" % [first_letter.to_upper(), text.to_lower()]
