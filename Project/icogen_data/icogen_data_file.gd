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

	var file_contents: String = file.get_as_text()
	file.close()

	var json_results: JSONParseResult = JSON.parse(file_contents)
	if json_results.error:
		return json_results.error

	if !json_results.result is Dictionary:
		return ERR_INVALID_DATA

	var formatted_data: Dictionary = json_results.result as Dictionary
	selected_image_sizes = formatted_data.get("selected_sizes", [])

	var icogen: ICOGenData = ICOGenData.new()
	for source_size in formatted_data.source_image_paths:
		err = icogen.add_source_image(formatted_data.source_image_paths[source_size], source_size)
		if err:
			Log.error("When loading the ICOGen file saved at %s, encountered error %s when attempting to load the source image for size %d, from file %s. This source image will be skipped." % \
					[path,
					Log.get_error_description(err),
					ICOGenData.get_dimensions(source_size),
					formatted_data.source_image_paths[source_size]])

	for source_size in formatted_data.source_overrides:
		icogen.set_source_override(source_size, formatted_data.source_overrides[source_size])

	for source_size in formatted_data.interpolation_modes:
		icogen.set_interpolation_mode(source_size, formatted_data.interpolation_modes[source_size])

	icogen_data = icogen
	return OK


func save(path: String, selected_sizes: Array, data: ICOGenData) -> int:
	var formatted_data: Dictionary = data.get_serialized_data()

	# If the source images are in the same directory as this file, or in a nested
	# directory, then save a relative path. If saved elsewhere to disk, save an
	# absolute path.
	for size in formatted_data.source_image_paths:
		var source_path: String = formatted_data.source_image_paths[size]
		formatted_data.source_image_paths[size] = source_path.trim_prefix(path.get_base_dir())

	formatted_data.selected_sizes = selected_sizes
	var json_output: String = JSON.print(formatted_data, "\t")

	var file: File = File.new()
	var err: int = file.open(path, File.WRITE)
	if err:
		return err

	file.store_string(json_output)
	file.close()

	return OK

