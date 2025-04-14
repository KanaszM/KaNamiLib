#@tool
class_name TreeFooterAppliedOperation
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var item: TreeItem
var index: int
var operation: Callable
var selection_only: bool
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init(
	item_reference: TreeItem, index_value: int, operation_reference: Callable, selection_only_state: bool
	) -> void:
		item = item_reference
		index = index_value
		operation = operation_reference
		selection_only = selection_only_state
#endregion

#region Public Methods
func call_operation() -> void:
	operation.call(item, index, selection_only, false)
#endregion

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
