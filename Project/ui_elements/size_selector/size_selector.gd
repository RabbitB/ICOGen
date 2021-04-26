extends MenuButton


signal image_sizes_changed(size, is_checked)

export(ICOGenData.ImageSize, FLAGS) var default_sizes

onready var _menu: PopupMenu = get_popup()


func _ready():
# warning-ignore:return_value_discarded
	ScriptClassDB.add_class("SizeSelector", get_script())
	ICOGen.get_signal_relay().add_relay("image_sizes_changed", self)

	_setup_menu_btn()
	_select_default_items()


func get_checked() -> Array:
	var checked_sizes: Array = []
	for idx in _menu.get_item_count():
		if _menu.is_item_checked(idx):
			checked_sizes.append(_menu.get_item_id(idx))

	return checked_sizes


func _setup_menu_btn() -> void:
# warning-ignore:return_value_discarded
	_menu.connect("index_pressed", self, "_on_menu_index_pressed")
	_menu.hide_on_checkable_item_selection = false

	_menu.add_separator("STANDARD")
	_menu.add_check_item("x16", 8)
	_menu.add_check_item("x32", 64)
	_menu.add_check_item("x48", 256)
	_menu.add_check_item("x256", 4096)

	_menu.add_separator("EXTENDED")
	_menu.add_check_item("x24", 32)
	_menu.add_check_item("x64", 512)
	_menu.add_check_item("x96", 1024)
	_menu.add_check_item("x128", 2048)

	_menu.add_separator("SPECIALIZED")
	_menu.add_check_item("x8", 1)
	_menu.add_check_item("x10", 2)
	_menu.add_check_item("x14", 4)
	_menu.add_check_item("x22", 16)
	_menu.add_check_item("x40", 128)


func _select_default_items() -> void:
	var _corrected_defaults: int
	for size in ICOGenData.ImageSize.values():
		# The export FLAGS command doesn't actually match the original flag enum,
		# but instead starts from 1. This requires us to double the size value.
		if default_sizes & (size * 2):
			var item_idx: int = _menu.get_item_index(size)
			_menu.set_item_checked(item_idx, true)

			_corrected_defaults = _corrected_defaults | size
			emit_signal("image_sizes_changed", size, true)


func _on_menu_index_pressed(idx: int) -> void:
	if _menu.is_item_checkable(idx):
		var is_checked: bool = _menu.is_item_checked(idx)
		_menu.set_item_checked(idx, !is_checked)

		emit_signal("image_sizes_changed", _menu.get_item_id(idx), !is_checked)

