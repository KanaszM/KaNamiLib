class_name SceneManagerOptions

#region Public Variables
var log_success_messages: bool = true
var override_same_scene: bool
var wait_time: float

var scene_arguments: Dictionary[StringName, Variant]

var window_size: Vector2
var window_borderless: bool
var window_resizable: bool = true
var window_transparent: bool
var window_move_to_center: bool
var window_mode: Window.Mode = Window.MODE_WINDOWED
#endregion
