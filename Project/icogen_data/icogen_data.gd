class_name ICOGenData
extends Resource


enum ImageSize {
	NONE = 0
	x8 = 1,
	x10 = 2,
	x14 = 4,
	x16 = 8,
	x22 = 16,
	x24 = 32,
	x32 = 64,
	x40 = 128,
	x48 = 256,
	x64 = 512,
	x96 = 1024,
	x128 = 2048,
	x256 = 4096,
}

enum InterpolationMode {
	NEAREST = 0,
	BILINEAR = 1,
	CUBIC = 2,
	TRILINEAR = 3,
	LANCZOS = 4,
}

const DEFAULT_INTERPOLATION_MODE: int = InterpolationMode.NEAREST

const N_ARY_TIMES_OPERATOR: String = char(10761)	# U+2A09

const SUPPORTED_EXTENSIONS: Dictionary = {
	"bmp": "load_bmp_from_buffer",
	"jpg": "load_jpg_from_buffer",
	"jpeg": "load_jpg_from_buffer",
	"png": "load_png_from_buffer",
	"tga": "load_tga_from_buffer",
	"webp": "load_webp_from_buffer",
}

var _output_sizes: int
var _source_images: Dictionary
var _source_map: Dictionary
var _source_overrides: Dictionary
var _interpolation_modes: Dictionary


func _init() -> void:
	_source_images = Dictionary()
	_source_map = Dictionary()
	_source_overrides = Dictionary()
	_interpolation_modes = Dictionary()

	for size in ImageSize.values():
		_source_map[size] = ImageSize.NONE
		_interpolation_modes[size] = DEFAULT_INTERPOLATION_MODE


func set_output_sizes(output_sizes: int) -> void:
	_output_sizes = output_sizes


func get_output_sizes() -> int:
	return _output_sizes


func add_output_sizes(output_sizes: int) -> void:
	_output_sizes |= output_sizes


func remove_output_sizes(output_sizes: int) -> void:
	_output_sizes &= ~output_sizes


func add_source_image(path: String, size_flag: int) -> int:
	var source_image: Image = Image.new()
	var err: int = _load_image_file(path, source_image)
	if err:
		return err

	source_image.take_over_path(path)
	_source_images[size_flag] = source_image
	_update_source_size_map()

	emit_changed()

	return OK


func remove_source_image(size_flag: int) -> void:
	if !_source_images.has(size_flag):
		return

# warning-ignore:return_value_discarded
	_source_images.erase(size_flag)
	_update_source_size_map()

	for override in _source_overrides:
		var override_with: int = _source_overrides[override]
		if override_with == size_flag:
			set_source_override(override, ImageSize.NONE)

	emit_changed()


func reset_image(size_flag: int) -> void:
	remove_source_image(size_flag)
	set_source_override(size_flag, ImageSize.NONE)
	set_interpolation_mode(size_flag, DEFAULT_INTERPOLATION_MODE)

	emit_changed()


func has_no_sources() -> bool:
	return _source_images.empty()


func get_image(size_flag: int) -> Image:
	if has_no_sources():
		return Image.new()

	var source_size: int = get_source_size(size_flag)
	var target_size: int = get_dimensions(size_flag)

	if source_size == ImageSize.NONE:
		Log.warning(
				"""There is no valid source image for image of size %d.
				Cannot generate a derived image.""",
				[target_size])
		return Image.new()

	return _create_square_image_keep_aspect_ratio(
			_source_images[source_size],
			target_size,
			get_interpolation_mode(size_flag))


func get_image_path(size_flag: int) -> String:
	return (_source_images.get(get_source_size(size_flag), Image.new()) as Image).resource_path


func get_source_size(size_flag: int) -> int:
	if has_source_override(size_flag):
		return get_source_override(size_flag)

	return _source_map[size_flag]


func image_is_source(size_flag: int) -> bool:
	return _source_images.has(size_flag)


func set_interpolation_mode(size_flag: int, mode: int) -> void:
	_interpolation_modes[size_flag] = mode
	emit_changed()


func get_interpolation_mode(size_flag: int) -> int:
	return _interpolation_modes[size_flag]


