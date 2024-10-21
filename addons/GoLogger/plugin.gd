@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")
	if !Log.disable_welcome_print: print(str("GoLogger version 1.1 loaded(https://github.com/Burloe/GoLogger).")) 



func _exit_tree() -> void:
	remove_autoload_singleton("Log") 
