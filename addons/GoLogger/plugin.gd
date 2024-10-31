@tool
extends EditorPlugin

var dock 


func _enter_tree() -> void:
	add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")
	dock = preload("res://addons/GoLogger/Dock/GoLoggerDock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")

func _exit_tree() -> void:
	remove_autoload_singleton("Log") 
	remove_control_from_bottom_panel(dock)
