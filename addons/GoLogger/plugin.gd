@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GoLogger", "res://addons/GoLogger/GoLogger.tscn")



func _exit_tree() -> void:
	remove_autoload_singleton("GoLogger") 
