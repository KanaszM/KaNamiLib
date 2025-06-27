@tool
class_name ExtendedRichTextLabel
extends RichTextLabel

#region Virtual Methods
func _init() -> void:
	bbcode_enabled = true
	fit_content = true
#endregion

#region Public Methods
func append_rtl(rtl: RTL, clear_text: bool = false) -> void:
	if clear_text:
		clear()
	
	RTL.append_to(self, rtl)
#endregion
