"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

@tool
class_name ExtendedRichTextLabel
extends RichTextLabel

#region Signals
#endregion

#region Enums
#endregion

#region Constants
#endregion

#region Export Variables
#endregion

#region Public Variables
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

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
