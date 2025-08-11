class_name UtilsTween


static func kill_tween_safe(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()
