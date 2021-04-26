tool
extends Control


export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

var _placeholder_texture

onready var _viewer: TextureRect = $Viewer as TextureRect


func _ready() -> void:
	# warning-ignore:return_value_discarded
	ICOGen.get_signal_relay().connect_relay(
			"interpolation_mode_changed",
			ICOGen.get_active_data(),
			self,
			"_on_image_needs_update")

# warning-ignore:return_value_discarded
	ICOGen.get_signal_relay().connect_relay(
			"source_changed",
			ICOGen.get_active_data(),
			self,
			"_on_image_needs_update")

	# warning-ignore:return_value_discarded
	ICOGen.get_signal_relay().connect_relay(
			"source_override_changed",
			ICOGen.get_active_data(),
			self,
			"_on_image_needs_update")

	_placeholder_texture = _viewer.texture
	_set_image_size(image_size)


func clear_image() -> void:
	_viewer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_viewer.texture = _placeholder_texture


func _set_image_size(new_size: int) -> void:
	image_size = new_size

	if Engine.editor_hint:
		return

	var dimensions: int = ICOGenData.get_dimensions(new_size)
	_viewer.rect_min_size = Vector2(256, dimensions)

	_update_image(image_size, self)


func _update_image(for_size: int, _source: Object) -> void:
	if Engine.editor_hint:
		return

	if image_size == for_size:
		var active_data: ICOGenData = ICOGen.get_active_data()

		if active_data.has_no_sources():
			clear_image()
		else:
			var texture: ImageTexture = ImageTexture.new()
			texture.create_from_image(active_data.get_image(image_size))

			_viewer.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			_viewer.texture = texture


func _on_image_needs_update(for_size: int, _source: Object) -> void:
	if image_size == for_size:
		_update_image(image_size, self)

