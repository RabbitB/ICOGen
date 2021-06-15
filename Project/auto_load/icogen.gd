tool
extends Node


signal active_data_replaced()
signal active_data_changed()

const INT_MAX: int = 2^63 - 1
const MIN_WINDOW_SIZE: Vector2 = Vector2(350, 420)

var active_data: ICOGenData setget _set_active_data


func _init():
	self.active_data = ICOGenData.new()


func _ready() -> void:
	OS.min_window_size = MIN_WINDOW_SIZE


func _on_active_data_changed() -> void:
	emit_signal("active_data_changed")


func _set_active_data(new_data: ICOGenData) -> void:
	if active_data != null:
		active_data.disconnect("changed", self, "_on_active_data_changed")

	active_data = new_data

# warning-ignore:return_value_discarded
	active_data.connect("changed", self, "_on_active_data_changed")

	emit_signal("active_data_replaced")
	emit_signal("active_data_changed")

