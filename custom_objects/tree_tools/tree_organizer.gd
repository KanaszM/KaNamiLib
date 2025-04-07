"""
# Version 1.0.0 (03-Apr-2025):
	- Reviewed release;
"""

#@tool
class_name TreeOrganizer
#extends 

#region Enums
enum SorterType {ASC, DESC}
enum FilterType {TEXT, NUMERIC, BOOL, LENGTH, LIST}
enum ValueMode {CELL, TOOLTIP, CELL_AND_TOOLTIP}
#endregion

#region Constants
const GET_DISTINCT_CELL_AND_TOOLTIP_VALUE_SEPARATOR: String = "|||"
#endregion

#region Static Public Methods
static func apply_grouping(
	source: Object, col_idx: int, recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> void:
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			Logger.error(apply_grouping, "The root TreeItem is null!")
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


static func apply_sorting(
	source: Object, sorters: Array[Sorter], recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> void:
		if sorters.is_empty():
			Logger.error(apply_sorting, "No sorters were provided!")
			return
		
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			Logger.error(apply_sorting, "The root TreeItem is null!")
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
		
		for sorter: Sorter in sorters:
			var sorter_is_asc: bool = sorter.type == SorterType.ASC
			
			match sorter.mode:
				Sorter.Mode.TEXT:
					row_items.sort_custom(func(item_row_1: TreeItem, item_row_2: TreeItem) -> bool:
						var item_row_1_value: String = _get_value_by_mode(item_row_1, sorter.col_idx, value_mode)
						var item_row_2_value: String = _get_value_by_mode(item_row_2, sorter.col_idx, value_mode)
						
						return (
							(item_row_1_value < item_row_2_value) if sorter_is_asc
							else (item_row_1_value > item_row_2_value)
							)
					)
				
				Sorter.Mode.NUMERIC:
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


static func apply_filters(
	source: Object,
	filters: Array[Filter],
	strict: bool = false,
	recursive: bool = true,
	value_mode: ValueMode = ValueMode.CELL
	) -> void:
		if filters.is_empty():
			Logger.error(apply_filters, "No filters were provided!")
			return
		
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			Logger.error(apply_filters, "The root TreeItem is null!")
			return
		
		_sort_elements(filters)
		
		var visible_row_items_count: int = 0
		
		for item_row: TreeItem in item_root.get_children():
			if item_row.has_meta(TreeFooter.META):
				continue
			
			var passed_filters_count: int = 0
			
			for filter: Filter in filters:
				var filter_passed: bool
				var value: String = _get_value_by_mode(item_row, filter.col_idx, value_mode)
				
				if filter is TextFilter:
					var text_filter := filter as TextFilter
					
					if text_filter.criteria.is_empty():
						filter_passed = true
					
					else:
						if not text_filter.case_sensitive:
							value = value.to_lower()
						
						match text_filter.mode:
							TextFilter.Mode.EQUALS:
								filter_passed = (
									(value != text_filter.criteria) if filter.negative
									else (value == text_filter.criteria)
									)
							
							TextFilter.Mode.CONTAINS:
								filter_passed = (
									(not text_filter.criteria in value) if filter.negative
									else (text_filter.criteria in value)
									)
							
							TextFilter.Mode.BEGINS_WITH:
								filter_passed = (
									(not value.begins_with(text_filter.criteria)) if filter.negative
									else value.begins_with(text_filter.criteria)
									)
							
							TextFilter.Mode.ENDS_WITH:
								filter_passed = (
									(not value.ends_with(text_filter.criteria)) if filter.negative
									else value.ends_with(text_filter.criteria)
									)
				
				elif filter is NumFilter:
					var num_filter := filter as NumFilter
					var num_cell_value: float = float(value)
					
					match num_filter.mode:
						NumFilter.Mode.EQUALS:
							filter_passed = (
								(num_cell_value != num_filter.criteria) if filter.negative
								else (num_cell_value == num_filter.criteria)
								)
						
						NumFilter.Mode.GREATER_THAN:
							filter_passed = (
								(num_cell_value < num_filter.criteria) if filter.negative
								else (num_cell_value > num_filter.criteria)
								)
						
						NumFilter.Mode.GREATER_THAN_OR_EQUAL_TO:
							filter_passed = (
								(num_cell_value <= num_filter.criteria) if filter.negative
								else (num_cell_value >= num_filter.criteria)
								)
						
						NumFilter.Mode.LOWER_THAN:
							filter_passed = (
								(num_cell_value > num_filter.criteria) if filter.negative
								else (num_cell_value < num_filter.criteria)
								)
						
						NumFilter.Mode.LOWER_THAN_OR_EQUAL_TO:
							filter_passed = (
								(num_cell_value >= num_filter.criteria) if filter.negative
								else (num_cell_value <= num_filter.criteria)
								)
				
				elif filter is BoolFilter:
					var bool_filter := filter as BoolFilter
					
					filter_passed = value == bool_filter.get_text()
				
				elif filter is LengthFilter:
					var length_filter := filter as LengthFilter
					var length_cell_value: int = value.length()
					
					filter_passed = (
						(length_cell_value != length_filter.criteria) if filter.negative
						else (length_cell_value == length_filter.criteria)
						)
				
				elif filter is ListFilter:
					var list_filter := filter as ListFilter
					
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


static func set_visibility(source: Object, state: bool, recursive: bool = true) -> void:
	var item_root: TreeItem = _get_root_item_from_source(source)
	
	if item_root == null:
		Logger.error(set_visibility, "The root TreeItem is null!")
		return
	
	for item_row: TreeItem in item_root.get_children():
		item_row.visible = state
		
		if item_row.get_child_count() > 0 and recursive:
			set_visibility(item_row, state, true)


static func get_distinct(
	source: Object, col_idx: int, recursive: bool = true, value_mode: ValueMode = ValueMode.CELL
	) -> Array:
		var results: Collection = Collection.new()
		var item_root: TreeItem = _get_root_item_from_source(source)
		
		if item_root == null:
			Logger.error(get_distinct, "The root TreeItem is null!")
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
				return TreeOrganizer._get_value_by_mode(item, col_idx, value_mode)))
			)
		
		if max_length > 0:
			item_texts = "%s%s" % [item_texts.left(max_length - ellipsis.length()), ellipsis]
		
		return item_texts
