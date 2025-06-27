@tool
class_name ExtendedLineEdit
extends LineEdit

#region Enums
enum PatternType {ANY, LETTERS, INTEGER, POSITIVE_INTEGER, FLOAT, POSITIVE_FLOAT, ALPHANUMERIC}
enum ConversionType {NONE, LOWER, UPPER, CAPITALIZE}
#endregion

#region Export Variables
@export var pattern: PatternType = PatternType.ANY: set = _set_pattern

@export_group("Conversion", "conversion_")
@export var conversion_type: ConversionType = ConversionType.NONE: set = _set_conversion_type
@export var conversion_strip_enabled: bool: set = _set_conversion_strip_enabled
#endregion

#region Private Variables
var _block_updates: bool = true
var _previous_valid_numeric_text: String
#endregion

#region Virtual Methods
func _ready() -> void:
	_set_pattern(pattern)
	_set_conversion_type(conversion_type)
	_set_conversion_strip_enabled(conversion_strip_enabled)
	
	_block_updates = false
	apply_conversion()
#endregion

#region Public Methods
func apply_conversion(text_ovveride: String = "") -> ExtendedLineEdit:
	if not _block_updates:
		text = convert_text(text if text_ovveride.is_empty() else text_ovveride)
	
	return self


func convert_text(what: String) -> String:
	if conversion_strip_enabled:
		what = what.strip_edges().strip_escapes()
	
	match conversion_type:
		ConversionType.UPPER: what = what.to_upper()
		ConversionType.LOWER: what = what.to_lower()
		ConversionType.CAPITALIZE: what = UtilsText.capitalize(what)
	
	return what


func is_empty() -> bool:
	return UtilsText.strip(text).is_empty()
#endregion

#region Theme Methods
func set_font_size(value: int) -> void:
	add_theme_font_size_override(&"font_size", value)


func set_font_color(color: Color) -> void:
	add_theme_color_override(&"font_color", color)


func set_font_color_disabled(color: Color) -> void:
	add_theme_color_override(&"font_uneditable_color", color)


func set_font_shade(type: Shade.Type, index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_color", Shade.get_color(type, index, reversed))


func set_font_shade_disabled(type: Shade.Type, index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_uneditable_color", Shade.get_color(type, index, reversed))


func set_font_placeholder_color(color: Color) -> void:
	add_theme_color_override(&"font_placeholder_color", color)


func set_font_placeholder_shade(type: Shade.Type, index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_placeholder_color", Shade.get_color(type, index, reversed))


func set_font_caret_color(color: Color) -> void:
	add_theme_color_override(&"caret_color", color)


func set_font_caret_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"caret_color", Shade.get_color(shade_type, shade_index, reversed))


func set_clear_button_color(color: Color, alpha: float = 1.0) -> void:
	color.a = alpha
	
	for color_type: StringName in [&"clear_button_color", &"clear_button_color_pressed"] as Array[StringName]:
		add_theme_color_override(color_type, color)


func set_clear_button_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	set_clear_button_color(Shade.get_color(shade_type, shade_index, reversed))


func set_focus_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"focus", style)


func set_normal_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"normal", style)


func set_read_only_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"read_only", style)
#endregion

#region Signal Callbacks
func _on_text_changed(_new_text: String) -> void:
	var pattern_type: String
	
	match pattern:
		PatternType.LETTERS, PatternType.ALPHANUMERIC:
			match pattern:
				PatternType.LETTERS: pattern_type = UtilsRegex.SUB_LETTERS
				PatternType.ALPHANUMERIC: pattern_type = UtilsRegex.SUB_ALPHANUMERIC
			
			var previous_text: String = text
			var previous_caret_column: int = caret_column
			var subbed_text: String = convert_text(UtilsRegex.sub(pattern_type, text, ""))
			var text_length_difference: int = previous_text.length() - subbed_text.length()
			
			text = subbed_text
			caret_column = previous_caret_column - text_length_difference
		
		PatternType.INTEGER, PatternType.POSITIVE_INTEGER, PatternType.FLOAT, PatternType.POSITIVE_FLOAT:
			match pattern:
				PatternType.INTEGER: pattern_type = UtilsRegex.MATCH_INTEGER
				PatternType.POSITIVE_INTEGER: pattern_type = UtilsRegex.MATCH_INTEGER_POSITIVE
				PatternType.FLOAT: pattern_type = UtilsRegex.MATCH_FLOAT
				PatternType.POSITIVE_FLOAT: pattern_type = UtilsRegex.MATCH_FLOAT_POSITIVE
			
			if text.is_empty():
				_previous_valid_numeric_text = ""
				return
			
			var matched_text: RegExMatch = UtilsRegex.get_match(pattern_type, text)
			
			if matched_text == null:
				text = _previous_valid_numeric_text
				caret_column = _previous_valid_numeric_text.length()
			
			else:
				_previous_valid_numeric_text = text
				caret_column -= _previous_valid_numeric_text.length() - text.length()
#endregion

#region Setter Methods
func _set_pattern(arg: PatternType) -> void:
	pattern = arg
	
	if pattern == PatternType.ANY:
		UtilsSignal.disconnect_safe(text_changed, _on_text_changed)
	
	else:
		UtilsSignal.connect_safe_and_call(text_changed, _on_text_changed)


func _set_conversion_type(arg: ConversionType) -> void:
	conversion_type = arg
	apply_conversion()


func _set_conversion_strip_enabled(arg: bool) -> void:
	conversion_strip_enabled = arg
	apply_conversion()
#endregion
