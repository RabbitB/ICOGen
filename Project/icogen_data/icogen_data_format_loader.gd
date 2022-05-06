class_name ICOGenDataFormatLoader
extends ResourceFormatLoader


func get_recognized_extensions() -> PoolStringArray:
	return PoolStringArray([ICOGenDataFormatSaver.FILE_EXT])


func get_resource_type(path: String) -> String:
	return "Resource" if path.get_extension() == ICOGenDataFormatSaver.FILE_EXT else ""


func handles_type(typename: String) -> bool:
	return typename == "ICOGenData" || typename == "Resource"


func load(path: String, _original_path: String):
	if path.get_extension() != ICOGenDataFormatSaver.FILE_EXT:
		return ERR_FILE_UNRECOGNIZED

	var file: File = File.new()
	var err: int = file.open(path, File.READ)
	if err:
		return err

	file.endian_swap = file.get_8()
	#	This is the file version string. We currently only have one version
	#	and can safely discard this for now. If there are future revisions,
	#	we'll need to capture this and use it to determine how to load the file.
# warning-ignore:return_value_discarded
	file.get_pascal_string()

	var compression_mode: int = file.get_8()
	var compressed_size: int = file.get_64()
	var uncompressed_size: int = file.get_64()
	var uncompressed_data: PoolByteArray

	if compression_mode != ICOGenDataFormatSaver.NO_COMPRESSION:
		uncompressed_data = \
				file.get_buffer(compressed_size).decompress(uncompressed_size, compression_mode)
	else:
		uncompressed_data = file.get_buffer(uncompressed_size)

	file.close()
	return _deserialize(bytes2var(uncompressed_data))


static func _deserialize(serialized_data: Dictionary) -> ICOGenData:
	var icogen_data: ICOGenData = ICOGenData.new()

	icogen_data.set_output_sizes(serialized_data.output_sizes)

	for size in serialized_data.source_image_paths:
		var source_path: String = serialized_data.source_image_paths[size]
		var err: int = icogen_data.add_source_image(source_path, size)
		if err:
			Log.error(
					"""Encountered error %s when attempting to load source image
					for size %d, from file %s. This source image will be skipped.""",
					[Log.get_error_description(err),
					ICOGenData.get_dimensions(size),
					source_path])

	for size in serialized_data.source_overrides:
		icogen_data.set_source_override(size, serialized_data.source_overrides[size])

	for size in serialized_data.interpolation_modes:
		icogen_data.set_interpolation_mode(size, serialized_data.interpolation_modes[size])

	return icogen_data

