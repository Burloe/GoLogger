@tool
extends EditorPlugin

var dock 
var icon = preload("res://addons/GoLogger/GoLogger_Icon_Flat.svg")


func _enter_tree() -> void:
	add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")
	dock = preload("res://addons/GoLogger/Dock/GoLoggerDock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")

func _exit_tree() -> void:
	dock.save_categories()
	remove_autoload_singleton("Log") 
	remove_control_from_bottom_panel(dock)
