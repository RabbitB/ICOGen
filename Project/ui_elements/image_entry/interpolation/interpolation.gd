tool
extends Control


export(ICOGenData.ImageSize) var image_size: int = ICOGenData.ImageSize.x16 setget _set_image_size

onready var _options: OptionButton = $Options as OptionButton
onready var _size_indicator: Label = $SizeIndicator as Label
onready var _is_ready: bool = true


func _ready() -> void:
# warning-ignore:return_value_discarded
	ICOGen.connect("active_data_changed", self, "_on_active_data_changed")

	_update_size_indicator()
	_update_options()


func _set_image_size(new_size: int) -> void:
	image_size = new_size

	_update_size_indicator()
	_update_options()


func _update_size_indicator() -> void:
	if _is_ready:
		_size_indicator.text = " %s" % ICOGenData.get_dimensions_string(image_size)


func _update_options() -> void:
	if _is_ready:
		_options.select(ICOGen.active_data.get_interpolation_mode(image_size))


func _on_Options_item_selected(index: int) -> void:
	ICOGen.active_data.set_interpolation_mode(image_size, index)


func _on_active_data_changed() -> void:
	_options.select(ICOGen.active_data.get_interpolation_mode(image_size))

