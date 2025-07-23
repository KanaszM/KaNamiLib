@tool
class_name ExtendedTree extends Tree

#region Public Variables
var copy_enabled: bool = true
var copy_row_divider: String = ", "
var copy_column_divider: String = "\n"
#endregion

#region Constructor
func _init() -> void:
	gui_input.connect(_on_gui_input)
#endregion

#region Public Methods
func copy_selected_cell(from_tooltip: bool = false) -> void:
	var _item_selected: TreeItem = get_selected()
	
	if _item_selected == null:
		return
	
	var column_selected: int = get_selected_column()
	
	if column_selected < 0:
		return
	
	var item_text: String = (
		_item_selected.get_tooltip_text(column_selected) if from_tooltip else _item_selected.get_text(column_selected)
		)
	
	if item_text.is_empty():
		return
	
	DisplayServer.clipboard_set(item_text)


func copy_selected_cell_row(from_tooltip: bool = false) -> void:
	var _item_selected: TreeItem = get_selected()
	
	if _item_selected == null:
		return
	
	var item_texts: PackedStringArray
	
	for col_idx: int in columns:
		var item_text: String = (
			_item_selected.get_tooltip_text(col_idx) if from_tooltip else _item_selected.get_text(col_idx)
			)
		
		if item_text.is_empty():
			continue
		
		item_texts.append(item_text)
	
	if item_texts.is_empty():
		return
	
	DisplayServer.clipboard_set(copy_row_divider.join(item_texts))


func copy_selected_cell_column(from_tooltip: bool = false) -> void:
	var column_selected: int = get_selected_column()
	
	if column_selected < 0:
		return
	
	var item_texts: PackedStringArray
	
	for item_row: TreeItem in get_all_rows(true):
		var item_text: String = (
			item_row.get_tooltip_text(column_selected) if from_tooltip else item_row.get_text(column_selected)
		)
		
		if item_text.is_empty():
			continue
		
		item_texts.append(item_text)
	
	if item_texts.is_empty():
		return
	
	DisplayServer.clipboard_set(copy_column_divider.join(item_texts))


func get_all_rows(visible_only: bool = false, roots_only: bool = false) -> Array[TreeItem]:
	var item_root: TreeItem = get_root()
	
	return ([] as Array[TreeItem]) if item_root == null else get_rows_from_root(item_root, visible_only, roots_only)


func get_all_non_empty_rows_by_col(col_idx: int, visible_only: bool = false) -> Array[TreeItem]:
	return get_all_rows(visible_only).filter(
		func(item_row: TreeItem) -> bool: return not item_row.get_text(col_idx).is_empty()
		)


func get_rows_from_root(item_root: TreeItem, visible_only: bool = false, roots_only: bool = false) -> Array[TreeItem]:
	var items: Array[TreeItem]
	
	if roots_only:
		items.append(item_root)
	
	for item_row: TreeItem in item_root.get_children():
		if item_row.get_child_count() > 0:
			items.append_array(get_rows_from_root(item_row, visible_only, roots_only))
		
		else:
			if (item_row.visible and visible_only) or not visible_only and not roots_only:
				items.append(item_row)
	
	return items


func is_empty() -> bool:
	var root: TreeItem = get_root()
	
	return true if root == null else root.get_child_count() == 0


func clamp_col_idx(col_idx: int) -> int:
	return clampi(col_idx, 0, columns - 1)


func get_total_columns_width() -> int:
	var width: int = 0
	
	for col_idx: int in columns:
		width += get_column_width(col_idx)
	
	return width


func scroll_to_bottom() -> void:
	var v_scroll_bar: VScrollBar = get_v_scroll_bar()
	
	v_scroll_bar.value = v_scroll_bar.max_value


func get_h_scroll_bar() -> HScrollBar:
	for node: Node in get_children(true):
		if node is HScrollBar:
			return node as HScrollBar
	
	return null


func get_v_scroll_bar() -> VScrollBar:
	for node: Node in get_children(true):
		if node is VScrollBar:
			return node as VScrollBar
	
	return null


func get_scroll_bars() -> Array[ScrollBar]:
	return [get_h_scroll_bar(), get_v_scroll_bar()]


func hide_h_scroll_bar() -> void:
	var custom_theme: Theme = Theme.new()
	
	custom_theme.set_stylebox(&"scroll", &"HScrollBar", StyleBoxEmpty.new())
	get_h_scroll_bar().theme = custom_theme


func hide_v_scroll_bar() -> void:
	var custom_theme: Theme = Theme.new()
	
	custom_theme.set_stylebox(&"scroll", &"VScrollBar", StyleBoxEmpty.new())
	get_v_scroll_bar().theme = custom_theme


func hide_scroll_bars() -> void:
	hide_h_scroll_bar()
	hide_v_scroll_bar()


func share_h_scroll_bar(other_tree: ExtendedTree) -> void:
	get_h_scroll_bar().share(other_tree.get_h_scroll_bar())


func share_v_scroll_bar(other_tree: ExtendedTree) -> void:
	get_v_scroll_bar().share(other_tree.get_v_scroll_bar())


func share_scroll_bars(other_tree: ExtendedTree) -> void:
	share_h_scroll_bar(other_tree)
	share_v_scroll_bar(other_tree)
#endregion

#region Theme Methods
func get_font() -> Font:
	return get_theme_font(&"font")


func set_panel_style(style: StyleBox) -> void:
	add_theme_stylebox_override(&"panel", style)


func set_title_styles(style: StyleBox) -> void:
	for style_type: StringName in [
		&"title_button_hover", &"title_button_pressed", &"title_button_normal",
		] as Array[StringName]:
			add_theme_stylebox_override(style_type, style)


func set_selected_styles(style: StyleBox) -> void:
	for style_type: StringName in [&"selected", &"selected_focus"] as Array[StringName]:
		add_theme_stylebox_override(style_type, style)


func set_title_color(color: Color) -> void:
	add_theme_color_override(&"title_button_color", color)


func set_title_shade(shade_type: Shade.Type, shade_index: int, reversed: bool) -> void:
	add_theme_color_override(&"title_button_color", Shade.get_color(shade_type, shade_index, reversed))


func set_font_color(color: Color) -> void:
	add_theme_color_override(&"font_color", color)


func set_font_shade(shade_type: Shade.Type, shade_index: int, reversed: bool) -> void:
	add_theme_color_override(&"font_color", Shade.get_color(shade_type, shade_index, reversed))


func set_font_selected_color(color: Color) -> void:
	add_theme_color_override(&"font_selected_color", color)


func set_font_selected_shade(shade_type: Shade.Type, shade_index: int, reversed: bool) -> void:
	add_theme_color_override(&"font_selected_color", Shade.get_color(shade_type, shade_index, reversed))


func set_separation(value: Vector2i) -> void:
	set_h_separation(value.x)
	set_v_separation(value.y)


func set_h_separation(value: int) -> void:
	add_theme_constant_override(&"h_separation", value)


func set_v_separation(value: int) -> void:
	add_theme_constant_override(&"v_separation", value)


func set_font_size(value: int) -> void:
	add_theme_font_size_override(&"font_size", value)


func set_title_font_size(value: int) -> void:
	add_theme_font_size_override(&"title_button_font_size", value)
#endregion

#region Signal Callbacks
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		
		if key_event.is_pressed():
			match key_event.keycode:
				KEY_C when key_event.ctrl_pressed: copy_selected_cell()
				KEY_C when key_event.shift_pressed: copy_selected_cell_row()
				KEY_C when key_event.alt_pressed: copy_selected_cell_column()
#endregion
