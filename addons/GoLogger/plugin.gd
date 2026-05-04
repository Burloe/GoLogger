@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	print_rich("[color=fc4674][font_size=12][GoLogger][color=white] plugin enabled! See [url]https://github.com/Burloe/GoLogger/wiki[/url] for more information.")
	dock = preload("uid://0k0tpsfqof2s").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")
	dock.plugin_version = get_plugin_version()
	dock.renable_btn.button_up.connect(
		func() -> void:
			_exit_tree()
			_enter_tree()
	)



func _exit_tree() -> void:
	dock.save_data()
	remove_control_from_bottom_panel(dock)




func _enable_plugin() -> void:
	if !Engine.has_singleton("Log"):
		# print_rich("[color=fc4674][font_size=12][GoLogger][color=white] plugin enabled! See [url]https://github.com/Burloe/GoLogger/wiki[/url] for more information.")
		add_autoload_singleton("Log", "res://addons/gologger/scenes/log.tscn")



func _disable_plugin() -> void:
	if Engine.has_singleton("Log"):
		remove_autoload_singleton("Log")



