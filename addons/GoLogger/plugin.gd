@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("uid://0k0tpsfqof2s").instantiate()
	add_control_to_bottom_panel(dock, "GoLogger")
	dock.plugin_version = get_plugin_version()
	for i in [dock.renable_btn1, dock.renable_btn2, dock.renable_btn3]:
		if i: i.button_up.connect(_renable_plugin) 



func _exit_tree() -> void:
	# dock.save_data()
	remove_control_from_bottom_panel(dock)



func _enable_plugin() -> void:
	if !Engine.has_singleton("Log"):
		add_autoload_singleton("Log", "res://addons/gologger/scenes/log.tscn")



func _disable_plugin() -> void:
	if Engine.has_singleton("Log"):
		remove_autoload_singleton("Log")



func _renable_plugin() -> void:
	if dock.dev_mode:
		_exit_tree()
		_enter_tree()