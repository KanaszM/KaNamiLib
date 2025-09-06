class_name TreeFooter

#region Constants
const META: StringName = &"TREE_FOOTER"
const META_IS_NUMERIC: StringName = &"TREE_FOOTER_IS_NUMERIC"
const META_CONTEXT_MENU: StringName = &"TREE_FOOTER_CONTEXT_MENU"

const DEFAULT_CELL_TOOLTIP: String = "Double click on this cell to select and apply one of the calculation options."
#endregion

#region Public Variables
var tree: ExtendedTree
var footer_columns: Array[TreeFooterFooterColumn]

var selector: TreeSelector
var cell_color: Color = Color.TRANSPARENT
var cell_tooltip: String = DEFAULT_CELL_TOOLTIP

var roots_with_footers: Dictionary[TreeItem, TreeItem]
#endregion

#region Private Variables
var _applied_operations: Array[TreeFooterAppliedOperation] = []
#endregion

#region Constructor
func _init(tree_reference: ExtendedTree, footer_columns_reference: Array[TreeFooterFooterColumn]) -> void:
	tree = tree_reference
	footer_columns = footer_columns_reference
#endregion

#region Public Methods
func set_enabled(state: bool) -> void:
	if tree == null:
		Log.error("The provided tree reference is null!", set_enabled)
		return
	
	if footer_columns.is_empty():
		Log.error("No footer columns were provided!", set_enabled)
		return
	
	UtilsSignal.connect_safe_if(tree.item_activated, _on_tree_item_activated, state)
	
	if state:
		for item_root: TreeItem in tree.get_all_rows(false, true):
			if not item_root in roots_with_footers:
				var item_footer: TreeItem = tree.create_item(item_root)
				
				item_footer.set_meta(META, true)
				
				for footer_column: TreeFooterFooterColumn in footer_columns:
					item_footer.set_custom_bg_color(footer_column.idx, cell_color, true)
					item_footer.set_tooltip_text(footer_column.idx, cell_tooltip)
					item_footer.set_text_alignment(footer_column.idx, footer_column.alignment)
					
					if footer_column.is_numeric:
						item_footer.set_metadata(footer_column.idx, META_IS_NUMERIC)
				
				roots_with_footers[item_root] = item_footer
	
	else:
		for item_root: TreeItem in roots_with_footers:
			item_root.remove_child(roots_with_footers[item_root])


func reapply_operations() -> void:
	for applied_operation: TreeFooterAppliedOperation in _applied_operations:
		applied_operation.call_operation()
#endregion

#region Private Methods
func _count(item_footer: TreeItem, col_idx: int, selection_only: bool, append_operation: bool = true) -> void:
	var value: int = (
		selector.selected_rows.size() if selector != null and selection_only
		else tree.get_all_non_empty_rows_by_col(col_idx, true).size()
		)
	
	item_footer.set_text(col_idx, "%s %d" % ["✓" if selection_only else "＃", value])
	item_footer.set_tooltip_text(col_idx, str(value))
	
	if append_operation:
		_applied_operations.append(TreeFooterAppliedOperation.new(item_footer, col_idx, _count, selection_only))


func _sum(item_footer: TreeItem, col_idx: int, selection_only: bool, append_operation: bool = true) -> void:
	var value: float = 0.0
	
	for item_row: TreeItem in (
		selector.selected_rows if selector != null and selection_only else tree.get_all_rows(true)
		):
			value += float(item_row.get_text(col_idx))
	
	item_footer.set_text(col_idx, "∑ %s" % value)
	item_footer.set_tooltip_text(col_idx, str(value))
	
	if append_operation:
		_applied_operations.append(TreeFooterAppliedOperation.new(item_footer, col_idx, _sum, selection_only))


