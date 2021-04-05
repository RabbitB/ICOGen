extends Node


const INT_MAX: int = 2^63 - 1
const MIN_WINDOW_SIZE: Vector2 = Vector2(271, 0)


var _active_data: ICOGenData
var _signal_relay: SignalRelay


func _init():
	_active_data = ICOGenData.new()
	_signal_relay = SignalRelay.new()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE && _signal_relay != null:
		_signal_relay.free()
		_signal_relay = null


func _ready() -> void:
	OS.min_window_size = MIN_WINDOW_SIZE
	_setup_relays()


func get_signal_relay() -> SignalRelay:
	return _signal_relay


func get_active_data() -> ICOGenData:
	return _active_data


func set_active_data(new_data: ICOGenData) -> void:
	_active_data = new_data


func _setup_relays() -> void:
	for size in ICOGenData.ImageSize.values():
		var size_tag: String = ICOGenData.get_dimensions_string(size)

		_signal_relay.add_relay("interpolation_mode_changed", _active_data, size_tag)
		_signal_relay.add_relay("source_changed", _active_data, size_tag)
		_signal_relay.add_relay("source_override_changed", _active_data, size_tag)
		_signal_relay.add_relay("image_refreshed", _active_data, size_tag)

