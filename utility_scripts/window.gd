class_name UtilsWindow


static func get_window() -> Window:
	return UtilsEngine.get_tree().root


static func update_window(
		size: Vector2 = Vector2.ZERO,
		borderless: bool = false,
		resizable: bool = true,
		transparent: bool = false,
		move_to_center: bool = true,
		mode: Window.Mode = Window.MODE_WINDOWED,
	) -> void:
		var screen_size: Vector2 = Vector2(DisplayServer.screen_get_size())
		var window: Window = get_window()
		var window_is_full_screen: bool = mode in [
			Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN, Window.MODE_MAXIMIZED,
			]
		
		window.mode = mode
		
		if not window_is_full_screen:
			if size > Vector2.ZERO:
				window.size = Vector2(
					clampf(size.x, 1.0, screen_size.x),
					clampf(size.y, 1.0, screen_size.y)
					)
			
			if move_to_center:
				window.move_to_center()
		
		window.borderless = borderless and not window_is_full_screen
		window.transparent = transparent
		window.unresizable = not resizable and not window_is_full_screen
