class_name FullWindowFileDialog, "iconography/full_window_file_dialog.png"
extends PersistentFileDialog


enum ResizeMode {
	NO_RESIZE,
	EXPAND_ONLY_X,
	EXPAND_ONLY_Y,
	EXPAND_ONLY
	RESIZE_X,
	RESIZE_Y,
	RESIZE
}

export(ResizeMode) var resize_dialog: int = ResizeMode.NO_RESIZE
export(Vector2) var dialog_size: Vector2 = Vector2.ZERO

var _title_margin: int = get_stylebox("panel").expand_margin_top
var _orig_window_size: Vector2 = Vector2.ZERO
var _orig_window_pos: Vector2 = Vector2.ZERO
var _orig_window_min_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	self.connect("popup_hide", self, "_on_hide")
	self.connect("about_to_show", self, "_on_about_to_show_full_window")
	self.connect("item_rect_changed", self, "_on_resized_full_window")
	get_viewport().connect("size_changed", self, "_on_viewport_resized_full_window")


func popup_full_window():
	popup_centered()
	resize_to_viewport()


func resize_to_viewport() -> void:
	rect_size = get_viewport_rect().size - Vector2(0, _title_margin)
	rect_global_position = Vector2(0, _title_margin)


func _resize_window() -> void:
	if resize_dialog == ResizeMode.NO_RESIZE:
		return

	_orig_window_size = OS.window_size
	_orig_window_pos = OS.window_position
	_orig_window_min_size = OS.min_window_size

	var new_size: Vector2 = _orig_window_size
	match resize_dialog:
		ResizeMode.EXPAND_ONLY_X:
			new_size.x = max(new_size.x, dialog_size.x)
		ResizeMode.EXPAND_ONLY_Y:
			new_size.y = max(new_size.y, dialog_size.y)
		ResizeMode.EXPAND_ONLY:
			new_size.x = max(new_size.x, dialog_size.x)
			new_size.y = max(new_size.y, dialog_size.y)
		ResizeMode.RESIZE_X:
			new_size.x = dialog_size.x
		ResizeMode.RESIZE_Y:
			new_size.y = dialog_size.y
		ResizeMode.RESIZE:
			new_size = dialog_size

	var half_size_diff: Vector2 = (new_size - _orig_window_size) / 2.0
	OS.window_position -= half_size_diff
	OS.window_size = new_size
	OS.min_window_size = new_size


func _reset_window() -> void:
	if _orig_window_size != Vector2.ZERO:
		OS.window_position = _orig_window_pos
		OS.min_window_size = _orig_window_min_size
		OS.window_size = _orig_window_size

		_orig_window_size = Vector2.ZERO
		_orig_window_pos = Vector2.ZERO
		_orig_window_min_size = Vector2.ZERO


func _on_hide() -> void:
	_reset_window()


func _on_about_to_show_full_window() -> void:
	_resize_window()
	resize_to_viewport()


func _on_resized_full_window() -> void:
	resize_to_viewport()


func _on_viewport_resized_full_window() -> void:
	resize_to_viewport()

