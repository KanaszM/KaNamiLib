class_name RTLSentence

#region Public Variables
var rtls: Array[RTL]
var join_character: String
var text_size: int = RTL.DEFAULT_TEXT_SIZE: set = size
#endregion

#region Virtual Methods
func _init(rtls_arg: Array[RTL] = [], join_character_arg: String = " ") -> void:
	rtls = rtls_arg
	join_character = join_character_arg
#endregion

#region Public Methods
func get_rtls() -> Array[RTL]:
	return rtls


func get_join_character() -> String:
	return join_character


func add_rtl(rtl: RTL) -> RTLSentence:
	rtls.append(rtl)
	return self


func add_rtls(rtls_arg: Array[RTL]) -> RTLSentence:
	rtls.append_array(rtls_arg)
	return self


func set_rtl(rtl: RTL) -> RTLSentence:
	rtls = [rtl]
	return self


func set_rtls(rtls_arg: Array[RTL]) -> RTLSentence:
	rtls = rtls_arg
	return self


func append_to(output: RichTextLabel, clear: bool = false) -> void:
	if clear:
		output.clear()
	
	var texts: PackedStringArray
	
	for rtl: RTL in rtls:
		rtl.size(text_size)
		texts.append(str(rtl))
	
	output.append_text(join_character.join(texts))


func combine(sentence: RTLSentence) -> RTLSentence:
	rtls.append_array(sentence.rtls)
	return self
#endregion

#region Setter Methods
func size(arg: int = RTL.DEFAULT_TEXT_SIZE) -> RTLSentence:
	text_size = arg
	return self
#endregion
