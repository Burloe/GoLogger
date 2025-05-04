@tool
extends EditorPlugin

var dock  



func _enter_tree() -> void:
	dock = preload("res://addons/GoLogger/Dock/GoLoggerDock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")
	dock.plugin_version = get_plugin_version()
	
func _exit_tree() -> void:
	dock.save_categories()
	remove_control_from_bottom_panel(dock)



func _enable_plugin() -> void:
	if !Engine.has_singleton("Log"):
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] plugin enabled! See [url]https://github.com/Burloe/GoLogger/wiki[/url] for more information.")
		add_autoload_singleton("Log", "res://addons/GoLogger/Log.tscn")
	
func _disable_plugin() -> void:
	if Engine.has_singleton("Log"):
		remove_autoload_singleton("Log") 