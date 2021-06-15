extends Button


signal wants_to_save(path)

onready var _file_dialog: FullWindowFileDialog = $FileDialog


func _ready():
# warning-ignore:return_value_discarded
	ICOGen.connect("active_data_changed", self, "_on_active_data_changed")
	disabled = ICOGen.active_data.has_no_sources()


func _pressed() -> void:
	_file_dialog.popup_full_window()


func _on_active_data_changed() -> void:
	disabled = ICOGen.active_data.has_no_sources()


func _on_FileDialog_file_selected(path: String) -> void:
	emit_signal("wants_to_save", path)

