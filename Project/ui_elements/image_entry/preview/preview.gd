tool
extends Control


export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

onready var _viewer: TextureRect = $Viewer as TextureRect


func _set_image_size(new_size: int) -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()
	image_size = new_size

	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(active_data.get_image(image_size))
	_viewer.texture = texture

