class_name ICOGenDataFormatSaver
extends ResourceFormatSaver


#	VERSION 1.0 FILE FORMAT
#	byte			bool: false for little-endian, true for big-endian
#	pascal_str		File Version
#	byte			CompressionMode: Compression type used on serialized data
#	byte[8]			Compressed serialized data size (read and discarded for uncompressed data)
#	byte[8]			Uncompressed serialized data size
#	byte_buffer		Serialized data. Serialized as a dictionary and converted into a byte buffer.
#					Compressed using the previously stored compression mode.


const NO_COMPRESSION: int = 255
const CURR_VERSION: String  = "1.0.0"
const FILE_EXT: String = "icogen"


func get_recognized_extensions(resource: Resource) -> PoolStringArray:
	if resource is ICOGenData:
		return PoolStringArray([FILE_EXT])
	return PoolStringArray()


func recognize(resource: Resource) -> bool:
	return resource is ICOGenData


func save(path: String, resource: Resource, flags: int) -> int:
	#	Only flags that would change the contents of this file are implemented.
	#	The others are simply ignored.
	var serialized_data: Dictionary = _serialize(resource as ICOGenData)
	var file: File = File.new()

	var err: int = file.open(path, File.WRITE)
	if err:
		return err

	if flags & ResourceSaver.FLAG_SAVE_BIG_ENDIAN:
		file.endian_swap = true

	var byte_data: PoolByteArray = var2bytes(serialized_data)

	file.store_8(file.endian_swap)
	file.store_pascal_string(CURR_VERSION)
	if flags & ResourceSaver.FLAG_COMPRESS:
		var compressed_data: PoolByteArray = byte_data.compress(File.COMPRESSION_FASTLZ)
		file.store_8(File.COMPRESSION_FASTLZ)
		file.store_64(compressed_data.size())
		file.store_64(byte_data.size())
		file.store_buffer(compressed_data)
	else:
		file.store_8(NO_COMPRESSION)
		file.store_64(byte_data.size())
		file.store_64(byte_data.size())
		file.store_buffer(byte_data)

	file.close()

	if flags & ResourceSaver.FLAG_CHANGE_PATH:
		resource.take_over_path(path)

	return OK


static func _serialize(icogen_data: ICOGenData) -> Dictionary:
	var serialized_data: Dictionary = {}

	serialized_data.source_image_paths = {}
	for size in icogen_data._source_images:
		serialized_data.source_image_paths[size] = icogen_data._source_images[size].resource_path

	serialized_data.output_sizes = icogen_data.get_output_sizes()
	serialized_data.source_overrides = icogen_data._source_overrides
	serialized_data.interpolation_modes = icogen_data._interpolation_modes

	return serialized_data

