tool
extends Reference


var proxy_name: String setget _read_only_property
var signal_name: String setget _read_only_property
var tag: String setget _read_only_property
var class_hint: ClassInfo setget _read_only_property

var _callback_name: String


func _init(for_signal: String, with_tag: String, for_class = null) -> void:
	signal_name = for_signal
	tag = with_tag

	proxy_name = get_proxy_name(signal_name, tag)

	if for_class != null:
		_setup_signals(for_class)


func add_relay(source: Object) -> void:
	var class_info: ClassInfo = ClassInfo.new(source)
	if !source.has_signal(signal_name):
		Log.error(
				"Object of type %s has no signal named %s",
				[class_info.get_class_name(), signal_name])
		return

	if class_hint == null:
		_setup_signals(source)
	elif !class_info.inherits_from(class_hint):
		Log.error(
				"This SignalProxy is already setup to relay signal %s on class %s. Cannot relay a different signal with the same name from class %s. Please create a new SignalProxy.",
				[signal_name, class_hint.get_class_name(), class_info.get_class_name()])

	if !source.is_connected(signal_name, self, _callback_name):
		source.connect(signal_name, self, _callback_name, [weakref(source)])


func matches_signal(other_signal: String, from_class, for_tag: String) -> bool:
	if other_signal != signal_name:
		return false

	if for_tag != tag:
		return false

	var class_info: ClassInfo = ClassInfo.new(from_class)
	return class_info.inherits_from(class_hint)


static func get_proxy_name(name: String, tag: String) -> String:
	return "%s_%s" % [tag, name]


func _setup_signals(for_class) -> void:
	var class_info: ClassInfo = ClassInfo.new(for_class)
	if !class_info.has_signal(signal_name):
		Log.error("Class %s has no signal named %s", [class_info.get_class_name(), signal_name])
		return

	var args_info: Array = class_info.get_signal(signal_name).args
	var args_count: int = args_info.size()

	if args_count > 10:
		Log.error(
				"SignalRelay and RelayProxy support a max of 10 arguments per signal. Signal %s has %d arguments.",
				[signal_name, args_count])
		return

	# Every relayed signal will include the original source of the signal.
	args_info.append({ "name": "source", "type": TYPE_OBJECT })

	_callback_name = "_proxy_callback_%d" % args_count
	class_hint = class_info

	add_user_signal(proxy_name, args_info)


func _proxy_callback_0(source: WeakRef) -> void:
	emit_signal(proxy_name, source.get_ref())


func _proxy_callback_1(arg_0, source: WeakRef) -> void:
	emit_signal(proxy_name, arg_0, source.get_ref())


func _proxy_callback_2(arg_0, arg_1, source: WeakRef) -> void:
	emit_signal(proxy_name, arg_0, arg_1, source.get_ref())


func _proxy_callback_3(arg_0, arg_1, arg_2, source: WeakRef) -> void:
	emit_signal(proxy_name, arg_0, arg_1, arg_2, source.get_ref())


func _proxy_callback_4(arg_0, arg_1, arg_2, arg_3, source: WeakRef) -> void:
	emit_signal(proxy_name, arg_0, arg_1, arg_2, arg_3, source.get_ref())


func _proxy_callback_5(
		arg_0, arg_1, arg_2, arg_3, arg_4,
		source: WeakRef) -> void:
	emit_signal(proxy_name, arg_0, arg_1, arg_2, arg_3, arg_4, source.get_ref())


func _proxy_callback_6(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5,
		source: WeakRef) -> void:
	emit_signal(
			proxy_name,
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5,
			source.get_ref())


func _proxy_callback_7(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6,
		source: WeakRef) -> void:
	emit_signal(
			proxy_name,
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6,
			source.get_ref())


func _proxy_callback_8(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7,
		source: WeakRef) -> void:
	emit_signal(
			proxy_name,
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7,
			source.get_ref())


func _proxy_callback_9(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8,
		source: WeakRef) -> void:
	emit_signal(
			proxy_name,
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8,
			source.get_ref())


func _proxy_callback_10(
		arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, arg_9,
		source: WeakRef) -> void:
	emit_signal(
			proxy_name,
			arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, arg_9,
			source.get_ref())


func _read_only_property(value) -> void:
	assert(true, "Attempted to write to a read-only property of SignalProxy.")
	return

