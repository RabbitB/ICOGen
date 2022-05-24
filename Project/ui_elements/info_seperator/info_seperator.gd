extends Control


const InfoDisplay: Script = preload("res://ui_elements/info_seperator/info_display/info_display.gd")

onready var info_display: InfoDisplay = $InfoDisplay as InfoDisplay


func _on_GetInfoButton_pressed() -> void:
	info_display.show_info()

