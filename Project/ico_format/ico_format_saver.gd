class_name ICOFormatSaver
extends ResourceFormatSaver
#	See https://en.wikipedia.org/wiki/ICO_(file_format) for additional info
#	on the ICO file format.


const FILE_EXT: String = "ico"


func get_recognized_extensions(resource: Resource) -> PoolStringArray:
	if resource is ICOGenData:
		return PoolStringArray([FILE_EXT])
	return PoolStringArray()


func recognize(resource: Resource) -> bool:
	return resource is ICOGenData


func save(path: String, resource: Resource, _flags: int) -> int:
	#	Flags are not implemented since this is an external file-format and
	#	follows a defined format that we don't have control over.
	var file: File = File.new()

	var err: int = file.open(path, File.WRITE)
	if err:
		return err

	var icogen_data: ICOGenData = resource as ICOGenData

	var output_image_count: int = 0
	var output_images: Dictionary = {}
	var output_image_buffers: Dictionary = {}
	var output_image_offsets: Dictionary = {}

	var output_sizes: SetBitIterator = SetBitIterator.new(icogen_data.get_output_sizes())
	for size in output_sizes:
		output_image_count += 1
		output_images[size] = icogen_data.get_image(size)
		output_image_buffers[size] = output_images[size].save_png_to_buffer()

	#	The initial offset for the first image is the size of the header, plus
	#	the size of an image entry multiplied by the number of images.
	var previous_image_byte_offset: int = 6 + (output_image_count * 16)
	for size in output_sizes:
		output_image_offsets[size] = previous_image_byte_offset
		previous_image_byte_offset += output_image_buffers[size].size()

	#	Write the ICONDIR Header
	#	OFFSET	SIZE		PURPOSE
	#	0		2			Reserved. Must always be 0.
	#	2		2			Specifies image type: 1 for icon (.ICO) image,
	#						2 for cursor (.CUR) image. Other values are invalid.
	#	4		2			Specifies the number of images in the file.
	file.store_16(0)
	file.store_16(1)
	file.store_16(output_image_count)

	#	Write each ICONDIRENTRY in the ICONDIR
	#	OFFSET	SIZE		PURPOSE
	#	0		1			Specifies image width in pixels.
	#	1		1			Specifies image height in pixels.
	#						Width & height can be any number between 0 and
	#						255. Value 0 means a dimension of 256 pixels.
	#	2		1			Specifies number of colors in the color palette.
	#						Should be 0 if image doesn't use a color palette.
	#	3		1			Reserved. Should be 0.
	#	4		2			ICO: Specifies color planes. Should be 0 or 1.
	#						CUR: Specifies the horizontal coords of the hotspot in pixels from the left.
	#	6		2			ICO: Specifies the bits per pixel.
	#						CUR: Specifies the vertical coords of the hotspot in pixels from the top.
	#	8		4			Specifies the size of the image's data in bytes.
	#	12		4			Specifies the offset of the image data from the beginning of the file.
	for size in output_sizes:
		var img_width: int = output_images[size].get_width()
		var img_height: int = output_images[size].get_height()
		var bits_per_pixel: int = ((output_image_buffers[size].size() as float) / (img_width * img_height) * 8) as int

		if img_width > 255:
			img_width = 0

		if img_height > 255:
			img_height = 0

		file.store_8(img_width)
		file.store_8(img_height)
		file.store_8(0)
		file.store_8(0)
		file.store_16(1)
		file.store_16(bits_per_pixel)
		file.store_32(output_image_buffers[size].size())
		file.store_32(output_image_offsets[size])

	#	Write each output-image into the ICO file
	for size in output_sizes:
		file.store_buffer(output_image_buffers[size])

	return OK

