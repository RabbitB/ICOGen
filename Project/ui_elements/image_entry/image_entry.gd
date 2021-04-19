tool
extends Control


export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

onready var _sources: Control = $Container/Sources
onready var _preview: Control = $Container/Preview
onready var _interpolation: Control = $Container/Interpolation


func _set_image_size(new_size: int) -> void:
	image_size = new_size
	_sources.image_size = image_size
	_preview.image_size = image_size
	_interpolation.image_size = image_size

