@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("res://addons/GoLogger/Dock/GoLoggerDock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")
	dock.plugin_version = get_plugin_version()
	dock.open_hotkey_resource.connect(_on_open_hotkey_resource)

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


func _on_open_hotkey_resource(resrc: int) -> void:
	var _r: String = ""
	match resrc:
		0: _r = "uid://n4t5k7np2380"  # Start Session Hotkey
		1: _r = "uid://gqn873em6x5v"  # Stop Session Hotkey
		2: _r = "uid://dqqknnyvnc7t6" # Copy Session Hotkey
	var res = ResourceLoader.load(_r)
	if res:
		get_editor_interface().edit_resource(res)
	else:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] Could not load resource: %s" % resrc)
