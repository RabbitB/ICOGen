tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("ScriptClassDB", "res://addons/krakatoa/globals/script_class_db.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ScriptClassDB")

