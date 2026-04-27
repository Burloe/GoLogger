extends Control

@onready var db_timer: Timer = %DebugTimer
@onready var c_container: HBoxContainer = %CategoryContainer
@export var entry_limit: int = 20:
	set(value):
		if value != entry_limit:
			entry_limit = value 
			for c in c_container.get_children():
				c.entry_limit = value

const PATH = "user://gologger_data.ini"

var config := ConfigFile.new()

var c_module = preload("uid://dgdg4n7lsq031")


func _ready() -> void:
	db_timer.timeout.connect(_on_timer_timeout)
	Log.msg_logged.connect(_on_msg_logged)
	config.load(PATH)

	for child in c_container.get_children():
		child.queue_free()

	for c in config.get_value("categories", "category_names", []):
		var _n = c_module.instantiate() as DBCategoryModule
		c_container.add_child(_n)
		_n.category_name = c
		_n.entry_limit = entry_limit



func _on_msg_logged(category_name: String, msg: String) -> void:
	for child in c_container.get_children():
		if child.category_name == category_name:
			child.add_msg(msg)
		


func _on_timer_timeout() -> void:
	if !FileAccess.file_exists(PATH):
		return

	var _result = config.load(PATH)

	if _result != OK:
		return

	var cats: Array = config.get_value("categories", "category_names", [])
	var def_c: String = config.get_value("categories", "default_category", "")

	if cats.is_empty() or cats == null: return

	for c in cats:
		Log.msg(str("This is a test entry for category [", c, "]."), c, true)

	if def_c != "":
		Log.msg(str("This is a test entry for the default category"), def_c)
