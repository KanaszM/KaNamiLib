@tool
extends EditorScript

#region Constructor
func _run() -> void:
	var notifications: Dictionary[int, PackedStringArray] = _generate_notifications_dict()
	
	for value: int in notifications:
		for entry: String in notifications[value]:
			var entry_split: PackedStringArray = entry.split(".")
			var entry_origin: String = entry_split[0]
			var entry_name: String = entry_split[1].replace("NOTIFICATION_", "").replace("_", " ").to_lower()
			
			print("%s: return \"[%d] %s :: %s\"" % [entry, value, entry_origin, entry_name])
		
		#print("%s" % [notifications[value]])
		#print("%-5d == %s" % [value, " == ".join(notifications[value])])
#endregion

#region Private Methods
func _generate_notifications_dict() -> Dictionary[int, PackedStringArray]:
	var unsorted_notifications: Dictionary[int, PackedStringArray]
	
	for class_name_str: String in ClassDB.get_class_list():
		for constant_name: String in ClassDB.class_get_integer_constant_list(class_name_str, true):
			if not constant_name.begins_with("NOTIFICATION_"):
				continue
			
			var value: int = ClassDB.class_get_integer_constant(class_name_str, constant_name)
			
			if not value in unsorted_notifications:
				unsorted_notifications[value] = PackedStringArray([])
			
			unsorted_notifications[value].append("%s.%s" % [class_name_str, constant_name])

	var sorted_values: PackedInt32Array = PackedInt32Array(unsorted_notifications.keys())
	
	sorted_values.sort()
	
	var sorted_notifications: Dictionary[int, PackedStringArray]
	
	for value: int in sorted_values:
		sorted_notifications[value] = unsorted_notifications[value]
	
	return sorted_notifications
#endregion
