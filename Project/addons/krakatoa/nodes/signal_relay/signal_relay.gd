tool
class_name SignalRelay, "iconography/signal_relay_icon.png"
extends Node


var _relays_to_connect: Dictionary


func _init() -> void:
	_relays_to_connect = Dictionary()


func connect_relay(
		signal_name: String,
		target: Object,
		method: String,
		binds: Array = [],
		flags: int = 0,
		filter_by_tag: String = "") -> int:

	var user_signal_name: String = _user_signal_name(signal_name, filter_by_tag)
	if !has_user_signal(user_signal_name):
		var connection_list: Array = _relays_to_connect.get(user_signal_name, Array())
		connection_list.append(
				{
					"target": weakref(target),
					"method": method,
					"binds": binds,
					"flags": flags
				})

		_relays_to_connect[user_signal_name] = connection_list
	else:
		return connect(user_signal_name, target, method, binds, flags)

	return OK


func disconnect_relay(
		signal_name: String,
		target: Object,
		method: String,
		for_tag: String = "") -> void:

	var user_signal_name: String = _user_signal_name(signal_name, for_tag)
	if !has_user_signal(user_signal_name):
		var connection_list: Array = _relays_to_connect.get(user_signal_name, Array())

		var found_at_index: int = -1
		var idx: int = 0
		for connection in connection_list:
			if connection.target.get_ref() == target && connection.method == method:
				found_at_index = idx
				break
			else:
				idx += 1

		if found_at_index != -1:
			connection_list.remove(found_at_index)
			_relays_to_connect[user_signal_name] = connection_list
	else:
		disconnect(user_signal_name, target, method)


func add_relay(signal_name: String, source: Object, tag: String = "") -> void:
	if !source.has_signal(signal_name):
		Log.error(
				"Object of type '%s' has no signal named '%s'",
				[source.get_class(), signal_name])
		return

	var args_info: Array
	for signal_info in source.get_signal_list():
		if signal_info.name == signal_name:
			args_info = signal_info.args
			break

	var args_count: int = args_info.size()
	if args_count > 10:
		Log.error(
				"SignalRelay doesn't support over 10 arguments per signal. Signal '%s' has %d arguments.",
				[signal_name, args_count])
		return

	# Every relayed signal will include the original source of the signal.
	args_info.append({ "name": "source", "type": TYPE_OBJECT })

	var callback_name: String = "_proxy_callback_%d" % args_count
	if !source.is_connected(signal_name, self, callback_name):
		source.connect(
				signal_name,
				self,
				callback_name,
				[signal_name, weakref(source), tag])

	_try_add_user_signal(signal_name, args_info, tag)

	# Go through the list of every object that tried to connect to this relay
	# before the relay itself was added, and attempt to connect them now.
	var user_signal_name: String = _user_signal_name(signal_name, tag)
	if _relays_to_connect.has(user_signal_name):
		for relay in _relays_to_connect[user_signal_name]:
			var target: Object = relay.target.get_ref()

			# This target has since been freed and there's no longer a reason
			# to try and connect it to a relay.
			if !is_instance_valid(target):
				continue

			connect(user_signal_name, target, relay.method, relay.binds, relay.flags)

		_relays_to_connect.erase(user_signal_name)


func remove_relay(signal_name: String, source: Object, tag: String = "") -> void:
	if !source.has_signal(signal_name):
		Log.error(
				"Object of type '%s' has no signal named '%s'",
				[source.get_class(), signal_name])
		return

	var args_count: int = -1
	for signal_info in source.get_signal_list():
		if signal_info.name == signal_name:
			args_count = signal_info.args.size()
			break

	if args_count == -1:
		Log.error(
				"SignalRelay encountered an unexpected error trying to read the number of arguments for signal '%s' on object of class '%s'.",
				[signal_name, source.get_class()])
		return

	var proxy_callback_name: String = "_proxy_callback_%d" % args_count
	if source.is_connected(signal_name, self, proxy_callback_name):
		source.disconnect(signal_name, self, proxy_callback_name)


func _try_add_user_signal(name: String, args: Array = [], tag: String = ""):
	var user_signal_name: String = _user_signal_name(name, tag)
	if has_user_signal(user_signal_name):
		return

	add_user_signal(user_signal_name, args)


func _user_signal_name(signal_name: String, tag: String = ""):
	return "%s_%s" % [tag, signal_name]


func _proxy_callback_0(
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(_user_signal_name(signal_name, tag), source.get_ref())


func _proxy_callback_1(
		arg_0,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(_user_signal_name(signal_name, tag), arg_0, source.get_ref())


func _proxy_callback_2(
		arg_0, arg_1,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1,
			source.get_ref())


func _proxy_callback_3(
		arg_0, arg_1, arg_2,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2,
			source.get_ref())


func _proxy_callback_4(
		arg_0, arg_1, arg_2, arg_3,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3,
			source.get_ref())


func _proxy_callback_5(
		arg_0, arg_1, arg_2, arg_3, arg_4,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4,
			source.get_ref())


func _proxy_callback_6(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5,
			source.get_ref())


func _proxy_callback_7(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6,
			source.get_ref())


func _proxy_callback_8(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7,
			source.get_ref())


func _proxy_callback_9(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8,
			source.get_ref())


func _proxy_callback_10(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, arg_9,
		signal_name: String,
		source: WeakRef,
		tag: String) -> void:
	emit_signal(
			_user_signal_name(signal_name, tag),
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, arg_9,
			source.get_ref())

