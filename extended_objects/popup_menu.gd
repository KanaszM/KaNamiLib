@tool
class_name ExtendedPopupMenu
extends PopupMenu

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
@export var free_on_hide: bool
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _ready() -> void:
	id_pressed.connect(_on_id_pressed)
	UtilsSignal.connect_safe_if(popup_hide, _on_popup_hide, free_on_hide)
#endregion

#region Public Methods
func popup_at_mouse_position(
	position_offset: Vector2 = Vector2.ZERO, popup_size_override: Vector2 = Vector2.ONE
	) -> void:
		static_popup_at_mouse_position(self, position_offset, popup_size_override)


func build_from_items_array(items: Array[Item]) -> void:
	clear(true)
	
	for item in items:
		match item.type:
			Item.Type.BUTTON:
				add_item(item.text)
			
			Item.Type.DIVIDER:
				add_separator(item.text)
			
			Item.Type.CHECK:
				add_check_item(item.text)
				
				if (item as Check).checked:
					set_item_checked(-1, true)
			
			Item.Type.ENUM:
				var sub_menu: PopupMenu = PopupMenu.new()
				
				sub_menu.hide_on_checkable_item_selection = hide_on_checkable_item_selection
				sub_menu.hide_on_item_selection = hide_on_item_selection
				sub_menu.hide_on_state_item_selection = hide_on_state_item_selection
				
				add_child(sub_menu)
				add_submenu_item(item.text, sub_menu.name)
				
				for key in (item as Enum).keys:
					sub_menu.add_radio_check_item(key)
				
				sub_menu.set_item_checked((item as Enum).selected, true)
				sub_menu.id_pressed.connect(_on_radio_id_pressed.bind(sub_menu, item.callback))
		
		if item.icon != null:
			var icon_color: Color = get_font_color() if item.modulate_icon else Color.WHITE
			
			set_item_icon(-1, item.icon)
			set_item_icon_max_width(-1, 16)
			set_item_icon_modulate(-1, icon_color.darkened(item.darken_icon))
		
		set_item_metadata(-1, item)


func build_from_items_array_and_popup_at_mouse_position(
	items: Array[Item], position_offset: Vector2 = Vector2.ZERO, popup_size_override: Vector2 = Vector2.ONE
	) -> void:
		build_from_items_array(items)
		
		if not items.is_empty():
			popup_at_mouse_position(position_offset, popup_size_override)
#endregion

#region Theme Methods
func get_font_color() -> Color:
	return get_theme_color(&"font_color")
#endregion

#region Private Methods
#endregion

#region Static Methods
static func static_popup_at_mouse_position(
	popup_node: Popup, position_offset: Vector2 = Vector2.ZERO, popup_size: Vector2 = Vector2.ONE
	) -> void:
		popup_node.popup(Rect2(UtilsWindow.get_window().get_mouse_position() + position_offset, popup_size))


static func static_context_menu_from_object(
	object: Object,
	items: Array[Item],
	position_offset: Vector2 = Vector2.ZERO,
	popup_size_override: Vector2 = Vector2.ONE,
	popup_after_build: bool = true,
	parent: Node = UtilsEngine.get_current_scene()
	) -> void:
		static_context_menu(
			StringName(str(object)), items, position_offset, popup_size_override, popup_after_build, parent
			)


static func static_context_menu(
	popup_name: StringName,
	items: Array[Item],
	position_offset: Vector2 = Vector2.ZERO,
	popup_size_override: Vector2 = Vector2.ONE,
	popup_after_build: bool = true,
	parent: Node = UtilsEngine.get_current_scene()
	) -> void:
		var nodepath: NodePath = NodePath(str(popup_name))
		var popup_menu := (parent.get_node(nodepath) if parent.has_node(nodepath) else null) as ExtendedPopupMenu
		
		if items.is_empty():
			if popup_menu != null:
				popup_menu.queue_free()
			
			return
		
		if popup_menu == null:
			popup_menu = ExtendedPopupMenu.new()
			
			popup_menu.name = popup_name
			popup_menu.free_on_hide = true
			parent.add_child(popup_menu)
		
		popup_menu.build_from_items_array(items)
		
		if popup_after_build and not items.is_empty():
			static_popup_at_mouse_position(popup_menu, position_offset, popup_size_override)
#endregion

#region Signal Callbacks
func _on_popup_hide() -> void:
	queue_free()


func _on_id_pressed(id: int) -> void:
	var meta: Variant = get_item_metadata(id)
	
	if meta is Item:
		var callback: Callable = (meta as Item).callback
		
		if callback.is_valid():
			callback.call()
		
		if is_item_checkable(id):
			toggle_item_checked(id)


func _on_radio_id_pressed(id: int, menu: PopupMenu, callback: Callable) -> void:
	for item_id: int in menu.item_count:
		menu.set_item_checked(item_id, item_id == id)
	
	if not callback.is_null():
		callback.call(id)
#endregion

#region SubClasses
class Item:
	#region Enums
	enum Type {BUTTON, DIVIDER, CHECK, ENUM}
	#endregion
	
	#region Public Variables
	var type: Type = Type.BUTTON
	var text: String
	var callback: Callable
	var icon: Texture2D
	var modulate_icon: bool = true
	var darken_icon: float
	#endregion
	
	#region Virtual Methods
	func _init(text_param: String, callback_param: Callable = Callable()) -> void:
		text = text_param
		callback = callback_param
	
	func _to_string() -> String:
		return (
			"<ExtendedPopupMenu.Item[%s][\"%s\"]%s>"
			% [UtilsDictionary.enum_to_str(Type, type, true), text, UtilsCallback.to_str(callback)]
			)
	#endregion
	
	#region Public Methods
	func set_icon(texture: Texture2D, modulate: bool = true, darken: float = 0.0) -> Item:
		icon = texture
		modulate_icon = modulate
		darken_icon = darken
		
		return self
	#endregion


class Divider extends Item:
	#region Virtual Methods
	func _init(text_param: String = "", callback_param: Callable = Callable()) -> void:
		type = Item.Type.DIVIDER
		super._init(text_param, callback_param)
	#endregion


class Check extends Item:
	#region Public Variables
	var checked: bool
	#endregion
	
	#region Virtual Methods
	func _init(text_param: String, callback_param: Callable = Callable(), checked_param: bool = false) -> void:
		type = Item.Type.CHECK
		super._init(text_param, callback_param)
		
		checked = checked_param
	#endregion


class Enum extends Item:
	#region Public Variables
	var keys: PackedStringArray
	var selected: int
	#endregion
	
	#region Virtual Methods
	func _init(
		text_param: String,
		callback_param: Callable = Callable(),
		keys_param: Dictionary[String, String] = {},
		selected_param: int = 0
		) -> void:
			type = Item.Type.ENUM
			
			super._init(text_param, callback_param)
			
			for key: String in keys_param:
				keys.append(key.to_pascal_case())
			
			selected = selected_param
	#endregion
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
