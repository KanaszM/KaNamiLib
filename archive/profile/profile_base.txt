class_name ProfileBase extends Resource

#region General
var profile_name: String: set = _set_profile_name
var profile_seed: String: set = _set_profile_seed
#endregion

#region Private Methods
func _to_string() -> String:
	return "<Profile[%s][%s]>" % [profile_name, profile_seed]
#endregion

#region Setter Methods
func _set_profile_name(arg: String) -> void:
	if arg.is_empty():
		Log.error("The profile name cannot be empty!")
		return
	
	profile_name = arg.strip_edges()


func _set_profile_seed(arg: String) -> void:
	if arg.is_empty():
		Log.error("The profile seed cannot be empty!")
		return
	
	profile_seed = arg.strip_edges()
#endregion
