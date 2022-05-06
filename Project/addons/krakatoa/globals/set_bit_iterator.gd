class_name SetBitIterator
#	Relevant code can be found in this stack-overflow answer:
#	https://stackoverflow.com/a/8898977/
#	Code was adopted from python to work as a GDScript custom iterator

var bits: int

var _current_bit: int
var _bits_left: int


func _init(bits_to_iterate: int):
	bits = bits_to_iterate


func should_continue() -> bool:
	return _bits_left != 0


func _iter_init(arg) -> bool:
	_current_bit = 0
	_bits_left = bits
	return should_continue()


func _iter_next(arg) -> bool:
	_bits_left ^= _current_bit
	return should_continue()


func _iter_get(arg) -> int:
	_current_bit = _bits_left & (~_bits_left + 1)
	return _current_bit

