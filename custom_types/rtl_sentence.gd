#@tool
class_name RTLSentence
#extends 

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
var rtls: Array[RTL]
var join_character: String
#endregion

#region Private Variables
#endregion

#region OnReady Variables
func _init(rtls_arg: Array[RTL], join_character_arg: String = " ") -> void:
	rtls = rtls_arg
	join_character = join_character_arg
#endregion

#region Virtual Methods
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

#region Private Methods
#endregion

#region Static Methods
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
