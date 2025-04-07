"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsVariant


static func to_bool(what: Variant) -> bool:
	match typeof(what):
		TYPE_BOOL:
			return what as bool
		
		TYPE_INT, TYPE_FLOAT:
			return int(what) == 1
		
		TYPE_STRING, TYPE_STRING_NAME:
			return UtilsText.strip(str(what)).to_lower() == "true"
		
		_:
			return false
