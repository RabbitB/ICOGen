class_name SetBitIterator
#	Relevant (forward-iteration) code can be found in this stack-overflow answer:
#	https://stackoverflow.com/a/8898977/
#
#	Code was adapted from python to work as a GDScript custom iterator.
#
#	Reverse-iteration code is custom and makes use of a bit-reversal algorithm
#	that uses a lookup table. Taken from the famous Bit-Twiddling Hacks and
#	adapted to work for 64-bit integers.
#	http://graphics.stanford.edu/~seander/bithacks.html#BitReverseTable

#	How the bit-iteration works:

#	109 is .............. 0110 1101
#	~109 is -110 which is 1001 0010   NOTE: It's -110 instead of -109 because of 1's compliment
#	~109+1 is -109....... 1001 0011
#	109 AND ~109 is...... 0000 0001 = 1  <---- 1st value yielded by the generator
#	109 XOR 1 is......... 0110 1100 = n = 108

#	108.................. 0110 1100
#	~108+1= -108......... 1001 0100
#	108 AND -108......... 0000 0100 = 4  <---- 2nd value yielded by the generator
#	108 XOR 4............ 0110 1000 = n = 104

#	104.................. 0110 1000
#	~104+1............... 1001 1000
#	104 AND -104......... 0000 1000 = 8  <---- 3rd value yielded by the generator
#	104 XOR 8............ 0110 0000 = n = 96

#	96................... 0110 0000
#	~96+1................ 1010 0000
#	96 AND -96........... 0010 0000 = 32 <---- 4th value yielded by the generator
#	96 XOR 32............ 0100 0000 = n = 64

#	64................... 0100 0000
#	~64+1................ 1100 0000
#	64 AND -64........... 0100 0000 = 64 <---- 5th value yielded by the generator
#	64 XOR 64............ 0000 0000 = n = 0; thus, the while loop terminates.


enum {
	LSB_TO_MSB,
	MSB_TO_LSB,
}

const INT_BIT_COUNT: int = 64
const DEFAULT_ITER_DIRECTION: int = LSB_TO_MSB

const BIT_REVERSE_TABLE_256: Array = [
	0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0,
	0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8,
	0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4,
	0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC,
	0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2,
	0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA,
	0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6,
	0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE,
	0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1,
	0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9,
	0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5,
	0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD,
	0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3,
	0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB,
	0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7,
	0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF,
]

export(int, "LSB to MSB", "MSB to LSB") var direction: int = DEFAULT_ITER_DIRECTION

var bits: int

var _current_bit: int
var _bits_left: int


func _init(bits_to_iterate: int, iter_direction: int = DEFAULT_ITER_DIRECTION):
	bits = bits_to_iterate
	direction = iter_direction


func should_continue() -> bool:
	return _bits_left != 0


func _iter_init(arg) -> bool:
	_current_bit = 0
	_bits_left = bits if direction == LSB_TO_MSB else _reverse_bits(bits)

	return should_continue()


func _iter_next(arg) -> bool:
	_bits_left ^= _current_bit
	return should_continue()


func _iter_get(arg) -> int:
	_current_bit = _bits_left & (~_bits_left + 1)

	#	TODO: This can also be implemented using _reverse_bits(_current_bit),
	#	but as the current implementation off-loads the heavy work (log) to
	#	native code, my initial thought is that it would be faster than all
	#	the bit-operations performed in GDScript. Good opportunity for future
	#	code-profiling.

	#	If set to iterate from the most-significant to least-significant bit,
	#	then the order of the bits has already been reversed. This means to get
	#	the original value of each bit, we need to shift it back into its
	#	original bit-position. To do this, we calculate the position of the
	#	current bit and calculate its inverse position. The inverse bit position
	#	happens to be the same distance from the most-significant bit.
	if direction == MSB_TO_LSB:
		return 1 << ((INT_BIT_COUNT - 1) - int(log(_current_bit) / log(2)))

	return _current_bit


func _reverse_bits(to_reverse: int) -> int:
	return \
			(BIT_REVERSE_TABLE_256[to_reverse & 0xFF] << 56) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 8) & 0xFF] << 48) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 16) & 0xFF] << 40) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 24) & 0xFF] << 32) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 32) & 0xFF] << 24) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 40) & 0xFF] << 16) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 48) & 0xFF] << 8) | \
			(BIT_REVERSE_TABLE_256[(to_reverse >> 56) & 0xFF])

