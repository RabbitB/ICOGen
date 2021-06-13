class_name ICOGenDataFile
extends Reference


var selected_image_sizes: Array
var icogen_data: ICOGenData


func _init() -> void:
	selected_image_sizes = []
	icogen_data = null


func load(path: String) -> int:
	var file: File = File.new()
	var err: int = file.open(path, File.READ)
	if err:
		return err

	var formatted_data: Dictionary = file.get_var()
	file.close()

	selected_image_sizes = formatted_data.get("selected_sizes", [])

	var icogen: ICOGenData = ICOGenData.new()
	var source_image_paths: Dictionary = formatted_data.get("source_image_paths", {})
	var source_overrides: Dictionary = formatted_data.get("source_overrides", {})
	var interpolation_modes: Dictionary = formatted_data.get("interpolation_modes", {})

	for source_size in source_image_paths:
		err = icogen.add_source_image(source_image_paths[source_size], source_size)

		if err:
			Log.error(
					"When loading the ICOGen file saved at %s, encountered " \
					+ "error %s when attempting to load the source image for " \
					+ "size %d, from file %s. This source image will be skipped.",
					[path,
					Log.get_error_description(err),
					ICOGenData.get_dimensions(source_size),
					source_image_paths[source_size]])

	for source_size in source_overrides:
		icogen.set_source_override(source_size, source_overrides[source_size])

	for source_size in interpolation_modes:
		icogen.set_interpolation_mode(source_size, interpolation_modes[source_size])

	icogen_data = icogen
	return OK


static func save(path: String, selected_sizes: Array, data: ICOGenData) -> int:
	var formatted_data: Dictionary = data.get_serialized_data()

	# If the source images are in the same directory as this file, or in a nested
	# directory, then save a relative path. If saved elsewhere to disk, save an
	# absolute path.
	for size in formatted_data.source_image_paths:
		var source_path: String = formatted_data.source_image_paths[size]
		formatted_data.source_image_paths[size] = source_path.trim_prefix(path.get_base_dir())

	formatted_data.selected_sizes = selected_sizes

	var file: File = File.new()
	var err: int = file.open(path, File.WRITE)
	if err:
		return err

	file.store_var(formatted_data)
	file.close()

	return OK

