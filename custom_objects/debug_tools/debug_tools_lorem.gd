#@tool
class_name DebugToolsLorem
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion

#region Static Methods
static func get_words(
	additional_entries: PackedStringArray = PackedStringArray([]),
	custom_entries: PackedStringArray = PackedStringArray([])
	) -> PackedStringArray:
		if custom_entries == null:
			var result: PackedStringArray = PackedStringArray([[
				"adipisci", "aliquam", "amet", "consectetur", "dolor", "dolore", "dolorem", "eius", "est", "et",
				"incidunt", "ipsum", "labore", "magnam", "modi", "neque", "non", "numquam", "porro", "quaerat", "qui",
				"quia", "quisquam", "sed", "sit", "tempora", "ut", "velit", "voluptatem",
				]])
			
			result.append_array(additional_entries)
			
			return result
		
		return custom_entries


static func get_random_word(custom_words: PackedStringArray = PackedStringArray([])) -> String:
	var words: PackedStringArray = get_words() if custom_words.is_empty() else custom_words
	
	return words[randi_range(0, words.size() - 1)]


static func generate_sentence(
	sentence_range: Vector2i = Vector2i(4, 8),
	sentence_separator: String = " ",
	if_empty: String = "",
	custom_words: PackedStringArray = PackedStringArray([]),
	) -> String:
		var range_words: int = randi_range(sentence_range.x, sentence_range.y)
		var selected_words: PackedStringArray
		
		for __: int in range_words:
			selected_words.append(get_random_word(custom_words))
		
		if selected_words.is_empty():
			return if_empty
		
		selected_words[0] = selected_words[0].capitalize()
		
		return "%s." % sentence_separator.join(selected_words)


static func generate_paragraph(
	paragraph_range: Vector2i = Vector2i(5, 10),
	sentence_range: Vector2i = Vector2i(4, 8),
	paragraph_separator: String = "\n",
	sentence_separator: String = " ",
	if_empty: String = "",
	custom_words: PackedStringArray = PackedStringArray([]),
	) -> String:
		var range_lines: int = randi_range(paragraph_range.x, paragraph_range.y)
		var sentences: PackedStringArray
		
		for __: int in range_lines:
			sentences.append(generate_sentence(sentence_range, sentence_separator, if_empty, custom_words))
		
		if sentences.is_empty():
			return if_empty
		
		return paragraph_separator.join(sentences)


static func generate_text(
	text_range: Vector2i = Vector2i(3, 6),
	paragraph_range: Vector2i = Vector2i(5, 10),
	sentence_range: Vector2i = Vector2i(4, 8),
	text_separator: String = "\n\n",
	paragraph_separator: String = "\n",
	sentence_separator: String = " ",
	if_empty: String = "",
	custom_words: PackedStringArray = PackedStringArray([]),
	) -> String:
		var range_texts: int = randi_range(text_range.x, text_range.y)
		var paragraphs: PackedStringArray
		
		for __: int in range_texts:
			paragraphs.append(generate_paragraph(
				paragraph_range, sentence_range, paragraph_separator, sentence_separator, if_empty, custom_words
				))
		
		if paragraphs.is_empty():
			return if_empty
		
		return text_separator.join(paragraphs)
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
