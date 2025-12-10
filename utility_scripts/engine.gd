class_name UtilsEngine


static func is_editor() -> bool:
	return OS.has_feature("editor")


static func get_tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


static func get_current_scene() -> Node:
	return get_tree().current_scene


static func has_global(singleton_name: StringName) -> bool:
	for child: Node in get_tree().root.get_children(true):
		if child.name == singleton_name:
			return true
	
	return false


static func notification_to_str(notification_idx: int) -> String:
	match notification_idx:
		Object.NOTIFICATION_POSTINITIALIZE: return "[0] Object :: postinitialize"
		Object.NOTIFICATION_PREDELETE: return "[1] Object :: predelete"
		Object.NOTIFICATION_EXTENSION_RELOADED: return "[2] Object :: extension reloaded"
		Node.NOTIFICATION_ENTER_TREE: return "[10] Node :: enter tree"
		Node.NOTIFICATION_EXIT_TREE: return "[11] Node :: exit tree"
		Node.NOTIFICATION_MOVED_IN_PARENT: return "[12] Node :: moved in parent"
		Node.NOTIFICATION_READY: return "[13] Node :: ready"
		Node.NOTIFICATION_PAUSED: return "[14] Node :: paused"
		Node.NOTIFICATION_UNPAUSED: return "[15] Node :: unpaused"
		Node.NOTIFICATION_PHYSICS_PROCESS: return "[16] Node :: physics process"
		Node.NOTIFICATION_PROCESS: return "[17] Node :: process"
		Node.NOTIFICATION_PARENTED: return "[18] Node :: parented"
		Node.NOTIFICATION_UNPARENTED: return "[19] Node :: unparented"
		Node.NOTIFICATION_SCENE_INSTANTIATED: return "[20] Node :: scene instantiated"
		Node.NOTIFICATION_DRAG_BEGIN: return "[21] Node :: drag begin"
		Node.NOTIFICATION_DRAG_END: return "[22] Node :: drag end"
		Node.NOTIFICATION_PATH_RENAMED: return "[23] Node :: path renamed"
		Node.NOTIFICATION_CHILD_ORDER_CHANGED: return "[24] Node :: child order changed"
		Node.NOTIFICATION_INTERNAL_PROCESS: return "[25] Node :: internal process"
		Node.NOTIFICATION_INTERNAL_PHYSICS_PROCESS: return "[26] Node :: internal physics process"
		Node.NOTIFICATION_POST_ENTER_TREE: return "[27] Node :: post enter tree"
		Node.NOTIFICATION_DISABLED: return "[28] Node :: disabled"
		Node.NOTIFICATION_ENABLED: return "[29] Node :: enabled"
		CanvasItem.NOTIFICATION_DRAW: return "[30] CanvasItem :: draw"
		Window.NOTIFICATION_VISIBILITY_CHANGED: return "[30] Window :: visibility changed"
		CanvasItem.NOTIFICATION_VISIBILITY_CHANGED: return "[31] CanvasItem :: visibility changed"
		CanvasItem.NOTIFICATION_ENTER_CANVAS: return "[32] CanvasItem :: enter canvas"
		Window.NOTIFICATION_THEME_CHANGED: return "[32] Window :: theme changed"
		CanvasItem.NOTIFICATION_EXIT_CANVAS: return "[33] CanvasItem :: exit canvas"
		CanvasItem.NOTIFICATION_LOCAL_TRANSFORM_CHANGED: return "[35] CanvasItem :: local transform changed"
		CanvasItem.NOTIFICATION_WORLD_2D_CHANGED: return "[36] CanvasItem :: world 2d changed"
		Control.NOTIFICATION_RESIZED: return "[40] Control :: resized"
		Control.NOTIFICATION_MOUSE_ENTER: return "[41] Control :: mouse enter"
		Node3D.NOTIFICATION_ENTER_WORLD: return "[41] Node3D :: enter world"
		Control.NOTIFICATION_MOUSE_EXIT: return "[42] Control :: mouse exit"
		Node3D.NOTIFICATION_EXIT_WORLD: return "[42] Node3D :: exit world"
		Control.NOTIFICATION_FOCUS_ENTER: return "[43] Control :: focus enter"
		Node3D.NOTIFICATION_VISIBILITY_CHANGED: return "[43] Node3D :: visibility changed"
		Control.NOTIFICATION_FOCUS_EXIT: return "[44] Control :: focus exit"
		Node3D.NOTIFICATION_LOCAL_TRANSFORM_CHANGED: return "[44] Node3D :: local transform changed"
		Control.NOTIFICATION_THEME_CHANGED: return "[45] Control :: theme changed"
		Control.NOTIFICATION_SCROLL_BEGIN: return "[47] Control :: scroll begin"
		Control.NOTIFICATION_SCROLL_END: return "[48] Control :: scroll end"
		Control.NOTIFICATION_LAYOUT_DIRECTION_CHANGED: return "[49] Control :: layout direction changed"
		Container.NOTIFICATION_PRE_SORT_CHILDREN: return "[50] Container :: pre sort children"
		Skeleton3D.NOTIFICATION_UPDATE_SKELETON: return "[50] Skeleton3D :: update skeleton"
		Container.NOTIFICATION_SORT_CHILDREN: return "[51] Container :: sort children"
		Control.NOTIFICATION_MOUSE_ENTER_SELF: return "[60] Control :: mouse enter self"
		Control.NOTIFICATION_MOUSE_EXIT_SELF: return "[61] Control :: mouse exit self"
		Node.NOTIFICATION_WM_MOUSE_ENTER: return "[1002] Node :: wm mouse enter"
		Node.NOTIFICATION_WM_MOUSE_EXIT: return "[1003] Node :: wm mouse exit"
		Node.NOTIFICATION_WM_WINDOW_FOCUS_IN: return "[1004] Node :: wm window focus in"
		Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT: return "[1005] Node :: wm window focus out"
		Node.NOTIFICATION_WM_CLOSE_REQUEST: return "[1006] Node :: wm close request"
		Node.NOTIFICATION_WM_GO_BACK_REQUEST: return "[1007] Node :: wm go back request"
		Node.NOTIFICATION_WM_SIZE_CHANGED: return "[1008] Node :: wm size changed"
		Node.NOTIFICATION_WM_DPI_CHANGE: return "[1009] Node :: wm dpi change"
		Node.NOTIFICATION_VP_MOUSE_ENTER: return "[1010] Node :: vp mouse enter"
		Node.NOTIFICATION_VP_MOUSE_EXIT: return "[1011] Node :: vp mouse exit"
		Node.NOTIFICATION_WM_POSITION_CHANGED: return "[1012] Node :: wm position changed"
		CanvasItem.NOTIFICATION_TRANSFORM_CHANGED: return "[2000] CanvasItem :: transform changed"
		Node3D.NOTIFICATION_TRANSFORM_CHANGED: return "[2000] Node3D :: transform changed"
		Node.NOTIFICATION_RESET_PHYSICS_INTERPOLATION: return "[2001] Node :: reset physics interpolation"
		MainLoop.NOTIFICATION_OS_MEMORY_WARNING: return "[2009] MainLoop :: os memory warning"
		Node.NOTIFICATION_OS_MEMORY_WARNING: return "[2009] Node :: os memory warning"
		MainLoop.NOTIFICATION_TRANSLATION_CHANGED: return "[2010] MainLoop :: translation changed"
		Node.NOTIFICATION_TRANSLATION_CHANGED: return "[2010] Node :: translation changed"
		MainLoop.NOTIFICATION_WM_ABOUT: return "[2011] MainLoop :: wm about"
		Node.NOTIFICATION_WM_ABOUT: return "[2011] Node :: wm about"
		MainLoop.NOTIFICATION_CRASH: return "[2012] MainLoop :: crash"
		Node.NOTIFICATION_CRASH: return "[2012] Node :: crash"
		MainLoop.NOTIFICATION_OS_IME_UPDATE: return "[2013] MainLoop :: os ime update"
		Node.NOTIFICATION_OS_IME_UPDATE: return "[2013] Node :: os ime update"
		MainLoop.NOTIFICATION_APPLICATION_RESUMED: return "[2014] MainLoop :: application resumed"
		Node.NOTIFICATION_APPLICATION_RESUMED: return "[2014] Node :: application resumed"
		MainLoop.NOTIFICATION_APPLICATION_PAUSED: return "[2015] MainLoop :: application paused"
		Node.NOTIFICATION_APPLICATION_PAUSED: return "[2015] Node :: application paused"
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN: return "[2016] MainLoop :: application focus in"
		Node.NOTIFICATION_APPLICATION_FOCUS_IN: return "[2016] Node :: application focus in"
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT: return "[2017] MainLoop :: application focus out"
		Node.NOTIFICATION_APPLICATION_FOCUS_OUT: return "[2017] Node :: application focus out"
		MainLoop.NOTIFICATION_TEXT_SERVER_CHANGED: return "[2018] MainLoop :: text server changed"
		Node.NOTIFICATION_TEXT_SERVER_CHANGED: return "[2018] Node :: text server changed"
		Node.NOTIFICATION_ACCESSIBILITY_UPDATE: return "[3000] Node :: accessibility update"
		Node.NOTIFICATION_ACCESSIBILITY_INVALIDATE: return "[3001] Node :: accessibility invalidate"
		Node.NOTIFICATION_EDITOR_PRE_SAVE: return "[9001] Node :: editor pre save"
		Node.NOTIFICATION_EDITOR_POST_SAVE: return "[9002] Node :: editor post save"
		EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED: return "[10000] EditorSettings :: editor settings changed"
		_: return ""
