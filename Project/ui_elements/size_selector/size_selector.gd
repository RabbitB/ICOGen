extends MenuButton


signal sizes_changed(size, is_checked)
onready var _menu: PopupMenu = get_popup()


func _ready():
# warning-ignore:return_value_discarded
	_menu.connect("index_pressed", self, "_on_menu_index_pressed")
	_menu.hide_on_checkable_item_selection = false


func set_checked(id: int, checked: bool) -> void:
	var idx: int = _menu.get_item_index(id)

	if _menu.is_item_checkable(idx):
		_menu.set_item_checked(idx, checked)
		emit_signal("sizes_changed", id, checked)


func get_checked() -> int:
	var checked_sizes: int = ICOGenData.ImageSize.NONE
	for idx in _menu.get_item_count():
		if _menu.is_item_checked(idx):
			checked_sizes |= _menu.get_item_id(idx)

	return checked_sizes


func uncheck_all() -> void:
	for idx in _menu.get_item_count():
		if _menu.is_item_checked(idx) && _menu.is_item_checkable(idx):
			_menu.set_item_checked(idx, false)
			emit_signal("sizes_changed", _menu.get_item_id(idx), false)


func _on_menu_index_pressed(idx: int) -> void:
	if _menu.is_item_checkable(idx):
		var is_checked: bool = _menu.is_item_checked(idx)
		_menu.set_item_checked(idx, !is_checked)

		emit_signal("sizes_changed", _menu.get_item_id(idx), !is_checked)

