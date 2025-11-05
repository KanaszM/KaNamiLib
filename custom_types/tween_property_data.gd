class_name TweenPropertyData extends Resource

#region Exports
@export var property: NodePath
@export var to_value: Variant
@export var from_value: Variant
@export_range(0.0, 10.0, 0.001, "or_greater") var duration: float
@export_range(0.0, 10.0, 0.001, "or_greater") var delay: float
@export var transition_type: Tween.TransitionType
@export var ease_type: Tween.EaseType
#endregion
