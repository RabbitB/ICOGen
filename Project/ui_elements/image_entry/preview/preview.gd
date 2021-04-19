tool
extends Control


export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

var _placeholder_texture

onready var _viewer: TextureRect = $Viewer as TextureRect


func _ready() -> void:
	_placeholder_texture = _viewer.texture

# warning-ignore:return_value_discarded
	ICOGen.get_signal_relay().connect_relay(
			"image_refreshed",
			ICOGen.get_active_data(),
			self,
			"_on_image_refreshed")


func clear_image() -> void:
	_viewer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_viewer.texture = _placeholder_texture


func _set_image_size(new_size: int) -> void:
	image_size = new_size
	_on_image_refreshed(image_size, self)


func _on_image_refreshed(for_size: int, _source: Object) -> void:
	if Engine.editor_hint:
		return

	if image_size == for_size:
		var active_data: ICOGenData = ICOGen.get_active_data()
		var texture: ImageTexture = ImageTexture.new()

		texture.create_from_image(active_data.get_image(image_size))
		_viewer.texture = texture
		_viewer.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED

