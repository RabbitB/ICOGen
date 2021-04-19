tool
class_name ClassInfo
extends Reference


enum {
	UNKNOWN,
	BUILT_IN,
	SCRIPT_DB,
	LOOSE_SCRIPT
}

var _class: String
var _type: int
var _script: Script


func _init(from_class) -> void:
	match typeof(from_class):
		TYPE_STRING:
			if ScriptClassDB.class_exists(from_class):
				_class = ScriptClassDB.class_get_name(from_class)
				_script = ScriptClassDB.class_get_script(from_class)
				_type = SCRIPT_DB
			elif ClassDB.class_exists(from_class):
				_class = from_class
				_type = BUILT_IN
			else:
				_class = from_class
				_script = load(from_class)
				_type = UNKNOWN if _script == null else LOOSE_SCRIPT
		TYPE_OBJECT:
			var obj_script: Script = from_class.get_script() if \
					!(from_class is Script) else from_class

			if obj_script == null:
				_class = from_class.get_class()
				_type = BUILT_IN
			elif ScriptClassDB.class_exists(obj_script.resource_path):
				_class = ScriptClassDB.class_get_name(obj_script.resource_path)
				_script = obj_script
				_type = SCRIPT_DB
			else:
				_class = obj_script.resource_name
				_script = obj_script
				_type = LOOSE_SCRIPT


func get_type() -> int:
	return _type


func get_class_name() -> String:
	return _class


func get_script() -> Script:
	return _script


func inherits_from(ancestor: ClassInfo) -> bool:
	match _type:
		BUILT_IN:
			return ancestor.get_type() == BUILT_IN && \
					ClassDB.is_parent_class(_class, ancestor.get_class_name())
		SCRIPT_DB:
			match ancestor.get_type():
				BUILT_IN:
					return ClassDB.is_parent_class(
							_script.get_instance_base_type(),
							ancestor.get_class_name())
				SCRIPT_DB:
					return ScriptClassDB.is_parent_class(
							_class,
							ancestor.get_class_name())
				LOOSE_SCRIPT:
					var base_script: Script = _script
					while base_script != null:
						if base_script == ancestor.get_script():
							return true
						base_script = base_script.get_base_script()

					return false
				_:
					return false
		LOOSE_SCRIPT:
			match ancestor.get_type():
				BUILT_IN:
					return ClassDB.is_parent_class(
							_script.get_instance_base_type(),
							ancestor.get_class_name())
				SCRIPT_DB, LOOSE_SCRIPT:
					var base_script: Script = _script
					while base_script != null:
						if base_script == ancestor.get_script():
							return true
						base_script = base_script.get_base_script()

					return false
				_:
					return false
		_:
			return false


func has_signal(signal_name: String) -> bool:
	match _type:
		BUILT_IN:
			return ClassDB.class_has_signal(_class, signal_name)
		SCRIPT_DB:
			return ScriptClassDB.class_has_signal(_class, signal_name)
		LOOSE_SCRIPT:
			if _script.has_script_signal(signal_name):
				return true

			return ClassDB.class_has_signal(_script.get_instance_base_type(), signal_name)
		_:
			return false


func get_signal(signal_name: String) -> Dictionary:
	match _type:
		BUILT_IN:
			return ClassDB.class_get_signal(_class, signal_name)
		SCRIPT_DB:
			return ScriptClassDB.class_get_signal(_class, signal_name)
		LOOSE_SCRIPT:
			for signal_info in _script.get_script_signal_list():
				if signal_info.name == signal_name:
					return signal_info

			for signal_info in _script.get_signal_list():
				if signal_info.name == signal_name:
					return signal_info

			return {}
		_:
			return {}

