@tool
extends EditorPlugin

var dock
var gdl_ico = preload("uid://bch3ujgyd4vth")

func _enter_tree() -> void:
	dock = preload("uid://0k0tpsfqof2s").instantiate() as EditorDock
	dock.title = "GDLogger"
	# dock.dock_icon = preload("uid://bch3ujgyd4vth")
	add_dock(dock)
	dock.plugin_version = get_plugin_version()
	# dock.docktab_container.set_tab_icon(0, gdl_ico)
	dock.renable_btn.button_up.connect(_renable_plugin) 



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