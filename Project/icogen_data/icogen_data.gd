class_name ICOGenData
extends Resource


signal interpolation_mode_changed(for_size)
signal source_changed(for_size)
signal source_override_changed(for_size)
signal image_refreshed(for_size)

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

const N_ARY_TIMES_OPERATOR: String = char(10761)	# U+2A09

const SUPPORTED_EXTENSIONS: Dictionary = {
	"bmp": "load_bmp_from_buffer",
	"jpg": "load_jpg_from_buffer",
	"jpeg": "load_jpg_from_buffer",
	"png": "load_png_from_buffer",
	"tga": "load_tga_from_buffer",
	"webp": "load_webp_from_buffer",
}

export (int, FLAGS, \
	"x8",
	"x10",
	"x14",
	"x16",
	"x22",
	"x24",
	"x32",
	"x40",
	"x48",
	"x64",
	"x96",
	"x128",
	"x256") var active_image_sizes: int setget _set_active_image_sizes

var _images: Dictionary


func _init() -> void:
	active_image_sizes = 0

	_images = Dictionary()
	for size in ImageSize.values():
		_images[size] = Dictionary()


func add_source_image(path: String, size_flag: int) -> int:
	var source_image: Image = Image.new()
	var err: int = _load_image_file(path, source_image)
	if err:
		return err

	_images[size_flag].source_image = source_image
	_images[size_flag].source_path = path

	_update_source_size_map()
	_refresh_all_images()

	emit_signal("source_changed", size_flag)

	return OK


func remove_source_image(size_flag: int) -> void:
	if !_images[size_flag].has("source_image"):
		Log.warning("No source image for image size %d was loaded. Cannot remove.",
				[get_dimensions(size_flag)])
		return

	_images[size_flag].erase("source_image")
	_images[size_flag].erase("source_path")

	_update_source_size_map()
	_refresh_all_images()

	emit_signal("source_changed", size_flag)


func get_image(size_flag: int) -> Image:
	if !_images[size_flag].has("derived_image"):
		Log.error("There is no image of size %d generated.",
				[get_dimensions(size_flag)])

	return _images[size_flag].get("derived_image", Image.new())


func get_image_path(size_flag: int) -> String:
	var source_size: int = _images[size_flag].source
	return _images[source_size].source_path


func image_is_source(size_flag: int) -> bool:
	return _images[size_flag].has("source_image")


func set_interpolation_mode(size_flag: int, mode: int) -> void:
	if \
			!_images[size_flag].has("interpolation_mode") || \
			_images[size_flag].interpolation_mode != mode:
		_images[size_flag].interpolation_mode = mode
		_refresh_image(size_flag)

		emit_signal("interpolation_mode_changed", size_flag)


func get_interpolation_mode(size_flag: int) -> int:
	return _images[size_flag].get("interpolation_mode", Image.INTERPOLATE_NEAREST)


func set_source_override(for_size_flag: int, source_size_flag: int) -> void:
	if !_images[source_size_flag].has("source_image"):
		Log.error("No source defined for image of size %d",
				[get_dimensions(source_size_flag)])
		return

	_images[for_size_flag].source_override = source_size_flag
	_refresh_image(for_size_flag)

	emit_signal("source_override_changed", for_size_flag)


func remove_source_override(size_flag: int) -> void:
	if _images[size_flag].erase("source_override"):
		_refresh_image(size_flag)
		emit_signal("source_override_changed", size_flag)


func get_source_override(size_flag: int) -> int:
	if !has_source_override(size_flag):
		Log.error("There is no source override for image of size %d",
				[get_dimensions(size_flag)])

	return _images[size_flag].get("source_override", ImageSize.NONE)


func has_source_override(size_flag: int) -> bool:
	return _images[size_flag].has("source_override")


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


func _refresh_image(size_flag: int) -> void:
	var derived_image_size: int = get_dimensions(size_flag)
	var derived_image: Image = Image.new()

	var source_size: int = _images[size_flag].get("source", ImageSize.NONE) if \
			!has_source_override(size_flag) else \
			_images[size_flag].source_override

	if source_size == ImageSize.NONE:
		Log.warning("There is no valid source image for image of size %d. Cannot generate a derived image.",
				[get_dimensions(size_flag)])
		return

	derived_image.copy_from(_images[source_size].source_image)
	derived_image.resize(
			derived_image_size,
			derived_image_size,
			get_interpolation_mode(size_flag))
	_images[size_flag].derived_image = derived_image

	emit_signal("image_refreshed", size_flag)


func _refresh_all_images() -> void:
	for size in ImageSize.values():
		_images[size].erase("derived_image")

		if size & active_image_sizes:
			_refresh_image(size)


func _update_source_size_map() -> void:
	#	Find the size of the next larger source.
	var closest_matching_source_size: int = ImageSize.NONE
	var inverted_size_array: Array = ImageSize.values()
	inverted_size_array.invert()

	for size in inverted_size_array:
		if _images[size].has("source_image"):
			closest_matching_source_size = size

		_images[size].source = closest_matching_source_size

	#	Find the size of the next smaller source, for sizes that don't have a next larger source.
	for size in ImageSize.values():
		if _images[size].has("source_image"):
			closest_matching_source_size = size

		if _images[size].source == ImageSize.NONE:
			_images[size].source = closest_matching_source_size


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


func _set_active_image_sizes(new_sizes: int) -> void:
	var changed_sizes: int = active_image_sizes ^ new_sizes
	var added_sizes: int = changed_sizes & new_sizes
	var removed_sizes: int = changed_sizes & active_image_sizes

	active_image_sizes = new_sizes

	for size in ImageSize.values():
		if size & removed_sizes:
			var image_is_source: bool = image_is_source(size)
			_images[size] = Dictionary()

			if image_is_source:
				_refresh_all_images()
				break
		elif size & added_sizes:
			_refresh_image(size)

