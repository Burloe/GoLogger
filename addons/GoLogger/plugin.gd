@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("Log") 