#endregion

#region Static Private Methods
static func _get_root_item_from_source(source: Object) -> TreeItem:
	if source is TreeItem:
		return source as TreeItem
	
	elif source is Tree:
		return (source as Tree).get_root()
	
	else:
		Logger.error(
			_get_root_item_from_source, "Invalid source: '%s'! Must be either a TreeItem or Tree object." % source
			)
		return null


static func _get_value_by_mode(
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


static func _sort_elements(elements: Array) -> void:
	elements.sort_custom(
		func(
			element_1: _TreeOrganizerElement,
			element_2: _TreeOrganizerElement
			) -> bool: return element_1.col_idx < element_2.col_idx
		)
#endregion

#region SubClasses
class _TreeOrganizerElement extends RefCounted:
	#region Public Variables
	var col_idx: int = -1: set = set_col_idx
	#endregion
	
	#region Setget Methods
	func set_col_idx(arg: int = col_idx) -> TreeOrganizer._TreeOrganizerElement:
		if arg < 0:
			arg = 0
		
		col_idx = arg
		
		return self
	#endregion


class Sorter extends TreeOrganizer._TreeOrganizerElement:
	#region Enums
	enum Mode {TEXT, NUMERIC}
	#endregion
	
	#region Public Variables
	var type: TreeOrganizer.SorterType = TreeOrganizer.SorterType.ASC
	var mode: Mode = Mode.TEXT
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		col_idx = column_index
	#endregion
	
	#region Public Methods
	func is_asc() -> bool:
		return type == SorterType.ASC
	
	
	func asc_text() -> TreeOrganizer.Sorter:
		type = SorterType.ASC
		mode = Mode.TEXT
		
		return self
	
	
	func desc_text() -> TreeOrganizer.Sorter:
		type = SorterType.DESC
		mode = Mode.TEXT
		
		return self
	
	
	func asc_numeric() -> TreeOrganizer.Sorter:
		type = SorterType.ASC
		mode = Mode.NUMERIC
		
		return self
	
	
	func desc_numeric() -> TreeOrganizer.Sorter:
		type = SorterType.DESC
		mode = Mode.NUMERIC
		
		return self
	
	
	func reverse_type() -> TreeOrganizer.Sorter:
		type = SorterType.DESC if type == SorterType.ASC else SorterType.ASC
		
		return self
	#endregion


class Filter extends TreeOrganizer._TreeOrganizerElement:
	#region Public Variables
	var type: TreeOrganizer.FilterType = TreeOrganizer.FilterType.TEXT
	var negative: bool
	#endregion
	
	#region Virtual Methods
	func _init(filter_type: TreeOrganizer.FilterType, column_index: int) -> void:
		type = filter_type
		col_idx = column_index
	#endregion
	
	#region Public Methods
	func set_negative(state: bool = true) -> TreeOrganizer.Filter:
		negative = state
		
		return self
	#endregion
	
	#region Private Methods
	func _to_string_formatter(sub_class_name: String, mode: String, criteria: Variant) -> String:
		return "%s[%d] %s%s '%s'>" % [sub_class_name, col_idx, "not " if negative else "", mode, criteria]
	#endregion


class TextFilter extends TreeOrganizer.Filter:
	#region Enums
	enum Mode {EQUALS, CONTAINS, BEGINS_WITH, ENDS_WITH}
	#endregion
	
	#region Public Variables
	var mode: Mode = Mode.EQUALS
	var criteria: String
	var case_sensitive: bool
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		super._init(FilterType.TEXT, column_index)
	
	
	func _to_string() -> String:
		return _to_string_formatter("TextFilter", UtilsDictionary.enum_to_str(Mode, mode, true), criteria)
	#endregion
	
	#region Public Methods
	func update(
		new_mode: Mode, criteria_value: String, is_negative: bool, is_case_sensitive: bool
		) -> TreeOrganizer.TextFilter:
			mode = new_mode
			criteria = criteria_value
			negative = is_negative
			case_sensitive = is_case_sensitive
			
			if not is_case_sensitive:
				criteria = criteria.to_lower()
			
			return self
	
	
	func equals(
		criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
		) -> TreeOrganizer.TextFilter:
			return update(Mode.EQUALS, criteria_value, is_negative, is_case_sensitive)
	
	
	func contains(
		criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
		) -> TreeOrganizer.TextFilter:
			return update(Mode.CONTAINS, criteria_value, is_negative, is_case_sensitive)
	
	
	func begins_with(
		criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
		) -> TreeOrganizer.TextFilter:
			return update(Mode.BEGINS_WITH, criteria_value, is_negative, is_case_sensitive)
	
	
	func ends_with(
		criteria_value: String, is_negative: bool = false, is_case_sensitive: bool = false
		) -> TreeOrganizer.TextFilter:
			return update(Mode.ENDS_WITH, criteria_value, is_negative, is_case_sensitive)
	
	
	func set_case_sensitive(state: bool = true) -> TreeOrganizer.TextFilter:
		case_sensitive = state
		return self
	#endregion


class NumFilter extends TreeOrganizer.Filter:
	#region Enums
	enum Mode {EQUALS, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO, LOWER_THAN, LOWER_THAN_OR_EQUAL_TO}
	#endregion
	
	#region Public Variables
	var mode: Mode = Mode.EQUALS
	var criteria: float
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		super._init(FilterType.NUMERIC, column_index)
	
	
	func _to_string() -> String:
		return _to_string_formatter("NumFilter", UtilsDictionary.enum_to_str(Mode, mode, true), criteria)
	#endregion
	
	#region Public Methods
	func update(new_mode: Mode, criteria_value: float, is_negative: bool) -> TreeOrganizer.NumFilter:
		mode = new_mode
		criteria = criteria_value
		negative = is_negative
		
		return self
	
	
	func equals(criteria_value: float, is_negative: bool = false) -> TreeOrganizer.NumFilter:
		return update(Mode.EQUALS, criteria_value, is_negative)
	
	
	func greater_than(criteria_value: float, is_negative: bool = false) -> TreeOrganizer.NumFilter:
		return update(Mode.GREATER_THAN, criteria_value, is_negative)
	
	
	func greater_than_or_equals_to(criteria_value: float, is_negative: bool = false) -> TreeOrganizer.NumFilter:
		return update(Mode.GREATER_THAN_OR_EQUAL_TO, criteria_value, is_negative)
	
	
	func lower_than(criteria_value: float, is_negative: bool = false) -> TreeOrganizer.NumFilter:
		return update(Mode.LOWER_THAN, criteria_value, is_negative)
	
	
	func lower_than_or_equals_to(criteria_value: float, is_negative: bool = false) -> TreeOrganizer.NumFilter:
		return update(Mode.LOWER_THAN_OR_EQUAL_TO, criteria_value, is_negative)
	#endregion


class BoolFilter extends TreeOrganizer.Filter:
	#region Public Variables
	var criteria: bool
	var text_true: String = "true": set = _set_text_true
	var text_false: String = "false": set = _set_text_false
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		super._init(FilterType.BOOL, column_index)
	
	
	func _to_string() -> String:
		return _to_string_formatter("BoolFilter", "=", get_text())
	#endregion
	
	#region Public Methods
	func update(criteria_value: bool) -> TreeOrganizer.BoolFilter:
		criteria = criteria_value
		
		return self
	
	
	func equals(criteria_value: bool) -> TreeOrganizer.BoolFilter:
		return update(criteria_value)
	
	
	func get_text() -> String:
		return text_true if criteria else text_false
	#endregion
	
	#region Setter Methods
	func _set_text_true(arg: String) -> void:
		text_true = arg.strip_edges().strip_escapes()
	
	
	func _set_text_false(arg: String) -> void:
		text_false = arg.strip_edges().strip_escapes()
	#endregion


class LengthFilter extends TreeOrganizer.Filter:
	#region Public Variables
	var criteria: int
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		super._init(FilterType.LENGTH, column_index)
	
	
	func _to_string() -> String:
		return _to_string_formatter("LengthFilter", "=", criteria)
	#endregion
	
	#region Public Methods
	func update(criteria_value: int, is_negative: bool) -> TreeOrganizer.LengthFilter:
		criteria = criteria_value
		negative = is_negative
		
		return self
	
	
	func equals(criteria_value: int, is_negative: bool = false) -> TreeOrganizer.LengthFilter:
		return update(criteria_value, is_negative)
	#endregion


class ListFilter extends TreeOrganizer.Filter:
	#region Public Variables
	var criteria: Array
	var case_sensitive: bool
	#endregion
	
	#region Virtual Methods
	func _init(column_index: int) -> void:
		super._init(FilterType.LENGTH, column_index)
	
	
	func _to_string() -> String:
		return _to_string_formatter("ListFilter", "=", criteria)
	#endregion
	
	#region Public Methods
	func update(criteria_value: Array, is_negative: bool, is_case_sensitive: bool) -> TreeOrganizer.ListFilter:
		criteria = criteria_value.map(
			func(entry: Variant) -> String: return str(entry) if is_case_sensitive else str(entry).to_lower()
			)
		negative = is_negative
		case_sensitive = is_case_sensitive
		
		return self
	
	
	func is_one_of(
		criteria_value: Array, is_negative: bool = false, is_case_sensitive: bool = false
		) -> TreeOrganizer.ListFilter:
			return update(criteria_value, is_negative, is_case_sensitive)
	
	
	func set_case_sensitive(state: bool = true) -> TreeOrganizer.ListFilter:
		case_sensitive = state
		return self
	#endregion
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
