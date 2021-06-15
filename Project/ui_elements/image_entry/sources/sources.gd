tool
extends Control


const OPTIONS_BEST_MATCH_IDX = 0

export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

onready var _file_dialog: FullWindowFileDialog = $FileDialog as FullWindowFileDialog
onready var _options: OptionButton = $Options as OptionButton
onready var _select_file: TextureButton = $SelectFile as TextureButton
onready var _remove_file: TextureButton = $RemoveFile as TextureButton


func _ready() -> void:
# warning-ignore:return_value_discarded
	ICOGen.connect("active_data_changed", self, "_on_active_data_changed")


func _update_options() -> void:
	_options.clear()

	# This size has an explicit source image, which means we display its path
	# and don't allow the user to select different options.
	if ICOGen.active_data.image_is_source(image_size):
		var image_path: String = ICOGen.active_data.get_image_path(image_size)
		var display_path: String = image_path.get_file()

		_options.add_item(display_path)
		_options.set_item_id(0, ICOGenData.ImageSize.NONE)

		_options.select(0)
		_options.disabled = true

	# There isn't a source image uploaded for this size, so we allow the user
	# to select from an automatic "best match" or from any other available source.
	else:
		_options.add_item("BEST MATCH")
		_options.set_item_id(OPTIONS_BEST_MATCH_IDX, ICOGenData.ImageSize.NONE)

		for size in ICOGenData.ImageSize.values():
			if ICOGen.active_data.image_is_source(size):
				_options.add_item("x%d" % ICOGenData.get_dimensions(size))
				_options.set_item_id(_options.get_item_count() - 1, size)
		_options.disabled = false

		var override_id: int = ICOGen.active_data.get_source_override(image_size)
		var override_idx = _options.get_item_index(override_id)

		_options.select(override_idx)


func _update_file_buttons() -> void:
	var image_is_source: bool = ICOGen.active_data.image_is_source(image_size)

	_select_file.visible = !image_is_source
	_remove_file.visible = image_is_source


func _set_image_size(new_size: int) -> void:
	image_size = new_size

	_update_options()
	_update_file_buttons()


func _on_Options_item_selected(index: int) -> void:
	var selected_size: int = _options.get_item_id(index)
	ICOGen.active_data.set_source_override(image_size, selected_size)


func _on_SelectFile_pressed() -> void:
	_file_dialog.popup_full_window()


func _on_RemoveFile_pressed() -> void:
	ICOGen.active_data.remove_source_image(image_size)

	_update_options()
	_update_file_buttons()


func _on_FileDialog_file_selected(path: String) -> void:
	var err: int = ICOGen.active_data.add_source_image(path, image_size)
	if err:
		Log.error("Could not add '%s' as a source; encountered error: %s" %
				[path, Log.get_error_description(err)])

	_update_options()
	_update_file_buttons()


func _on_active_data_changed() -> void:
	_update_options()
	_update_file_buttons()

