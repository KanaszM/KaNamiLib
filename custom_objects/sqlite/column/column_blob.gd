class_name SQLColumnBlob extends SQLColumn

#region Virtual Methods
func _init(name_arg: String = "") -> void:
	super._init(DataType.BLOB, name_arg)


func _get_class() -> String:
	return "SQLColumnBlob"
#endregion
