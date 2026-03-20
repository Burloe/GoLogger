extends Control

@onready var db_timer: Timer = %DebugTimer

const PATH = "user://gologger_data.ini"

var config := ConfigFile.new()

func _ready() -> void:
	db_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if !FileAccess.file_exists(PATH):
		print("--")
		return
	else: print("++")

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
