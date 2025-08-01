class_name RTL

#region Constants
const DEFAULT_TEXT_SIZE: int = 14
const DEFAULT_NEWLINES_COUNT: int = 1
#endregion

#region Private Variables
var _bold: bool: set = bold
var _center: bool: set = center
var _underline: bool: set = underline

var _size: int = DEFAULT_TEXT_SIZE: set = size
var _color: Color = Color.TRANSPARENT: set = color
var _text: String
var _image_size: Vector2i
var _image_path: String

var _newlines_before: int: set = newlines_before
var _newlines_after: int: set = newlines_after
#endregion

#region Constructor
func _init(source: Variant = null) -> void:
	(_set_as_list if UtilsArray.is_array(source) else _set_as_text).call(source)
#endregion

#region Public Methods
func image(image_path: String, width: int = _image_size.x, height: int = _image_size.y) -> RTL:
	_image_path = image_path
	_image_size = Vector2i(width, height)
	
	return self


func newlines_before_and_after(
	value_before: int = DEFAULT_NEWLINES_COUNT, value_after: int = DEFAULT_NEWLINES_COUNT
	) -> RTL:
		_newlines_before = value_before
		_newlines_after = value_after
		
		return self


func indent_prefix(prefix: String) -> RTL:
	return _set_indent(prefix, true)


func indent_suffix(prefix: String) -> RTL:
	return _set_indent(prefix, false)


func get_formatted() -> String:
	var newlines_start: String = "".lpad(_newlines_before, "\n")
	var newlines_end: String = "".lpad(_newlines_after, "\n")
	var size_start: String = "[font_size=%d]" % _size
	var size_end: String = "[/font_size]"
	var color_start: String = ("[color=#%s]" % _color.to_html()) if _color != Color.TRANSPARENT else ""
	var color_end: String = "[/color]" if _color != Color.TRANSPARENT else ""
	var bold_start: String = "[b]" if _bold else ""
	var bold_end: String = "[/b]" if _bold else ""
	var underline_start: String = "[u]" if _underline else ""
	var underline_end: String = "[/u]" if _underline else ""
	var center_start: String = "[center]" if _center else ""
	var center_end: String = "[/center]" if _center else ""
	var text_start_end: String = _text
	var image_start_end: String = (
		"" if _image_path.is_empty()
		else (
			"[img%s]%s[/img]" % [("=%d" % _image_size.x) if _image_size.y == 0
			else ("=%dx%d" % [_image_size.x, _image_size.y]), _image_path]
			)
		)
	
	return "".join(PackedStringArray([
		newlines_start,
		size_start,
		color_start,
		bold_start,
		underline_start,
		center_start,
		text_start_end,
		image_start_end,
		center_end,
		underline_end,
		bold_end,
		color_end,
		size_end,
		newlines_end,
	]))
#endregion

#region Static Methods
static func append_to(label: RichTextLabel, rtl: RTL, clear: bool = false) -> void:
	if clear:
		label.clear()
	
	label.append_text(str(rtl))


static func append_paragraph_to(
	label: RichTextLabel, entries: Array, base_text_size: int = DEFAULT_TEXT_SIZE, clear: bool = true
	) -> void:
		label.bbcode_enabled = true
		
		if clear:
			label.clear()
		
		for entry_idx: int in entries.size():
			var entry: Variant = entries[entry_idx]
			
			match typeof(entry):
				TYPE_ARRAY:
					entry = entry as Array
					append_paragraph_to(label, entry, base_text_size)
				
				TYPE_STRING:
					entry = entry as String
					label.append_text(entry)
				
				TYPE_OBJECT when entry is RTL:
					entry = entry as RTL
					
					if base_text_size > 0 and entry._size < base_text_size:
						entry.size(base_text_size)
					
					if entry_idx < entries.size():
						entry._newlines_after += 1
					
					label.append_text(str(entry))
				
				TYPE_OBJECT when entry is RTLSentence:
					entry = entry as RTLSentence
					
					var texts: PackedStringArray
					
					for rtl: RTL in entry.rtls:
						if base_text_size > 0 and rtl._size < base_text_size:
							rtl.size(base_text_size)
						
						texts.append(str(rtl))
					
					label.append_text(entry.join_character.join(texts))
					
					if entry_idx < entries.size():
						label.append_text("\n")


static func strip_tags(source: String) -> String:
	return UtilsRegex.sub(UtilsRegex.SUB_BBCODE, source).strip_edges()
#endregion

#region Private Methods
func _to_string() -> String:
	return get_formatted()


func _set_as_text(source: Variant) -> RTL:
	source = str(source)
	_text = "" if UtilsText.is_empty_or_null(source) else source
	
	return self


func _set_as_list(source: Array) -> RTL:
	_text = "[ul]%s[/ul]" % "\n".join(source)
	
	return self


func _set_indent(character: String, is_prefix: bool) -> RTL:
	var temp_parts: PackedStringArray
	
	for part: String in _text.split("\n"):
		temp_parts.append("%s %s" % [character if is_prefix else part, character if not is_prefix else part])
	
	_text = "\n".join(temp_parts)
	
	return self
#endregion

#region Setter Methods
func bold(arg: bool = true) -> RTL:
	_bold = arg
	return self


func center(arg: bool = true) -> RTL:
	_center = arg
	return self


func underline(arg: bool = true) -> RTL:
	_underline = arg
	return self


func size(arg: int = DEFAULT_TEXT_SIZE) -> RTL:
	_size = arg
	return self


func color(arg: Color = Color.TRANSPARENT) -> RTL:
	_color = arg
	return self


func newlines_before(arg: int = DEFAULT_NEWLINES_COUNT) -> RTL:
	_newlines_before = arg
	return self


func newlines_after(arg: int = DEFAULT_NEWLINES_COUNT) -> RTL:
	_newlines_after = arg
	return self
#endregion
