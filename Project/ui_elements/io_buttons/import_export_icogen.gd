extends Control


signal should_import_icogen_file(path)
signal should_export_icogen_file(path)

onready var _import_file_dialog: FullWindowFileDialog = $ImportFileDialog
onready var _export_file_dialog: FullWindowFileDialog = $ExportFileDialog


func _on_ImportICOGen_pressed() -> void:
	_import_file_dialog.popup_full_window()


func _on_ExportICOGen_pressed() -> void:
	_export_file_dialog.popup_full_window()


func _on_ImportFileDialog_file_selected(path: String) -> void:
	emit_signal("should_import_icogen_file", path)


func _on_ExportFileDialog_file_selected(path: String) -> void:
	emit_signal("should_export_icogen_file", path)

