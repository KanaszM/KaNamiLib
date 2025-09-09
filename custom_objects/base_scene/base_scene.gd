@abstract class_name BaseScene extends Node

#region Constants
const GROUP: StringName = &"BaseScene"
#endregion

#region Signals
signal teardown_completed
#endregion

#region Abstract Methods
@abstract func _teardown() -> void
#endregion

#region Private Variables
var _id: String
var _teardown_is_active: bool
var _teardown_is_completed: bool
#endregion

#region Constructor
func _init() -> void:
	add_to_group(GROUP)
	
	teardown_completed.connect(_on_teardown_completed)
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

#region Static Public Methods
static func get_current(scene_tree: SceneTree) -> BaseScene:
	if scene_tree == null:
		Log.error("The provided scene tree reference is null!", get_current)
		return null
	
	var detected_valid_nodes: Array[Node] = scene_tree.get_nodes_in_group(GROUP)
	
	if detected_valid_nodes.is_empty():
		return
	
	if detected_valid_nodes.size() > 1:
		Log.warning("More than one base scene have been detected. Returning the first one...", get_current)
	
	return detected_valid_nodes[0] as BaseScene
#endregion

#region Private Methods
func _to_string() -> String:
	return "<BaseScene[%s]>" % ("N/A" if _id.is_empty() else _id)
#endregion

#region Signal Callbacks
func _on_teardown_completed() -> void:
	_teardown_is_active = false
	_teardown_is_completed = true
#endregion
