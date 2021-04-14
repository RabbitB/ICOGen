tool
extends Node


var _db: Dictionary
var _db_cache: Dictionary


func _init() -> void:
	_db = Dictionary()
	_db_cache = Dictionary()


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
		_db_cache[script_name] = Dictionary()

	return loaded_script


func add_class(script_name: String, script: Script) -> bool:
	if !_db.has(script.resource_path) && !_db.has(script_name):
		_db[script_name] = script
		_db[script.resource_path] = script_name
		_db_cache[script_name] = Dictionary()
		return true

	return false


func clear_cache(a_class: String = ""):
	if a_class.empty():
		for class_to_clear in _db_cache:
			_db_cache[class_to_clear] = Dictionary()
		return
	elif _db_cache.has(a_class):
		_db_cache[a_class] = Dictionary()

	return


func class_exists(a_class: String) -> bool:
	return _db.has(a_class)


func class_get_name(a_class: String) -> String:
	var retrieved_value = _db.get(a_class)
	if typeof(retrieved_value) == TYPE_STRING:
		return retrieved_value
	elif retrieved_value is Script:
		return a_class

	return ""


func class_get_script(a_class: String) -> Script:
	var retrieved_value = _db.get(a_class)
	if typeof(retrieved_value) == TYPE_STRING:
		return _db[retrieved_value]

	return retrieved_value


func class_get_integer_constant(a_class: String, constant_name: String) -> int:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return 0

	var class_script: Script = _db.get(a_class)
	var constant_map: Dictionary

	var base_script: Script = class_script
	while base_script != null:
		constant_map = base_script.get_script_constant_map()
		if constant_map.has(constant_name):
			return constant_map[constant_name]

		base_script = base_script.get_base_script()

	return ClassDB.class_get_integer_constant(
			class_script.get_instance_base_type(),
			constant_name)


func class_get_integer_constant_list(a_class: String, no_inheritance: bool = false) -> Array:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_inheritance:
		if _db_cache[a_class].has("int_const_list_no_inheritance"):
			return _db_cache[a_class].int_const_list_no_inheritance

		var int_const_list: Array = class_script.get_script_constant_map().keys()

		_db_cache[a_class].int_const_list_no_inheritance = int_const_list
		return int_const_list
	else:
		if _db_cache[a_class].has("int_const_list"):
			return _db_cache[a_class].int_const_list

		var all_constants: Array = class_script.get_script_constant_map().keys()
		var base_class: Script = class_script.get_base_script()
		while base_class != null:
			all_constants += base_class.get_script_constant_map().keys()
			base_class = base_class.get_base_script()

		var native_base_type: String = class_script.get_instance_base_type()
		all_constants += Array(ClassDB.class_get_integer_constant_list(native_base_type))

		_db_cache[a_class].int_const_list = all_constants
		return all_constants


func class_get_method_list(a_class: String, no_native_inheritance: bool = false) -> Array:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		if _db_cache[a_class].has("method_list_no_inheritance"):
			return _db_cache[a_class].method_list_no_inheritance

		var method_list: Array = class_script.get_script_method_list()

		_db_cache[a_class].method_list_no_inheritance = method_list
		return method_list
	else:
		if _db_cache[a_class].has("method_list"):
			return _db_cache[a_class].method_list

		#	The docs don't make it clear, but get_script_method_list returns
		#	all methods including from inherited scripts, but not from native
		#	inherited classes.
		var all_methods: Array = class_script.get_script_method_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_methods += ClassDB.class_get_method_list(native_base_type)

		_db_cache[a_class].method_list = all_methods
		return all_methods


func class_get_property_list(a_class: String, no_native_inheritance: bool = false) -> Array:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		if _db_cache[a_class].has("property_list_no_inheritance"):
			return _db_cache[a_class].property_list_no_inheritance

		var property_list: Array = class_script.get_script_property_list()

		_db_cache[a_class].property_list_no_inheritance = property_list
		return property_list
	else:
		if _db_cache[a_class].has("property_list"):
			return _db_cache[a_class].property_list

		#	The docs don't make it clear, but get_script_property_list returns
		#	all properties including from inherited scripts, but not from native
		#	inherited classes.
		var all_props: Array = class_script.get_script_property_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_props += ClassDB.class_get_property_list(native_base_type)

		_db_cache[a_class].property_list = all_props
		return all_props


func class_get_signal(a_class: String, signal_name: String) -> Dictionary:
	a_class = class_get_name(a_class)
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
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return []

	var class_script: Script = _db.get(a_class)
	if no_native_inheritance:
		if _db_cache[a_class].has("signal_list_no_inheritance"):
			return _db_cache[a_class].signal_list_no_inheritance

		var signal_list: Array = class_script.get_script_signal_list()

		_db_cache[a_class].signal_list_no_inheritance = signal_list
		return signal_list
	else:
		if _db_cache[a_class].has("signal_list"):
			return _db_cache[a_class].signal_list

		#	The docs don't make it clear, but get_script_signal_list returns
		#	all signals including from inherited scripts, but not from native
		#	inherited classes.
		var all_signals: Array = class_script.get_script_signal_list()
		var native_base_type: String = class_script.get_instance_base_type()

		all_signals += ClassDB.class_get_signal_list(native_base_type)

		_db_cache[a_class].signal_list = all_signals
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
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return false

	var class_script: Script = _db.get(a_class)
	if class_script.has_script_signal(signal_name):
		return true

	return ClassDB.class_has_signal(class_script.get_instance_base_type(), signal_name)


func get_class_list() -> Array:
	var classes: Array = []
	for a_class in _db:
		if _db[a_class] is Script:
			classes.append(a_class)

	return classes


func get_inheriters_from_class(a_class: String) -> Array:
	a_class = class_get_name(a_class)
	var inheriters: Array = []

	if !_db.has(a_class):
		return inheriters

	for other_class in _db:
		if \
				_db[other_class] is Script && \
				a_class != other_class && \
				is_parent_class(other_class, a_class):
			inheriters.append(other_class)

	return inheriters


func get_parent_class(a_class: String, return_native_parent: bool = true) -> String:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return ""

	var class_script: Script = _db.get(a_class)
	var parent_class: Script = class_script.get_base_script()
	if parent_class != null:
		return _db.get(_db.get(parent_class.resource_path, ""), "")
	elif return_native_parent:
		return class_script.get_instance_base_type()

	return ""


func get_native_parent_class(a_class: String) -> String:
	a_class = class_get_name(a_class)
	if !_db.has(a_class):
		return ""

	return _db.get(a_class).get_instance_base_type()


func is_parent_class(a_class: String, ancestor: String) -> bool:
	a_class = class_get_name(a_class)
	ancestor = class_get_name(ancestor)

	if !_db.has(a_class) || !_db.has(ancestor):
		return false

	var class_script: Script = _db.get(a_class)
	var ancestor_script: Script = _db.get(ancestor)

	while class_script != null:
		if ancestor_script == class_script:
			return true
		class_script = class_script.get_base_script()

	return false

