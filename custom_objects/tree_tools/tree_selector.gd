"""
# Version 1.0.0 (03-Apr-2025):
	- Reviewed release;
"""

#@tool
class_name TreeSelector
#extends 

#region Signals
signal changed
#endregion

#region Enums
#endregion

#region Constants
const SELECTION_COLOR_ALPHA: float = 0.5
#endregion

#region Export Variables
#endregion

#region Public Variables
var tree: ExtendedTree

var single_selection: bool
var single_selection_auto_accept: bool

var selection_col_idx: int
var selection_color: Color = Shade.green(2): set = _set_selection_color

var selected_rows: Array[TreeItem]
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(tree_reference: ExtendedTree) -> void:
	tree = tree_reference
	
	_set_selection_color(selection_color)
	
	tree.item_activated.connect(_on_tree_item_activated)
#endregion

#region Public Methods
func get_first_selected_row() -> TreeItem:
	return null if selected_rows.is_empty() else selected_rows[0]


func all_rows_are_selected() -> bool:
	return selected_rows.size() == tree.get_all_rows(true).size()


func row_is_selected(item_row: TreeItem) -> bool:
	return item_row in selected_rows


func rows_are_selected() -> bool:
	return not selected_rows.is_empty()


func set_row_activated(item_row: TreeItem, emit_changed: bool = true) -> void:
	if item_row == null or item_row.get_cell_mode(selection_col_idx) != TreeItem.CELL_MODE_CHECK:
		return
	
	if single_selection:
		set_row_selected_modal(item_row)
		
		if single_selection_auto_accept:
			if emit_changed:
				changed.emit()
			
			return
	
	else:
		toggle_row_selection(item_row)
	
	if emit_changed:
		changed.emit()


func set_row_selected_if_col_value(col_idx: int, value: Variant, mode: bool) -> void:
	for item_row: TreeItem in tree.get_all_rows(true):
		var current_value: String = item_row.get_text(col_idx)
		
		if str(value) == current_value:
			if single_selection:
				if mode:
					set_row_selected_modal(item_row)
				
				else:
					set_row_selected(item_row, false)
			
			else:
				set_row_selected(item_row, mode)


func set_row_selected(item_row: TreeItem, mode: bool) -> void:
	if item_row.get_child_count() > 0:
		return
	
	if item_row.get_cell_mode(selection_col_idx) != TreeItem.CELL_MODE_CHECK:
		return
	
	var active_selection_color: Color = selection_color if mode else Color.TRANSPARENT
	var is_selected: bool = row_is_selected(item_row)
	
	if mode and not is_selected:
		selected_rows.append(item_row)
	
	elif not mode and is_selected:
		selected_rows.erase(item_row)
	
	item_row.set_checked(selection_col_idx, mode)
	
	for col_idx: int in tree.columns:
		item_row.set_custom_bg_color(col_idx, active_selection_color)


func set_row_selected_modal(item_row: TreeItem) -> void:
	var is_selected: bool = row_is_selected(item_row)
	
	if is_selected:
		set_row_selected(item_row, false)
	
	if single_selection_auto_accept or not is_selected:
		for other_item_row: TreeItem in tree.get_all_rows(true):
			set_row_selected(other_item_row, other_item_row == item_row)


func set_all_rows_selection(mode: bool, forced: bool = false, emit_changed: bool = true) -> void:
	if not single_selection or forced:
		for item_row: TreeItem in tree.get_all_rows(true):
			set_row_selected(item_row, mode)
		
		if emit_changed:
			changed.emit()


func toggle_row_selection(item_row: TreeItem) -> void:
	set_row_selected(item_row, not row_is_selected(item_row))
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
func _on_tree_item_activated() -> void:
	set_row_activated(tree.get_selected())
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_selection_color(arg: Color) -> void:
	selection_color = arg
	selection_color.a = SELECTION_COLOR_ALPHA
#endregion

#region Getter Methods
#endregion
