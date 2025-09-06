class_name InspectorPropertySection extends FoldableContainer

#region Public Variables
var title_raw: String
#endregion

#region Private Variables
var _vbox: VBoxContainer
#endregion

#region Constructor
func _init(title_arg: String, foldable_group_arg: FoldableGroup) -> void:
	title_raw = title_arg
	title = title_arg.strip_edges().capitalize()
	foldable_group = foldable_group_arg


func _ready() -> void:
	_vbox = VBoxContainer.new()
	add_child(_vbox)
#endregion

#region Public Methods
func add(control: Control) -> void:
	_vbox.add_child(control)
#endregion
