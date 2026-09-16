@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("uid://0k0tpsfqof2s").instantiate() as EditorDock
	dock.title = "GDLogger"
	dock.dock_icon = preload("uid://c4jrvdxu1e2q3")
	add_dock(dock)
	dock.plugin_version = get_plugin_version()
	for i in [dock.renable_btn1, dock.renable_btn2]:
		if i: i.button_up.connect(_renable_plugin) 



func _exit_tree() -> void: 
	remove_dock(dock)
	dock.queue_free()
	dock = null



func _enable_plugin() -> void:
	if !Engine.has_singleton("Log"):
		add_autoload_singleton("Log", "res://addons/gdlogger/scenes/log.tscn")



func _disable_plugin() -> void:
	if Engine.has_singleton("Log"):
		remove_autoload_singleton("Log")



func _renable_plugin() -> void: 
	_exit_tree()
	_enter_tree()