extends MenuButton


signal image_sizes_changed(size, is_checked)

onready var _menu: PopupMenu = get_popup()


func _ready():
	_setup_menu_btn()
	ICOGen.get_signal_relay().add_relay("image_sizes_changed", self)


func _setup_menu_btn() -> void:
# warning-ignore:return_value_discarded
	_menu.connect("index_pressed", self, "_on_menu_index_pressed")
	_menu.hide_on_checkable_item_selection = false

	_menu.add_separator("STANDARD")
	_menu.add_check_item("x16", 16)
	_menu.add_check_item("x32", 32)
	_menu.add_check_item("x48", 48)
	_menu.add_check_item("x256", 256)

	_menu.add_separator("EXTENDED")
	_menu.add_check_item("x24", 24)
	_menu.add_check_item("x64", 64)
	_menu.add_check_item("x96", 96)
	_menu.add_check_item("x128", 128)

	_menu.add_separator("SPECIALIZED")
	_menu.add_check_item("x8", 8)
	_menu.add_check_item("x10", 10)
	_menu.add_check_item("x14", 14)
	_menu.add_check_item("x22", 22)
	_menu.add_check_item("x40", 40)


func _on_menu_index_pressed(idx: int) -> void:
	if _menu.is_item_checkable(idx):
		var is_checked: bool = _menu.is_item_checked(idx)
		_menu.set_item_checked(idx, !is_checked)

		emit_signal("image_sizes_changed", _menu.get_item_id(idx), !is_checked)

