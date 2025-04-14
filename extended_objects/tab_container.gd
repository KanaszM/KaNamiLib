@tool
class_name ExtendedTabContainer
extends TabContainer

#region Signals
signal tab_closed(node: Node)
signal tab_limit_reached
#endregion

#region Enums
enum TabCloseByNameMode {EXACT, BEGINS, ENDS}
#endregion

#region Constants
const METHOD_CLOSE_OVERRIDE: StringName = &"_on_tab_closed"
#endregion

#region Export Variables
@export var tabs_max_count: int = 20
@export var single_tab_processing_enabled: bool = true: set = _set_single_tab_processing_enabled
#endregion

#region Public Variables
var ContextMenu: ExtendedPopupMenu
var TabsMenu: ExtendedPopupMenu
#endregion

#region Private Variables
var _context_menu_items: Array[ExtendedPopupMenu.Item] = [
	ExtendedPopupMenu.Item.new("Close Tab", close_current_tab),
	ExtendedPopupMenu.Item.new("Close Other Tabs", close_other_tabs),
	ExtendedPopupMenu.Item.new("Close All Tabs", close_all_tabs),
]
#endregion

#region OnReady Variables
@onready var TabsBar := get_tab_bar() as TabBar
#endregion

#region Virtual Methods
func _ready() -> void:
	tab_changed.connect(_on_tab_changed)
	TabsBar.select_with_rmb = true
	TabsBar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	
	ContextMenu = ExtendedPopupMenu.new()
	TabsMenu = ExtendedPopupMenu.new()
	
	add_child(ContextMenu, false, Node.INTERNAL_MODE_BACK)
	add_child(TabsMenu, false, Node.INTERNAL_MODE_BACK)
	
	ContextMenu.build_from_items_array(_context_menu_items)
	
	TabsMenu.id_pressed.connect(_on_TabsMenu_id_pressed)
	TabsMenu.about_to_popup.connect(_on_TabsMenu_about_to_popup)
	TabsBar.tab_close_pressed.connect(_on_TabsBar_tab_close_pressed)
	TabsBar.tab_rmb_clicked.connect(_on_TabsBar_tab_rmb_clicked)
	
	for _signal: Signal in [child_entered_tree, child_exiting_tree] as Array[Signal]:
		_signal.connect(_on_child_detection.bind(_signal == child_entered_tree))
	
	_on_child_detection()
	_update_tab_processes()
#endregion

#region Public Methods
func add_tab(
	pack: PackedScene,
	title: StringName,
	args: Dictionary[StringName, Variant] = {},
	icon: Texture2D = null,
	callback_name: StringName = &"",
	callback_args: Array = []
	) -> Node:
		if get_tab_count() >= tabs_max_count:
			tab_limit_reached.emit()
			return null
		
		title = title.replace(".", "").validate_node_name()
		
		var tab_idx: int = get_tab_idx_from_title(title)
		
		if tab_idx >= 0:
			current_tab = tab_idx
			
			var active_tab_control: Control = get_active_tab_control()
			
			if active_tab_control.has_method(callback_name):
				active_tab_control.callv(callback_name, callback_args)
			
			return null
		
		if pack == null:
			return null
		
		var content_node: Node = pack.instantiate()
		
		if not title.is_empty():
			content_node.name = title
		
		for property: StringName in args:
			if property in content_node:
				content_node.set(property, args[property])
		
		add_child(content_node)
		switch_to_last_tab()
		
		if icon != null:
			set_tab_icon(current_tab, icon)
		
		_update_tab_processes()
		
		if content_node.has_method(callback_name):
			content_node.callv(callback_name, callback_args)
		
		return content_node


func close_tabs_by_title(tab_title_to_close: String, mode: TabCloseByNameMode = TabCloseByNameMode.EXACT) -> void:
	var tab_titles: PackedStringArray = get_tab_titles()
	
	for tab_idx: int in tab_titles.size():
		var tab_title: String = tab_titles[tab_idx]
		
		if(
			(mode == TabCloseByNameMode.EXACT and tab_title == tab_title_to_close)
			or (mode == TabCloseByNameMode.BEGINS and tab_title.begins_with(tab_title_to_close))
			or (mode == TabCloseByNameMode.ENDS and tab_title.ends_with(tab_title_to_close))
			):
				close_tab(tab_idx)


