@tool
extends EditorPlugin

var dock

var start_session_hotkey := preload("uid://n4t5k7np2380")
var stop_session_hotkey := preload("uid://gqn873em6x5v")
var copy_session_hotkey := preload("uid://dqqknnyvnc7t6")


func _enter_tree() -> void:
	dock = preload("res://addons/GoLogger/Dock/GoLoggerDock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")
	dock.plugin_version = get_plugin_version()

func _exit_tree() -> void:
	dock.save_data()
	remove_control_from_bottom_panel(dock)



func _enable_plugin() -> void:
	if !Engine.has_singleton("Log"):
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] plugin enabled! See [url]https://github.com/Burloe/GoLogger/wiki[/url] for more information.")
		add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")

func _disable_plugin() -> void:
	if Engine.has_singleton("Log"):
		remove_autoload_singleton("Log")


func _on_open_hotkey_resource(resrc: String) -> void:
	var res = ResourceLoader.load(resrc)
	if res:
		get_editor_interface().edit_resource(res)
	else:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] Could not load resource: %s" % resrc)
