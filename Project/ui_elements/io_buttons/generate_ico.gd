extends Button


signal wants_to_save(path)

onready var _file_dialog: FullWindowFileDialog = $FileDialog


func _ready():
# warning-ignore:return_value_discarded
	ICOGen.connect("active_data_changed", self, "_on_ICOGen_active_data_changed")

# warning-ignore:return_value_discarded
	ICOGen.get_signal_relay().connect_relay(
			"source_changed",
			ICOGenData,
			self,
			"_on_source_changed")

	disabled = ICOGen.get_active_data().has_no_sources()


func _pressed() -> void:
	_file_dialog.popup_full_window()


func _on_ICOGen_active_data_changed() -> void:
	disabled = ICOGen.get_active_data().has_no_sources()


func _on_source_changed(_for_size: int, _source: Object) -> void:
	disabled = ICOGen.get_active_data().has_no_sources()


func _on_FileDialog_file_selected(path: String) -> void:
	emit_signal("wants_to_save", path)

