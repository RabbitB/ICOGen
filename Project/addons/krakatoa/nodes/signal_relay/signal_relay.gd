tool
class_name SignalRelay, "iconography/signal_relay_icon.png"
extends Node


const RelayProxy: Script = preload("relay_proxy.gd")

var _relays: Dictionary


func _init() -> void:
	_relays = Dictionary()


func connect_relay(
		signal_name: String,
		class_hint: String,
		target: Object,
		method: String,
		binds: Array = [],
		flags: int = 0,
		tag: String = "") -> int:
	var relay_name: String = RelayProxy.get_proxy_name(signal_name, tag)

	if !_relays.has(relay_name):
		_relays[relay_name] = []

	for relay in _relays[relay_name]:
		if relay.matches_signal(signal_name, class_hint, tag):
			return relay.connect(relay_name, target, method, binds, flags)

	var new_relay: RelayProxy = RelayProxy.new(signal_name, tag, class_hint)
	var err: int = new_relay.connect(relay_name, target, method, binds, flags)
	_relays[relay_name].append(new_relay)

	return err


func disconnect_relay(
		signal_name: String,
		class_hint: String,
		target: Object,
		method: String,
		for_tag: String = "") -> void:
	var relay_name: String = RelayProxy.get_proxy_name(signal_name, for_tag)
	for relay in _relays.get(relay_name, []):
		if relay.matches_signal(signal_name, class_hint, for_tag):
			relay.disconnect(signal_name, target, method)


func add_relay(signal_name: String, source: Object, tag: String = "") -> void:
	var relay_name: String = RelayProxy.get_proxy_name(signal_name, tag)
	var source_class: String = source.get_class()

	if !_relays.has(relay_name):
		_relays[relay_name] = []

	var match_found: bool = false
	var relay_list: Array = _relays[relay_name]
	for relay in relay_list:
		if relay.matches_signal(signal_name, source_class, tag):
			relay.add_relay(source)

			match_found = true
			break

	if !match_found:
		var new_relay: RelayProxy = RelayProxy.new(signal_name, tag)
		new_relay.add_relay(source)
		relay_list.append(new_relay)


func remove_relay(signal_name: String, source: Object, tag: String = "") -> void:
	var relay_name: String = RelayProxy.get_proxy_name(signal_name, tag)
	var source_class: String = source.get_class()

	if !_relays.has(relay_name):
		return

	var found_relay: RelayProxy
	var relay_list: Array = _relays[relay_name]
	for relay in relay_list:
		if relay.matches_signal(signal_name, source_class, tag):
			found_relay = relay
			break

	relay_list.erase(found_relay)

