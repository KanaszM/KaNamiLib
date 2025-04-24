@tool
class_name ExtendedMarginContainer
extends MarginContainer

#region Signals
signal margin_changed
#endregion

#region Enums
enum Mode {UNIT, PERCENTAGE}
#endregion

#region Constants
#endregion

#region Export Variables
@export var mode: Mode = Mode.UNIT: set = _set_mode

@export_group("Unit Margins", "margin_")
@export var margin_all: int: set = _set_margin_all
@export var margin_left_right: int: set = _set_margin_left_right
@export var margin_top_bottom: int: set = _set_margin_top_bottom
@export var margin_left: int: set = _set_margin_left
@export var margin_right: int: set = _set_margin_right
@export var margin_top: int: set = _set_margin_top
@export var margin_bottom: int: set = _set_margin_bottom

@export_group("Percentage Margins", "percent_margin_")
@export_range(0.0, 100.0, 0.01, "suffix:%") var percent_margin_all: float: set = _set_percent_margin_all
@export_range(0.0, 100.0, 0.01, "suffix:%") var percent_margin_left: float: set = _set_percent_margin_left
@export_range(0.0, 100.0, 0.01, "suffix:%") var percent_margin_right: float: set = _set_percent_margin_right
@export_range(0.0, 100.0, 0.01, "suffix:%") var percent_margin_top: float: set = _set_percent_margin_top
@export_range(0.0, 100.0, 0.01, "suffix:%") var percent_margin_bottom: float: set = _set_percent_margin_bottom
#endregion

#region Public Variables
#endregion

#region Private Variables
var _percent_margins_h: Vector2
var _percent_margins_v: Vector2
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _ready() -> void:
	_update_margins()
#endregion

#region Public Methods
func set_margin(value: int, left: bool, right: bool, top: bool, bottom: bool) -> ExtendedMarginContainer:
	if left:
		add_theme_constant_override(&"margin_left", value)
	
	if right:
		add_theme_constant_override(&"margin_right", value)
	
	if top:
		add_theme_constant_override(&"margin_top", value)
	
	if bottom:
		add_theme_constant_override(&"margin_bottom", value)
	
	if left or right or top or bottom:
		margin_changed.emit()
	
	return self
#endregion

#region Private Methods
func _update_margins() -> void:
	match mode:
		Mode.UNIT:
			UtilsSignal.disconnect_safe(resized, _update_margins)
			
			if margin_all != 0:
				set_margin(margin_all, true, true, true, true)
			
			elif (margin_left_right + margin_top_bottom) != 0:
				set_margin(margin_left_right, true, true, false, false)
				set_margin(margin_top_bottom, false, false, true, true)
			
			else:
				set_margin(margin_left, true, false, false, false)
				set_margin(margin_right, false, true, false, false)
				set_margin(margin_top, false, false, true, false)
				set_margin(margin_bottom, false, false, false, true)
		
		Mode.PERCENTAGE:
			UtilsSignal.connect_safe(resized, _update_margins)
			
			var size_h: Vector2i = (Vector2i.ONE * size.x) * _percent_margins_h
			var size_v: Vector2i = (Vector2i.ONE * size.y) * _percent_margins_v
			
			set_margin(size_h.x, true, false, false, false)
			set_margin(size_h.y, false, true, false, false)
			set_margin(size_v.x, false, false, true, false)
			set_margin(size_v.y, false, false, false, true)
#endregion

#region SubClasses
#endregion

#region Setter Methods
func _set_mode(arg: Mode) -> void:
	mode = arg
	_update_margins()

# Unit Margins
func _set_margin_all(arg: int) -> void:
	margin_all = arg
	_update_margins()


func _set_margin_left_right(arg: int) -> void:
	margin_left_right = arg
	_update_margins()


func _set_margin_top_bottom(arg: int) -> void:
	margin_top_bottom = arg
	_update_margins()


func _set_margin_left(arg: int) -> void:
	margin_left = arg
	_update_margins()


func _set_margin_right(arg: int) -> void:
	margin_right = arg
	_update_margins()


func _set_margin_top(arg: int) -> void:
	margin_top = arg
	_update_margins()


func _set_margin_bottom(arg: int) -> void:
	margin_bottom = arg
	_update_margins()

# Percentage Margins
func _set_percent_margin_all(arg: float) -> void:
	percent_margin_all = arg
	_percent_margins_h = (Vector2.ONE * percent_margin_all) / 100.0
	_percent_margins_v = _percent_margins_h
	_update_margins()


func _set_percent_margin_left(arg: float) -> void:
	percent_margin_left = arg
	_percent_margins_h.x = percent_margin_left / 100.0
	_update_margins()


func _set_percent_margin_right(arg: float) -> void:
	percent_margin_right = arg
	_percent_margins_h.y = percent_margin_right / 100.0
	_update_margins()


func _set_percent_margin_top(arg: float) -> void:
	percent_margin_top = arg
	_percent_margins_v.x = percent_margin_top / 100.0
	_update_margins()


func _set_percent_margin_bottom(arg: float) -> void:
	percent_margin_bottom = arg
	_percent_margins_v.y = percent_margin_bottom / 100.0
	_update_margins()
#endregion

#region Getter Methods
#endregion
