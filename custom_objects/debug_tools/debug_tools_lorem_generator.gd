"""
# Version 1.0.0 (03-Apr-2025):
	- Reviewed release;
"""

#@tool
class_name DebugToolsLoremGenerator
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
const WORDS: Array[String] = [
	"adipisci", "aliquam", "amet", "consectetur", "dolor", "dolore", "dolorem", "eius", "est", "et",
	"incidunt", "ipsum", "labore", "magnam", "modi", "neque", "non", "numquam", "porro", "quaerat", "qui",
	"quia", "quisquam", "sed", "sit", "tempora", "ut", "velit", "voluptatem",
	]

const SENTENCE_SEPARATOR: String = " "
const PARAGRAPH_SEPARATOR: String = "\n"
const TEXT_SEPARATOR: String = "\n\n"
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
static func sentence(s_range: Vector2i = Vector2i(4, 8)) -> String:
	var range_words: int = randi_range(s_range.x, s_range.y)
	var selected_words: PackedStringArray
	
	for __: int in range_words:
		selected_words.append(word())
	
	if selected_words.is_empty():
		return ""
	
	selected_words[0] = selected_words[0].capitalize()
	
	return "%s." % SENTENCE_SEPARATOR.join(selected_words)


static func paragraph(p_range: Vector2i = Vector2i(5, 10), s_range: Vector2i = Vector2i(4, 8)) -> String:
	var range_lines: int = randi_range(p_range.x, p_range.y)
	var sentences: PackedStringArray
	
	for __: int in range_lines:
		sentences.append(sentence(s_range))
	
	if sentences.is_empty():
		return ""
	
	return PARAGRAPH_SEPARATOR.join(sentences)


static func text(
	t_range: Vector2i = Vector2i(3, 6), p_range: Vector2i = Vector2i(5, 10), s_range: Vector2i = Vector2i(4, 8)
	) -> String:
		var range_texts: int = randi_range(t_range.x, t_range.y)
		var paragraphs: PackedStringArray
		
		for __: int in range_texts:
			paragraphs.append(paragraph(p_range, s_range))
		
		if paragraphs.is_empty():
			return ""
		
		return TEXT_SEPARATOR.join(paragraphs)


static func word() -> String:
	return WORDS[randi_range(0, WORDS.size() - 1)]
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
