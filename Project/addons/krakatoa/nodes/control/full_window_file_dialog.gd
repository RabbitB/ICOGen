class_name FullWindowFileDialog, "iconography/full_window_file_dialog.png"
extends PersistentFileDialog


var _title_margin: int = get_stylebox("panel").expand_margin_top


func _ready() -> void:
	self.connect("about_to_show", self, "_on_about_to_show_full_window")
	self.connect("item_rect_changed", self, "_on_resized_full_window")
	get_viewport().connect("size_changed", self, "_on_viewport_resized_full_window")


func popup_full_window():
	popup_centered()
	resize_to_viewport()


func resize_to_viewport() -> void:
	rect_size = get_viewport_rect().size - Vector2(0, _title_margin)
	rect_global_position = Vector2(0, _title_margin)


func _on_about_to_show_full_window() -> void:
	resize_to_viewport()


func _on_resized_full_window() -> void:
	resize_to_viewport()


func _on_viewport_resized_full_window() -> void:
	resize_to_viewport()

