class_name UtilsProcess


static func parse_args(delimiter: String = "=") -> Dictionary[String, Variant]:
	var args: Dictionary[String, Variant]
	
	for arg: String in OS.get_cmdline_args():
		arg = arg.replace(" ", "")
		
		var split: PackedStringArray = arg.split(delimiter, false)
		
		match split.size():
			1: args[split[0]] = null
			2: args[split[0]] = split[1]
	
	return args


static func switch(process_path: String, args: PackedStringArray = PackedStringArray([])) -> void:
	OS.create_process(process_path, args)
	UtilsEngine.get_tree().quit()


static func restart(
	args: PackedStringArray = PackedStringArray([]),
	quit_current_process: bool = true,
	on_quit_callback: Callable = Callable(),
	) -> void:
		OS.create_instance(OS.get_cmdline_args() if args.is_empty() else args)
		
		if quit_current_process:
			if on_quit_callback.is_valid():
				on_quit_callback.call()
			
			else:
				UtilsEngine.get_tree().quit()