func set_source_override(for_size_flag: int, source_size_flag: int) -> void:
	if source_size_flag != ImageSize.NONE && !_source_images.has(source_size_flag):
		Log.error("No source defined for image of size %d",
				[get_dimensions(source_size_flag)])
		return

	_source_overrides[for_size_flag] = source_size_flag
	emit_changed()


func get_source_override(size_flag: int) -> int:
	return _source_overrides.get(size_flag, ImageSize.NONE)


func has_source_override(size_flag: int) -> bool:
	return _source_overrides.get(size_flag, ImageSize.NONE) != ImageSize.NONE


static func get_dimensions(size_flag: int) -> int:
	match size_flag:
		ImageSize.x8: return 8
		ImageSize.x10: return 10
		ImageSize.x14: return 14
		ImageSize.x16: return 16
		ImageSize.x22: return 22
		ImageSize.x24: return 24
		ImageSize.x32: return 32
		ImageSize.x40: return 40
		ImageSize.x48: return 48
		ImageSize.x64: return 64
		ImageSize.x96: return 96
		ImageSize.x128: return 128
		ImageSize.x256: return 256
		_: return 0


static func get_dimensions_string(size_flag: int) -> String:
	return "%s%d" % [N_ARY_TIMES_OPERATOR, get_dimensions(size_flag)]


func _create_square_image_keep_aspect_ratio(src_image: Image, target_size: int, interpolation_mode: int) -> Image:
	var src_width: int = src_image.get_width()
	var src_height: int = src_image.get_height()

	var intermediate_width: int = target_size
	var intermediate_height: int = target_size

	#	If the image is already square, we can just resize to the target size
	#	and continue without need for additional steps.
	if src_width == src_height:
		var output_image: Image = Image.new()
		output_image.copy_from(src_image)
		output_image.resize(target_size, target_size, interpolation_mode)

		return output_image
	elif src_width > src_height:
		var aspect_ratio: float = src_height / (src_width as float)
		intermediate_height = round(target_size * aspect_ratio) as int
	else:
		var aspect_ratio: float = src_width / (src_height as float)
		intermediate_width = round(target_size * aspect_ratio) as int

	var intermediate_image: Image = Image.new()
	intermediate_image.copy_from(src_image)
	intermediate_image.resize(intermediate_width, intermediate_height, interpolation_mode)

	var output_image: Image = Image.new()
	output_image.create(target_size, target_size, false, intermediate_image.get_format())

	var blit_region: Rect2 = intermediate_image.get_used_rect()
	_blit_and_center_rect(intermediate_image, output_image, blit_region)

	return output_image


func _blit_and_center_rect(src_image: Image, target_image: Image, src_rect: Rect2):
	if src_rect.size.x > target_image.get_width() || src_rect.size.y > target_image.get_height():
		Log.warning(
				"""Cannot blit from src to target image, because the desired
				rect to blit is larger than the target image.""")
		return

	var blit_pos: Vector2 = (target_image.get_size() - src_rect.size) / 2
	target_image.blit_rect(src_image, src_rect, blit_pos)


func _update_source_size_map() -> void:
	for size in _source_map:
		_source_map[size] = ImageSize.NONE

	if has_no_sources():
		return

	#	Find the size of the next larger source.
	var closest_matching_source_size: int = ImageSize.NONE
	var inverted_size_array: Array = ImageSize.values()
	inverted_size_array.invert()

	for size in inverted_size_array:
		if _source_images.has(size):
			closest_matching_source_size = size

		_source_map[size] = closest_matching_source_size

	#	Find the size of the next smaller source, for any sizes that don't
	#	have a larger source.
	for size in ImageSize.values():
		if _source_images.has(size):
			closest_matching_source_size = size

		if _source_map[size] == ImageSize.NONE:
			_source_map[size] = closest_matching_source_size


func _load_image_file(path: String, into_image: Image) -> int:
	var extension: String = path.get_extension()
	if !SUPPORTED_EXTENSIONS.has(extension):
		return ERR_FILE_UNRECOGNIZED

	var image_load_func: FuncRef = funcref(into_image, SUPPORTED_EXTENSIONS[extension])

	var file: File = File.new()
	var err: int = file.open(path, File.READ)
	if err:
		return err

	var image_buffer: PoolByteArray = file.get_buffer(file.get_len())
	file.close()

	err = image_load_func.call_func(image_buffer)
	if err:
		return err

	return OK

