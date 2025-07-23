@tool
class_name ExtendedTextEdit extends TextEdit

#region Export Variables
@export var max_length: int: set = _set_max_length
#endregion

#region Private Variables
var _previous_text: String
var _caret_column: int
var _caret_line: int
#endregion

#region Public Methods
func is_empty() -> bool:
	return text.strip_edges().strip_escapes().is_empty()
#endregion

#region Theme Methods
func set_font_size(value: int) -> void:
	add_theme_font_size_override(&"font_size", value)


func set_font_color(color: Color) -> void:
	add_theme_color_override(&"font_color", color)


func set_font_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_color", Shade.get_color(shade_type, shade_index, reversed))


func set_font_placeholder_color(color: Color) -> void:
	add_theme_color_override(&"font_placeholder_color", color)


func set_font_placeholder_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"font_placeholder_color", Shade.get_color(shade_type, shade_index, reversed))


func set_font_caret_color(color: Color) -> void:
	add_theme_color_override(&"caret_color", color)


func set_font_caret_shade(shade_type: Shade.Type, shade_index: int, reversed: bool = false) -> void:
	add_theme_color_override(&"caret_color", Shade.get_color(shade_type, shade_index, reversed))


func set_focus_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"focus", style)


func set_normal_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"normal", style)


func set_read_only_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"read_only", style)


func get_normal_style() -> StyleBox:
	return get_theme_stylebox(&"normal")
#endregion

#region Private Methods
func _ready() -> void:
	_set_max_length(max_length)
#endregion

#region Signal Callbacks
func _on_text_changed() -> void:
	if max_length > 0:
		if text.strip_edges().strip_escapes().length() > max_length:
			text = _previous_text
			set_caret_line(_caret_line)
			set_caret_column(_caret_column)
		
		_previous_text = text
		_caret_line = get_caret_line()
		_caret_column = get_caret_column()
#endregion

#region Setter Methods
func _set_max_length(arg: int) -> void:
	max_length = maxi(0, arg)
	UtilsSignal.connect_safe_if(text_changed, _on_text_changed, max_length > 0)
#endregion
