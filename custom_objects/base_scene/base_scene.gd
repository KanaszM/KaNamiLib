@abstract class_name BaseScene extends Node

#region Constants
const GROUP: StringName = &"BaseScene"
#endregion

#region Signals
signal teardown_completed
#endregion

#region Private Variables
var _id: String
var _teardown_is_active: bool
var _teardown_is_completed: bool
#endregion

#region Virtual Methods
func _ready() -> void:
	add_to_group(GROUP)
	
	teardown_completed.connect(_on_teardown_completed)


func _to_string() -> String:
	return "<BaseScene[%s]>" % ("N/A" if _id.is_empty() else _id)
#endregion

#region Public Methods
func set_id(id: String) -> void:
	if is_inside_tree():
		Log.error("The ID should be set before adding the node to the tree by the BaseSceneManager!", set_id)
		return
	
	id = id.strip_edges()
	
	if id.is_empty():
		Log.error("The ID cannot be empty!", set_id)
		return
	
	_id = id


func get_id() -> String:
	return _id


func teardown() -> void:
	if _teardown_is_completed:
		Log.warning("This BaseScene has already been torn down.", teardown)
		return
	
	if _teardown_is_active:
		Log.warning("Still processing the previous request...", teardown)
		return
	
	_teardown_is_active = true
	_teardown()
#endregion

#region Private Methods
func _teardown() -> void:
	pass
#endregion

#region Signal Callbacks
func _on_teardown_completed() -> void:
	_teardown_is_active = false
	_teardown_is_completed = true
#endregion
