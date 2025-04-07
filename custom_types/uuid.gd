"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""

#@tool
class_name UUID
extends Resource

#region Signals
#endregion

#region Enums
#endregion

#region Constants
const FORMAT: String = "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x"
#endregion

#region Export Variables
#endregion

#region Public Variables
var b: PackedByteArray
#endregion

#region Private Variables
#endregion

#region OnReady Variables
#endregion

#region Virtual Methods
func _init() -> void:
	b = UUID.get_binary()


func _to_string() -> String:
	return UUID.get_formatted(b)
#endregion

#region Public Methods
func get_byte_array() -> PackedByteArray:
	return b.duplicate()


func get_dict(big_endian: bool = true) -> Dictionary[int, int]:
	return {
		0: (b[0] << 24) + (b[1] << 16) + (b[2] << 8) + b[3],
		1: (b[4] << 8) + b[5],
		2: (b[6] << 8) + b[7],
		3: (b[8] << 8) + b[9],
		4: (b[10] << 40) + (b[11] << 32) + (b[12] << 24) + (b[13] << 16) + (b[14] << 8) + b[15]
		} if big_endian else {
			0: (b[1] << 8) + (b[2] << 16) + (b[3] << 24),
			1: b[4] + (b[5] << 8),
			2: b[6] + (b[7] << 8),
			3: b[8] + (b[9] << 8),
			4: b[10] + (b[11] << 8) + (b[12] << 16) + (b[13] << 24) + (b[14] << 32) + (b[15] << 40)
			}


func is_equal(uuid: UUID) -> bool:
	return b == uuid.b
#endregion

#region Private Methods
#endregion

#region Static Methods
static func get_binary(mask: int = 0b11111111) -> PackedByteArray:
	randomize()
	
	return PackedByteArray([
		randi() & mask, randi() & mask, randi() & mask, randi() & mask,
		randi() & mask, randi() & mask, ((randi() & mask) & 0x0f) | 0x40, randi() & mask,
		((randi() & mask) & 0x3f) | 0x80, randi() & mask, randi() & mask, randi() & mask,
		randi() & mask, randi() & mask, randi() & mask, randi() & mask
		])


static func get_formatted(_b: PackedByteArray = get_binary()) -> String:
	return FORMAT % [
		_b[0], _b[1], _b[2], _b[3], _b[4], _b[5], _b[6], _b[7], _b[8],
		_b[9], _b[10], _b[11], _b[12], _b[13], _b[14], _b[15]
		]
#endregion

#region Signal Callbacks
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
