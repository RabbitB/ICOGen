tool
extends Control


const OPTIONS_BEST_MATCH_IDX = 0

export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

onready var _file_dialog: FullWindowFileDialog = $FileDialog as FullWindowFileDialog
onready var _options: OptionButton = $Options as OptionButton
onready var _select_file: TextureButton = $SelectFile as TextureButton
onready var _remove_file: TextureButton = $RemoveFile as TextureButton


func _update_options() -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()
	var orig_selected_size: int = _options.get_selected_id()

	_options.clear()

	# This size has an explicit source image, which means we display its path
	# and don't allow the user to select different options.
	if active_data.image_is_source(image_size):
		var image_path: String = active_data.get_image_path(image_size)
		var display_path: String = "%s" % image_path.get_file()

		_options.add_item(display_path)
		_options.set_item_id(0, ICOGenData.ImageSize.NONE)

		_options.select(0)
		_options.disabled = true

	# There isn't a source image uploaded for this size, so we allow the user
	# to select from an automatic "best match" or from any other available source.
	else:
		_options.add_item("BEST MATCH")
		_options.set_item_id(0, ICOGenData.ImageSize.NONE)

		for size in ICOGenData.ImageSize.values():
			if size & active_data.active_image_sizes && active_data.image_is_source(size):
				_options.add_item(ICOGenData.get_dimensions_string(size))
				_options.set_item_id(_options.get_item_count() - 1, size)
		_options.disabled = false

		var idx_for_orig_size: int = _options.get_item_index(orig_selected_size)
		if idx_for_orig_size == -1:
			_options.select(OPTIONS_BEST_MATCH_IDX)
		else:
			_options.select(idx_for_orig_size)

	_on_Options_item_selected(_options.selected)


func _update_file_buttons() -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()
	var image_is_source: bool = active_data.image_is_source(image_size)

	_select_file.visible = !image_is_source
	_remove_file.visible = image_is_source


func _set_image_size(new_size: int) -> void:
	image_size = new_size

	_update_options()
	_update_file_buttons()


func _on_Options_item_selected(index: int) -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()

	var selected_size: int = _options.get_item_id(index)
	if selected_size == ICOGenData.ImageSize.NONE:
		active_data.remove_source_override(selected_size)
	else:
		active_data.set_source_override(image_size, selected_size)


func _on_SelectFile_pressed() -> void:
	_file_dialog.popup_full_window()


func _on_RemoveFile_pressed() -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()
	active_data.remove_source_image(image_size)

	_update_file_buttons()
	_update_options()


func _on_FileDialog_file_selected(path: String) -> void:
	var active_data: ICOGenData = ICOGen.get_active_data()
	var err: int = active_data.add_source_image(path, image_size)
	if err:
		Log.error("Could not add '%s' as a source; encountered error: %s" %
				[path, Log.get_error_description(err)])

	_update_file_buttons()
	_update_options()

