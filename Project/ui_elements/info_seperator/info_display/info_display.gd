extends Node


const InfoDialog: Script = preload("res://ui_elements/info_seperator/info_dialog/info_dialog.gd")

onready var _backdrop: Control = $Backdrop
onready var _info_dialog: InfoDialog = $Backdrop/InfoDialog


func show_info() -> void:
	_info_dialog.popup_centered_ratio(_info_dialog.window_size_ratio)


func _on_InfoDialog_about_to_show() -> void:
	_backdrop.visible = true


func _on_InfoDialog_popup_hide() -> void:
	_backdrop.visible = false

