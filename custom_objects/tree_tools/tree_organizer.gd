class_name TreeOrganizer

#region Enums
enum ValueMode {CELL, TOOLTIP, CELL_AND_TOOLTIP}
#endregion

#region Constants
const GET_DISTINCT_CELL_AND_TOOLTIP_VALUE_SEPARATOR: String = "|||"
#endregion

#region Private Variables
var _current_result: Result
#endregion

#region Constructor
func _init() -> void:
	_current_result = Result.new()
#endregion

#region Public Methods
func get_current_result() -> Result:
	return _current_result


func apply_grouping(
	source: Object, col_idx: int, recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> void:
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		_current_result.clear()
		
		if item_root == null:
			_current_result.error("The root TreeItem is null!", apply_grouping)
			return
		
		var grouped_rows: Dictionary[String, Array]
		var row_items: Array[TreeItem] = item_root.get_children()
		var row_items_with_children: Array[TreeItem]
		
		for item_row: TreeItem in row_items:
			if item_row.get_child_count() > 0:
				row_items_with_children.append(item_row)
			
			item_root.remove_child(item_row)
		
		for item_row: TreeItem in row_items:
			var value: String = _get_value_by_mode(item_row, col_idx, value_mode)
			
			if not value in grouped_rows:
				grouped_rows[value] = []
			
			grouped_rows[value].append(item_row)
		
		var tree: Tree = item_root.get_tree()
		
		for group_value: String in grouped_rows:
			var grouped_row_items := Array(
				grouped_rows[group_value], TYPE_OBJECT, &"TreeItem", TreeItem
				) as Array[TreeItem]
			var item_group: TreeItem = tree.create_item(item_root)
			
			item_group.set_text(0, group_value)
			item_group.set_expand_right(0, true)
			
			for grouped_row_item: TreeItem in grouped_row_items:
				item_group.add_child(grouped_row_item)
		
		if recursive and not row_items_with_children.is_empty():
			for item_row: TreeItem in row_items_with_children:
				apply_grouping(item_row, col_idx, true, value_mode)
		
		_current_result.success()


func apply_sorting(
	source: Object, sorters: Array[TreeOrganizerSorter], recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> void:
		_current_result.clear()
		
		if sorters.is_empty():
			_current_result.error("No sorters were provided!", apply_sorting)
			return
		
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			_current_result.error("The root TreeItem is null!", apply_sorting)
			return
		
		_sort_elements(sorters)
		
		var row_items: Array[TreeItem] = item_root.get_children()
		var row_items_with_children: Array[TreeItem]
		
		var item_footer: TreeItem
		
		for item_row: TreeItem in row_items:
			if item_row.get_child_count() > 0:
				row_items_with_children.append(item_row)
			
			if item_row.has_meta(TreeFooter.META):
				item_footer = item_row
			
			item_root.remove_child(item_row)
		
		for sorter: TreeOrganizerSorter in sorters:
			var sorter_is_asc: bool = sorter.type == TreeOrganizerSorter.Type.ASC
			
			match sorter.mode:
				TreeOrganizerSorter.Mode.TEXT:
					row_items.sort_custom(func(item_row_1: TreeItem, item_row_2: TreeItem) -> bool:
						var item_row_1_value: String = _get_value_by_mode(item_row_1, sorter.col_idx, value_mode)
						var item_row_2_value: String = _get_value_by_mode(item_row_2, sorter.col_idx, value_mode)
						
						return (
							(item_row_1_value < item_row_2_value) if sorter_is_asc
							else (item_row_1_value > item_row_2_value)
							)
					)
				
				TreeOrganizerSorter.Mode.NUMERIC:
					row_items.sort_custom(func(item_row_1: TreeItem, item_row_2: TreeItem) -> bool:
						var item_row_1_value: float = float(_get_value_by_mode(item_row_1, sorter.col_idx, value_mode))
						var item_row_2_value: float = float(_get_value_by_mode(item_row_2, sorter.col_idx, value_mode))
						
						return (
							(item_row_1_value < item_row_2_value) if sorter_is_asc
							else (item_row_1_value > item_row_2_value)
							)
					)
		
		for item_row: TreeItem in row_items:
			if item_row.has_meta(TreeFooter.META):
				continue
			
			item_root.add_child(item_row)
		
		if item_footer != null:
			item_root.add_child(item_footer)
		
		if recursive and not row_items_with_children.is_empty():
			for item_row: TreeItem in row_items_with_children:
				apply_sorting(item_row, sorters, true, value_mode)
		
		_current_result.success()


func apply_filters(
	source: Object,
	filters: Array[TreeOrganizerFilter],
	strict: bool = false,
	recursive: bool = true,
	value_mode: ValueMode = ValueMode.CELL
	) -> void:
		_current_result.clear()
		
		if filters.is_empty():
			_current_result.error("No filters were provided!", apply_filters)
			return
		
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			_current_result.error("The root TreeItem is null!", apply_filters)
			return
		
		_sort_elements(filters)
		
		var visible_row_items_count: int = 0
		
		for item_row: TreeItem in item_root.get_children():
			if item_row.has_meta(TreeFooter.META):
				continue
			
			var passed_filters_count: int = 0
			
			for filter: TreeOrganizerFilter in filters:
				var filter_passed: bool
				var value: String = _get_value_by_mode(item_row, filter.col_idx, value_mode)
				
				if filter is TreeOrganizerTextFilter:
					var text_filter := filter as TreeOrganizerTextFilter
					
					if text_filter.criteria.is_empty():
						filter_passed = true
					
					else:
						if not text_filter.case_sensitive:
							value = value.to_lower()
						
						match text_filter.mode:
							TreeOrganizerTextFilter.Mode.EQUALS:
								filter_passed = (
									(value != text_filter.criteria) if filter.negative
									else (value == text_filter.criteria)
									)
							
							TreeOrganizerTextFilter.Mode.CONTAINS:
								filter_passed = (
									(not text_filter.criteria in value) if filter.negative
									else (text_filter.criteria in value)
									)
							
							TreeOrganizerTextFilter.Mode.BEGINS_WITH:
								filter_passed = (
									(not value.begins_with(text_filter.criteria)) if filter.negative
									else value.begins_with(text_filter.criteria)
									)
							
							TreeOrganizerTextFilter.Mode.ENDS_WITH:
								filter_passed = (
									(not value.ends_with(text_filter.criteria)) if filter.negative
									else value.ends_with(text_filter.criteria)
									)
				
				elif filter is TreeOrganizerNumericFilter:
					var num_filter := filter as TreeOrganizerNumericFilter
					var num_cell_value: float = float(value)
					
					match num_filter.mode:
						TreeOrganizerNumericFilter.Mode.EQUALS:
							filter_passed = (
								(num_cell_value != num_filter.criteria) if filter.negative
								else (num_cell_value == num_filter.criteria)
								)
						
						TreeOrganizerNumericFilter.Mode.GREATER_THAN:
							filter_passed = (
								(num_cell_value < num_filter.criteria) if filter.negative
								else (num_cell_value > num_filter.criteria)
								)
						
						TreeOrganizerNumericFilter.Mode.GREATER_THAN_OR_EQUAL_TO:
							filter_passed = (
								(num_cell_value <= num_filter.criteria) if filter.negative
								else (num_cell_value >= num_filter.criteria)
								)
						
						TreeOrganizerNumericFilter.Mode.LOWER_THAN:
							filter_passed = (
								(num_cell_value > num_filter.criteria) if filter.negative
								else (num_cell_value < num_filter.criteria)
								)
						
						TreeOrganizerNumericFilter.Mode.LOWER_THAN_OR_EQUAL_TO:
							filter_passed = (
								(num_cell_value >= num_filter.criteria) if filter.negative
								else (num_cell_value <= num_filter.criteria)
								)
				
				elif filter is TreeOrganizerBoolFilter:
					var bool_filter := filter as TreeOrganizerBoolFilter
					
					filter_passed = value == bool_filter.get_text()
				
				elif filter is TreeOrganizerLengthFilter:
					var length_filter := filter as TreeOrganizerLengthFilter
					var length_cell_value: int = value.length()
					
					filter_passed = (
						(length_cell_value != length_filter.criteria) if filter.negative
						else (length_cell_value == length_filter.criteria)
						)
				
				elif filter is TreeOrganizerListFilter:
					var list_filter := filter as TreeOrganizerListFilter
					
					if not list_filter.case_sensitive:
						value = value.to_lower()
					
					filter_passed = (
						(value not in list_filter.criteria) if filter.negative else (value in list_filter.criteria)
						)
				
				passed_filters_count += int(filter_passed)
				
				if not strict and filter_passed:
					break
			
			var item_row_is_visible: bool = (
				(passed_filters_count == filters.size()) if strict else (passed_filters_count != 0)
				)
			
			item_row.visible = item_row_is_visible
			visible_row_items_count += int(item_row_is_visible)
			
			if item_row.get_child_count() > 0 and recursive:
				apply_filters(item_row, filters, strict, true, value_mode)
		
		if recursive and visible_row_items_count > 0:
			item_root.visible = true
		
		_current_result.success()


func set_visibility(source: Object, state: bool, recursive: bool = true) -> void:
	var item_root: TreeItem = _get_root_item_from_source(source)
	
	_current_result.clear()
	
	if item_root == null:
		_current_result.error("The root TreeItem is null!", set_visibility)
		return
	
	for item_row: TreeItem in item_root.get_children():
		item_row.visible = state
		
		if item_row.get_child_count() > 0 and recursive:
			set_visibility(item_row, state, true)
	
	_current_result.success()


func get_distinct(
	source: Object, col_idx: int, recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> Array:
		var results: Collection = Collection.new()
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		_current_result.clear()
		
		if item_root == null:
			_current_result.error("The root TreeItem is null!", get_distinct)
			return []
		
		for item_row: TreeItem in item_root.get_children():
			var value: String = _get_value_by_mode(
				item_row, col_idx, value_mode, GET_DISTINCT_CELL_AND_TOOLTIP_VALUE_SEPARATOR
				)
			
			match value_mode:
				ValueMode.CELL, ValueMode.TOOLTIP:
					results.add(value)
				
				ValueMode.CELL_AND_TOOLTIP:
					for sub_value: String in value.split(GET_DISTINCT_CELL_AND_TOOLTIP_VALUE_SEPARATOR):
						results.add(sub_value)
			
			if item_row.get_child_count() > 0 and recursive:
				get_distinct(item_row, col_idx, true, value_mode)
		
		_current_result.success()
		
		return results.items()


func str_item(
	item: TreeItem,
	max_length: int = 0,
	value_mode: ValueMode = ValueMode.CELL,
	sepparator: String = "|",
	ellipsis: String = "...",
	) -> String:
		var item_texts: String = sepparator.join(
			PackedStringArray(range(item.get_tree().columns).map(func(col_idx: int) -> String:
				return _get_value_by_mode(item, col_idx, value_mode)))
			)
		
		if max_length > 0:
			item_texts = "%s%s" % [item_texts.left(max_length - ellipsis.length()), ellipsis]
		
		return item_texts
#endregion

#region Private Methods
func _get_root_item_from_source(source: Object) -> TreeItem:
	if source is TreeItem:
		return source as TreeItem
	
	elif source is Tree:
		return (source as Tree).get_root()
	
	return null


func _get_value_by_mode(
	item_row: TreeItem, col_idx: int, value_mode: ValueMode, cell_and_tooltip_separator: String = " "
	) -> String:
		match value_mode:
			ValueMode.CELL:
				return item_row.get_text(col_idx)
			
			ValueMode.TOOLTIP:
				return item_row.get_tooltip_text(col_idx)
			
			ValueMode.CELL_AND_TOOLTIP:
				return (
					"%s%s%s"
					% [item_row.get_text(col_idx), cell_and_tooltip_separator, item_row.get_tooltip_text(col_idx)]
					)
			
			_:
				return ""


func _sort_elements(elements: Array) -> void:
	elements.sort_custom(
		func(
			element_1: TreeOrganizerElement,
			element_2: TreeOrganizerElement
			) -> bool: return element_1.col_idx < element_2.col_idx
		)
#endregion