func _average(item_footer: TreeItem, col_idx: int, selection_only: bool, append_operation: bool = true) -> void:
	var values: PackedFloat64Array
	
	for item_row: TreeItem in (
		selector.selected_rows if selector != null and selection_only else tree.get_all_rows(true)
		):
			values.append(float(item_row.get_text(col_idx)))
	
	var value: String = str(UtilsNumeric.float_get_average_64(values)).pad_decimals(3)
	
	item_footer.set_text(col_idx, "⨏ %s" % value)
	item_footer.set_tooltip_text(col_idx, value)
	
	if append_operation:
		_applied_operations.append(TreeFooterAppliedOperation.new(item_footer, col_idx, _average, selection_only))


func _clear(item_footer: TreeItem, col_idx: int) -> void:
	item_footer.set_text(col_idx, "")
	item_footer.set_tooltip_text(col_idx, cell_tooltip)
	
	for applied_operation_idx: int in _applied_operations.size() - 1:
		var applied_operation: TreeFooterAppliedOperation = _applied_operations[applied_operation_idx]
		
		if applied_operation.item == item_footer and applied_operation.index == col_idx:
			_applied_operations.remove_at(applied_operation_idx)


func _clear_all(item_footer: TreeItem) -> void:
	for footer_column: TreeFooterFooterColumn in footer_columns:
		item_footer.set_text(footer_column.idx, "")
		item_footer.set_tooltip_text(footer_column.idx, cell_tooltip)
	
	_applied_operations.clear()
#endregion

#region Signal Callbacks
func _on_tree_item_activated() -> void:
	var item_row_selected: TreeItem = tree.get_selected()
	
	if item_row_selected == null or not item_row_selected.has_meta(META):
		return
	
	var col_idx_selected: int = tree.get_selected_column()
	var footer_is_numeric: bool = item_row_selected.get_metadata(col_idx_selected) == META_IS_NUMERIC
	var footer_menu_items: Array[ExtendedPopupMenu.Item] = [
		ExtendedPopupMenu.Divider.new("All Rows"),
		ExtendedPopupMenu.Item.new("Count", _count.bind(item_row_selected, col_idx_selected, false)),
	]
	var footer_menu_clear_items: Array[ExtendedPopupMenu.Item]
	
	if footer_is_numeric:
		footer_menu_items.append(
			ExtendedPopupMenu.Item.new("Sum", _sum.bind(item_row_selected, col_idx_selected, false))
			)
		footer_menu_items.append(
			ExtendedPopupMenu.Item.new("Avgerage", _average.bind(item_row_selected, col_idx_selected, false))
			)
	
	if selector != null and selector.rows_are_selected():
		footer_menu_items.append(
			ExtendedPopupMenu.Divider.new("Selection")
			)
		footer_menu_items.append(
			ExtendedPopupMenu.Item.new("Count", _count.bind(item_row_selected, col_idx_selected, true))
			)
		
		if footer_is_numeric:
			footer_menu_items.append(
				ExtendedPopupMenu.Item.new("Sum", _sum.bind(item_row_selected, col_idx_selected, true))
				)
			footer_menu_items.append(
				ExtendedPopupMenu.Item.new("Avgerage", _average.bind(item_row_selected, col_idx_selected, true))
				)
	
	if not item_row_selected.get_text(col_idx_selected).is_empty():
		footer_menu_clear_items.append(
			ExtendedPopupMenu.Item.new("Clear", _clear.bind(item_row_selected, col_idx_selected))
			)
	
	if not _applied_operations.is_empty():
		footer_menu_clear_items.append(
			ExtendedPopupMenu.Item.new("Clear All", _clear_all.bind(item_row_selected))
			)
	
	if not footer_menu_clear_items.is_empty():
		footer_menu_items.append(
			ExtendedPopupMenu.Divider.new("")
			)
		footer_menu_items.append_array(footer_menu_clear_items)
	
	ExtendedPopupMenu.static_context_menu(META_CONTEXT_MENU, footer_menu_items)
#endregion