func switch_to_last_tab() -> void:
	current_tab = get_tab_count() - 1


func switch_to_tab_with_name(title: StringName) -> void:
	var tab_idx: int = get_tab_idx_from_title(title)
	
	if tab_idx < 0:
		return
	
	current_tab = tab_idx


func get_active_tab_control() -> Control:
	var tab_controls: Array[Control] = get_tab_controls()
	
	return tab_controls[current_tab] if not tab_controls.is_empty() else null


func get_tab_controls() -> Array[Control]:
	var tab_controls: Array[Control]
	
	for child in get_children():
		if child is Control:
			tab_controls.append(child)
	
	return tab_controls


func get_tab_idx_from_title(title: StringName) -> int:
	for tab_idx: int in get_tab_count():
		if get_tab_title(tab_idx) == title:
			return tab_idx
	
	return -1


func tab_exists(title: StringName) -> bool:
	return get_tab_idx_from_title(title) >= 0


func get_tab_titles() -> PackedStringArray:
	var tab_titles: PackedStringArray = PackedStringArray([])
	
	for tab_idx: int in get_tab_count():
		tab_titles.append(get_tab_title(tab_idx))
	
	return tab_titles


func retab_node(tab_control: Control) -> void:
	if tab_control != null:
		if tab_control.has_method(METHOD_CLOSE_OVERRIDE):
			tab_control.call(METHOD_CLOSE_OVERRIDE)
		
		else:
			tab_control.queue_free()


func close_tab(tab_idx: int) -> void:
	retab_node(get_tab_control(tab_idx))


func close_current_tab() -> void:
	retab_node(get_current_tab_control())


func close_other_tabs() -> void:
	for tab_idx in get_tab_count():
		if tab_idx != current_tab:
			close_tab(tab_idx)


func close_all_tabs() -> void:
	for tab_idx in get_tab_count():
		close_tab(tab_idx)
#endregion

#region Private Methods
func _update_tab_processes() -> void:
	if not single_tab_processing_enabled:
		for tab_control: Control in get_tab_controls():
			tab_control.set_process(true)
			tab_control.set_process_input(true)
			tab_control.set_physics_process(true)
		
		return
	
	var current_tab_control: Control = get_active_tab_control()
	
	if current_tab_control == null:
		return
	
	for tab_control: Control in get_tab_controls():
		tab_control.set_process(tab_control == current_tab_control)
		tab_control.set_process_input(tab_control == current_tab_control)
		tab_control.set_physics_process(tab_control == current_tab_control)
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
func _on_tab_changed(_tab_idx: int) -> void:
	_update_tab_processes()


func _on_TabsMenu_id_pressed(tab_idx: int) -> void:
	current_tab = tab_idx


func _on_TabsMenu_about_to_popup() -> void:
	TabsMenu.clear()
	
	for tab_idx in get_tab_count():
		TabsMenu.add_radio_check_item(get_tab_title(tab_idx))
		TabsMenu.set_item_checked(tab_idx, current_tab == tab_idx)
	
	TabsMenu.size.y = 1
	TabsMenu.position.y += 10


func _on_TabsBar_tab_close_pressed(tab_idx: int) -> void:
	close_tab(tab_idx)


func _on_TabsBar_tab_rmb_clicked(_tab_idx: int) -> void:
	ContextMenu.popup(Rect2(get_global_mouse_position(), Vector2.ONE))


func _on_child_detection(node: Node = null, entered: bool = false) -> void:
	if not entered:
		tab_closed.emit(node)
	
	await get_tree().process_frame
	
	set_popup(null if get_tab_count() == 0 else TabsMenu)
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_single_tab_processing_enabled(arg: bool) -> void:
	single_tab_processing_enabled = arg
	_update_tab_processes()
#endregion

#region Getter Methods
#endregion
