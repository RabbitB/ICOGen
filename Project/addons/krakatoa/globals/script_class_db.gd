tool
extends Node


var _db: Dictionary


func _init() -> void:
	_db = Dictionary()


func load(script_name: String, script_path: String) -> Script:
	if _db.has(script_path):
		return _db[_db[script_path]]

	if _db.has(script_name):
		assert(false, "A class named %s already exists with another script" % script_name)
		Log.error("A class named %s already exists with another script", [script_name])

	var loaded_script: Script = load(script_path)
	assert(loaded_script != null, "%s is not a valid path to a script." % script_path)

	if loaded_script != null:
		_db[script_name] = loaded_script
		_db[script_path] = script_name

	return loaded_script


func add_class(script_name: String, script: Script) -> void:
	if !_db.has(script.resource_path) && !_db.has(script_name):
		_db[script_name] = script
		_db[script.resource_path] = script_name
	else:
		assert(false, "Class %s is already in the database." % script_name)
		Log.error("Class %s is already in the database", [script_name])


func class_exists(a_class: String) -> bool:
	return _db.has(a_class)


func class_get_integer_constant(a_class: String, constant_name: String) -> int:
	if !_db.has(a_class):
		return 0

	var class_script: Script = _db.get(a_class)
	var constant_map: Dictionary

	while class_script != null:
		constant_map = class_script.get_script_constant_map()
		if constant_map.has(constant_name):
			return constant_map[constant_name]

		class_script = class_script.get_base_script()

	return ClassDB.class_get_integer_constant(
			_db.get(a_class).get_instance_base_type(),
			constant_name)


func class_get_integer_constant_list(a_class: String, no_inheritance: bool = false) -> Array:
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_inheritance:
		return class_script.get_script_constant_map().keys()
	else:
		var all_constants: Array = class_script.get_script_constant_map().keys()
		var base_class: Script = class_script.get_base_script()
		while base_class != null:
			all_constants += base_class.get_script_constant_map().keys()
			base_class = base_class.get_base_script()

		var native_base_type: String = class_script.get_instance_base_type()
		all_constants += Array(ClassDB.class_get_integer_constant_list(native_base_type))

		return all_constants


func class_get_method_list(a_class: String, no_native_inheritance: bool = false) -> Array:
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		return class_script.get_script_method_list()
	else:
		#	The docs don't make it clear, but get_script_method_list returns
		#	all methods including from inherited scripts, but not from native
		#	inherited classes.
		var all_methods: Array = class_script.get_script_method_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_methods += ClassDB.class_get_method_list(native_base_type)

		return all_methods


func class_get_property_list(a_class: String, no_native_inheritance: bool = false) -> Array:
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		return class_script.get_script_property_list()
	else:
		#	The docs don't make it clear, but get_script_property_list returns
		#	all properties including from inherited scripts, but not from native
		#	inherited classes.
		var all_props: Array = class_script.get_script_property_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_props += ClassDB.class_get_property_list(native_base_type)

		return all_props


func class_get_signal(a_class: String, signal_name: String) -> Dictionary:
	if !_db.has(a_class):
		return {}

	#	The docs don't make it clear, but get_script_signal_list returns
	#	all signals including from inherited scripts, but not from native
	#	inherited classes.
	var class_script: Script = _db.get(a_class)
	if class_script.has_script_signal(signal_name):
		for signal_info in class_script.get_script_signal_list():
			if signal_info.name == signal_name:
				return signal_info

	return ClassDB.class_get_signal(class_script.get_instance_base_type(), signal_name)


func class_get_signal_list(a_class: String, no_native_inheritance: bool = false) -> Array:
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		return class_script.get_script_signal_list()
	else:
		#	The docs don't make it clear, but get_script_signal_list returns
		#	all signals including from inherited scripts, but not from native
		#	inherited classes.
		var all_signals: Array = class_script.get_script_signal_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_signals += ClassDB.class_get_signal_list(native_base_type)

		return all_signals


func class_has_integer_constant(a_class: String, constant_name: String) -> bool:
	var constant_list: Array = class_get_integer_constant_list(a_class)
	return constant_list.has(constant_name)


func class_has_method(
		a_class: String,
		method_name: String,
		no_native_inheritance: bool = false) -> bool:
	var method_list: Array = class_get_method_list(a_class, no_native_inheritance)
	for method in method_list:
		if method.name == method_name:
			return true

	return false


func class_has_signal(a_class: String, signal_name: String) -> bool:
	if !_db.has(a_class):
		return false

	var class_script: Script = _db.get(a_class)
	if class_script.has_script_signal(signal_name):
		return true

	return ClassDB.class_has_signal(class_script.get_instance_base_type(), signal_name)


func get_class_list() -> Array:
	return _db.keys()


func get_inheriters_from_class(a_class: String) -> Array:
	var inheriters: Array = []
	if !_db.has(a_class):
		return inheriters

	for other_class in _db.keys:
		if a_class != other_class && is_parent_class(other_class, a_class):
			inheriters.append(other_class)

	return inheriters


func get_parent_class(a_class: String, return_native_parent: bool = true) -> String:
	if !_db.has(a_class):
		return ""

	var class_script: Script = _db.get(a_class)
	var parent_class: Script = class_script.get_base_script()
	if parent_class != null:
		return _db.get(_db.get(parent_class.resource_path, ""), "")
	elif return_native_parent:
		return class_script.get_instance_base_type()

	return ""


func is_parent_class(a_class: String, ancestor: String) -> bool:
	if !_db.has(a_class) || !_db.has(ancestor):
		return false

	var class_script: Script = _db.get(a_class)
	var ancestor_script: Script = _db.get(ancestor)

	while class_script != null:
		if ancestor_script == class_script:
			return true
		class_script = class_script.get_base_script()

	return false

