tool
class_name ClassInfo
extends Reference


static func is_built_in_class(type) -> bool:
	match typeof(type):
		TYPE_STRING:
			return ClassDB.class_exists(type)
		TYPE_OBJECT:
			return type.get_script() == null

	return false


static func get_built_in_class(type) -> String:
	match typeof(type):
		TYPE_STRING:
			if ScriptClassDB.class_exists(type):
				return ScriptClassDB.get_native_parent_class(type)

			return type if ClassDB.class_exists(type) else ""
		TYPE_OBJECT:
			if type is Script:
				return type.get_instance_base_type()

			return type.get_class()

	return ""


static func class_inherits_from(a_class, ancestor) -> bool:
	if a_class is Script:
		return script_inherits_from(a_class, ancestor)
	elif typeof(a_class) == TYPE_STRING:
		if is_built_in_class(a_class):
			return is_built_in_class(ancestor) && \
					ClassDB.is_parent_class(a_class, get_built_in_class(ancestor))
		else:
			var class_script: Script = load(a_class)
			if class_script == null:
				assert(false, "%s is an invalid script path" % a_class)
				return false

			return script_inherits_from(class_script, ancestor)
	elif typeof(a_class) == TYPE_OBJECT:
		var class_script: Script = a_class.get_script()
		if class_script == null:
			return is_built_in_class(ancestor) && \
					ClassDB.is_parent_class(a_class, get_built_in_class(ancestor))

		return script_inherits_from(class_script, ancestor)

	return false


static func script_inherits_from(a_class: Script, ancestor) -> bool:
	if ancestor is Script:
		return script_inherits_from_script(a_class, ancestor as Script)
	elif typeof(ancestor) == TYPE_STRING:
		if ClassDB.class_exists(ancestor):
			return ClassDB.is_parent_class(a_class.get_instance_base_type(), ancestor)
		else:
			var ancestor_script: Script = load(ancestor)
			if ancestor_script == null:
				assert(false, "%s is an invalid script path" % ancestor)
				return false

			return script_inherits_from_script(a_class, ancestor_script)
	elif typeof(ancestor) == TYPE_OBJECT:
		var ancestor_script: Script = ancestor.get_script()
		if ancestor_script == null:
			return ClassDB.is_parent_class(a_class.get_instance_base_type(), ancestor.get_class())
		else:
			return script_inherits_from_script(a_class, ancestor_script)

	return false


static func script_inherits_from_script(a_script: Script, ancestor: Script) -> bool:
	var base_script: Script = a_script.get_base_script()
	while base_script != null:
		if ancestor == base_script:
			return true
		base_script = base_script.get_base_script()

	return false


static func class_has_signal(for_class, signal_name: String) -> bool:
	if for_class is Script:
		return script_has_signal(for_class, signal_name)
	elif typeof(for_class) == TYPE_STRING:
		if ClassDB.class_exists(for_class):
			return ClassDB.class_has_signal(for_class, signal_name)
		else:
			var class_script: Script = load(for_class)
			if class_script == null:
				assert(false, "%s is an invalid script path" % for_class)
				return false

			return script_has_signal(class_script, signal_name)
	elif typeof(for_class) == TYPE_OBJECT:
		return for_class.has_signal(signal_name)

	return false


static func script_has_signal(for_script: Script, signal_name: String) -> bool:
	if for_script.has_script_signal(signal_name):
		return true

	return ClassDB.class_has_signal(for_script.get_instance_base_type(), signal_name)


static func class_get_signal(from_class, signal_name: String) -> Dictionary:
	if from_class is Script:
		return script_get_signal(from_class, signal_name)
	elif typeof(from_class) == TYPE_STRING:
		if ClassDB.class_exists(from_class):
			return ClassDB.class_get_signal(from_class, signal_name)
		else:
			var class_script: Script = load(from_class)
			if class_script == null:
				assert(false, "%s is an invalid script path" % from_class)
				return {}

			return script_get_signal(class_script, signal_name)
	elif typeof(from_class) == TYPE_OBJECT:
		for signal_info in from_class.get_signal_list():
			if signal_info.name == signal_name:
				return signal_info

	return {}


static func script_get_signal(from_script: Script, signal_name: String) -> Dictionary:
	if from_script.has_script_signal(signal_name):
		for signal_info in from_script.get_script_signal_list():
			if signal_info.name == signal_name:
				return signal_info

	return ClassDB.class_get_signal(from_script.get_instance_base_type(), signal_name)

