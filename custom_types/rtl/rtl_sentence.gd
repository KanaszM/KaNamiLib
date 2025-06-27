class_name RTLSentence

#region Public Variables
var rtls: Array[RTL]
var join_character: String
#endregion

#region OnReady Variables
func _init(rtls_arg: Array[RTL], join_character_arg: String = " ") -> void:
	rtls = rtls_arg
	join_character = join_character_arg
#endregion

#region Public Methods
func append_to(label: RichTextLabel, clear: bool = false) -> void:
	if clear:
		label.clear()
	
	var texts: PackedStringArray
	
	for rtl: RTL in rtls:
		texts.append(str(rtl))
	
	label.append_text(join_character.join(texts))
#endregion
