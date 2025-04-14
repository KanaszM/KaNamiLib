#@tool
class_name Shade
extends Resource

#region Signals
#endregion

#region Enums
enum Type {GRAY, RED, PINK, GRAPE, VIOLET, INDIGO, BLUE, CYAN, TEAL, GREEN, LIME, YELLOW, ORANGE}
#endregion

#region Constants
const DEFAULT_IDX: int = 6
const INVERTED_STRENGTH_IDX: int = 1

const COLORS: Dictionary[Type, Array] = {
  Type.GRAY: [
	Color("#f8f9fa"), Color("#f1f3f5"), Color("#e9ecef"), Color("#dee2e6"), Color("#ced4da"),
	Color("#adb5bd"), Color("#868e96"), Color("#495057"), Color("#343a40"), Color("#212529"),
  ],
  Type.RED: [
	Color("#fff5f5"), Color("#ffe3e3"), Color("#ffc9c9"), Color("#ffa8a8"), Color("#ff8787"),
	Color("#ff6b6b"), Color("#fa5252"), Color("#f03e3e"), Color("#e03131"), Color("#c92a2a"),
  ],
  Type.PINK: [
	Color("#fff0f6"), Color("#ffdeeb"), Color("#fcc2d7"), Color("#faa2c1"), Color("#f783ac"),
	Color("#f06595"), Color("#e64980"), Color("#d6336c"), Color("#c2255c"), Color("#a61e4d"),
  ],
  Type.GRAPE: [
	Color("#f8f0fc"), Color("#f3d9fa"), Color("#eebefa"), Color("#e599f7"), Color("#da77f2"),
	Color("#cc5de8"), Color("#be4bdb"), Color("#ae3ec9"), Color("#9c36b5"), Color("#862e9c"),
  ],
  Type.VIOLET: [
	Color("#f3f0ff"), Color("#e5dbff"), Color("#d0bfff"), Color("#b197fc"), Color("#9775fa"),
	Color("#845ef7"), Color("#7950f2"), Color("#7048e8"), Color("#6741d9"), Color("#5f3dc4"),
  ],
  Type.INDIGO: [
	Color("#edf2ff"), Color("#dbe4ff"), Color("#bac8ff"), Color("#91a7ff"), Color("#748ffc"),
	Color("#5c7cfa"), Color("#4c6ef5"), Color("#4263eb"), Color("#3b5bdb"), Color("#364fc7"),
  ],
  Type.BLUE: [
	Color("#e7f5ff"), Color("#d0ebff"), Color("#a5d8ff"), Color("#74c0fc"), Color("#4dabf7"),
	Color("#339af0"), Color("#228be6"), Color("#1c7ed6"), Color("#1971c2"), Color("#1864ab"),
  ],
  Type.CYAN: [
	Color("#e3fafc"), Color("#c5f6fa"), Color("#99e9f2"), Color("#66d9e8"), Color("#3bc9db"),
	Color("#22b8cf"), Color("#15aabf"), Color("#1098ad"), Color("#0c8599"), Color("#0b7285"),
  ],
  Type.TEAL: [
	Color("#e6fcf5"), Color("#c3fae8"), Color("#96f2d7"), Color("#63e6be"), Color("#38d9a9"),
	Color("#20c997"), Color("#12b886"), Color("#0ca678"), Color("#099268"), Color("#087f5b"),
  ],
  Type.GREEN: [
	Color("#ebfbee"), Color("#d3f9d8"), Color("#b2f2bb"), Color("#8ce99a"), Color("#69db7c"),
	Color("#51cf66"), Color("#40c057"), Color("#37b24d"), Color("#2f9e44"), Color("#2b8a3e"),
  ],
  Type.LIME: [
	Color("#f4fce3"), Color("#e9fac8"), Color("#d8f5a2"), Color("#c0eb75"), Color("#a9e34b"),
	Color("#94d82d"), Color("#82c91e"), Color("#74b816"), Color("#66a80f"), Color("#5c940d"),
  ],
  Type.YELLOW: [
	Color("#fff9db"), Color("#fff3bf"), Color("#ffec99"), Color("#ffe066"), Color("#ffd43b"),
	Color("#fcc419"), Color("#fab005"), Color("#f59f00"), Color("#f08c00"), Color("#e67700"),
  ],
  Type.ORANGE: [
	Color("#fff4e6"), Color("#ffe8cc"), Color("#ffd8a8"), Color("#ffc078"), Color("#ffa94d"),
	Color("#ff922b"), Color("#fd7e14"), Color("#f76707"), Color("#e8590c"), Color("#d9480f"),
  ]
}
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
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion

#region Static Methods
static func get_color(type: Type, idx: int = 0, reversed: bool = false, alpha: float = 1.0) -> Color:
	var colors := Array(COLORS[type], TYPE_COLOR, &"", null) as Array[Color]
	var result: Color = colors[get_opposite_idx(idx) if reversed else clamp_color_idx(idx)]
	
	result.a = alpha
	
	return result


static func get_random_color_by_idx(idx: int, reversed: bool = false, alpha: float = 1.0) -> Color:
	return get_color((Type.values() as Array[Type])[randi_range(0, Type.size())], idx, reversed, alpha)


static func get_opposite_idx(idx: int) -> int:
	return clamp_color_idx(INVERTED_STRENGTH_IDX + 9 - idx)


static func get_opposite_color(type: Type, idx: int = 0) -> Color:
	return (Array(COLORS[type], TYPE_COLOR, &"", null) as Array[Color])[get_opposite_idx(idx)]


static func get_opposite_color_raw(color: Color) -> Color:
	for type: Type in COLORS:
		var idx: int = COLORS[type].find(color)
		
		if idx >= 0:
			return get_opposite_color(type, idx)
	
	return color


static func clamp_color_idx(idx: int) -> int:
	return clampi(idx, 0, 9)
#endregion

#region Static Shortcut Methods
static func gray(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.GRAY, idx, reversed, a)


static func red(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.RED, idx, reversed, a)


static func pink(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.PINK, idx, reversed, a)


static func grape(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.GRAPE, idx, reversed, a)


static func violet(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.VIOLET, idx, reversed, a)


static func indigo(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.INDIGO, idx, reversed, a)


static func blue(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.BLUE, idx, reversed, a)


static func cyan(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.CYAN, idx, reversed, a)


static func teal(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.TEAL, idx, reversed, a)


static func green(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.GREEN, idx, reversed, a)


static func lime(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.LIME, idx, reversed, a)


static func yellow(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.YELLOW, idx, reversed, a)


static func orange(idx: int = DEFAULT_IDX, reversed: bool = false, a: float = 1.0) -> Color:
	return get_color(Type.ORANGE, idx, reversed, a)
#endregion

#region SubClasses
#endregion

#region Setter Methods
#endregion

#region Getter Methods
#endregion
