@tool
class_name ExtendedScrollContainer
extends ScrollContainer

#region Signals
#endregion

#region Enums
enum FollowScrollSmoothMode {FIXED, BY_LENGTH}
#endregion

#region Constants
#endregion

#region Export Variables
@export_group("Follow Scroll", "follow_scroll_")
@export var follow_scroll_enabled: bool: set = _set_follow_scroll_enabled

@export_subgroup("Smoothing", "follow_scroll_smooth_")
@export var follow_scroll_smooth_enabled: bool = true
@export var follow_scroll_smooth_mode: FollowScrollSmoothMode = FollowScrollSmoothMode.FIXED
@export var follow_scroll_smooth_fixed_speed: float = 0.25: set = _set_follow_scroll_smooth_fixed_speed
@export var follow_scroll_smooth_by_length_weight: float = 2.0: set = _set_follow_scroll_smooth_by_length_weight
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
@onready var HorizontalScrollBar: HScrollBar = get_h_scroll_bar()
@onready var VerticalScrollBar: VScrollBar = get_v_scroll_bar()
@onready var ScrollBars: Array[ScrollBar] = [HorizontalScrollBar, VerticalScrollBar]
#endregion

#region Virtual Methods
func _ready() -> void:
	_set_follow_scroll_enabled(follow_scroll_enabled)
#endregion

#region Public Methods
func any_scroll_bar_has_focus() -> bool:
	return VerticalScrollBar.has_focus() or HorizontalScrollBar.has_focus()


func scroll_to_top() -> void:
	_set_max_scroll_vertical(false)


func scroll_to_bottom() -> void:
	_set_max_scroll_vertical(true)


func get_content() -> Control:
	if get_child_count() == 0:
		return null
	
	var first_child: Node = get_child(0)
	
	return first_child as Control if first_child is Control else null


func v_scroll_to_center(deferred: bool = true) -> void:
	if VerticalScrollBar == null:
		return
	
	if deferred:
		await get_tree().process_frame
	
	if VerticalScrollBar.max_value > 0.0 and VerticalScrollBar.page > 0.0:
		VerticalScrollBar.value = (VerticalScrollBar.max_value - VerticalScrollBar.page) / 2.0
#endregion

#region Private Methods
func _set_max_scroll_vertical(mode: bool) -> void:
	var final_value: float = VerticalScrollBar.max_value if mode else 0.0
	
	if follow_scroll_smooth_enabled:
		var tween: Tween = create_tween()
		var time: float
		
		match follow_scroll_smooth_mode:
			FollowScrollSmoothMode.FIXED:
				time = follow_scroll_smooth_fixed_speed
			
			FollowScrollSmoothMode.BY_LENGTH:
				time = (
					((final_value - VerticalScrollBar.value) / VerticalScrollBar.page)
					- follow_scroll_smooth_by_length_weight
				)
		
		tween.tween_property(VerticalScrollBar, ^"value", final_value, time)
	
	else:
		await get_tree().process_frame
		VerticalScrollBar.value = final_value
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_follow_scroll_enabled(arg: bool) -> void:
	follow_scroll_enabled = arg
	
	if not is_node_ready():
		return
	
	var content: Control = get_content()
	
	if content == null:
		return
	
	if follow_scroll_enabled and not content.resized.is_connected(scroll_to_bottom):
		content.resized.connect(scroll_to_bottom)
	
	elif not follow_scroll_enabled and content.resized.is_connected(scroll_to_bottom):
		content.resized.disconnect(scroll_to_bottom)


func _set_follow_scroll_smooth_fixed_speed(arg: float) -> void:
	follow_scroll_smooth_fixed_speed = maxf(0.0, arg)


func _set_follow_scroll_smooth_by_length_weight(arg: float) -> void:
	follow_scroll_smooth_by_length_weight = maxf(1.0, arg)
#endregion

#region Getter Methods
#endregion
