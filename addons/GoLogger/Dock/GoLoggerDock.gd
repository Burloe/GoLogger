@tool
extends TabContainer


@onready var tooltip : Panel = $Settings/HBoxContainer/ToolTip

@onready var base_dir : LineEdit = $Settings/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/BaseDirLineEdit
var base_dir_tt : String = "Directory. GoLogger will create folders within the base directory for each log category to store the logs."

@onready var log_header : OptionButton = $Settings/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/LogHeaderOptButton
var log_header_tt : String = "Sets the header used in logs. Gets the name and version from Project Settings."

@onready var autostart_btn : CheckButton = $Settings/HBoxContainer/ColumnA/VBox/AutostartCheckButton
var autostart_tt : String = "Autostarts a session when you run your project."

@onready var utc_btn : CheckButton = $Settings/HBoxContainer/ColumnA/VBox/UTCCheckButton
var utc_tt : String = "Use UTC time as opposed to the local system time."

@onready var dash_btn : CheckButton = $Settings/HBoxContainer/ColumnA/VBox/SeparatorCheckButton
var dash_tt : String = "Uses - to separate date/timestamp. With categoryname(yy-mm-dd_hh-mm-ss).log. Without = categoryname(yymmdd_hhmmss).log."


@onready var limit_method_btn : OptionButton = $Settings/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/LimitMethodOptButton
var limit_method_tt : String = "Sets the method used to limit log files from becoming excessively large.\nEntry count is triggered when the number of entries exceeds the entry count limit.\n Session Timer will trigger upon timer's timeout signal."

@onready var limit_action_btn : OptionButton = $Settings/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/LimitActionOptButton
var limit_action_tt : String = "Sets the action taken when the limit method is triggered."

@onready var entry_count_line : LineEdit = $Settings/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/FileCountLineEdit
var entry_count_tt : String = "The entry count limit of any log."

@onready var wait_time_line : LineEdit = $Settings/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/EntryCountLineEdit
var wait_time_tt : String = "Wait time of the session timer."

@onready var file_count_line : LineEdit = $Settings/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/SessionTimerLineEdit
var file_count_tt : String = "The limit of files in a category folder. The oldest log file is deleted when a new one is created."


@onready var error_rep_btn : OptionButton = $Settings/HBoxContainer/ColumnC/Column/HBoxContainer/VBoxContainer2/ErrorRepOptButton
var error_rep_tt : String = "Sets the level of error reporting. Errors will pause execution while warnings are added to the Debugger > Error tab. You can also turn them off entirely."

@onready var session_print_btn : OptionButton = $Settings/HBoxContainer/ColumnC/Column/HBoxContainer/VBoxContainer2/SessionChangeOptButton
var session_print_tt : String = "Prints messages to the output whenever a session is started, copied or stopped. You can also turn them off entirely."

@onready var disable_warn1_btn : CheckButton = $Settings/HBoxContainer/ColumnC/Column/DisableWarn1CheckButton
var disable_warn1_tt : String = "Disable: 'Failed to start session, a session is already active'."

@onready var disable_warn2_btn : CheckButton = $Settings/HBoxContainer/ColumnC/Column/DisableWarn2CheckButton
var disable_warn2_tt : String = "Disable warning: 'Failed to log entry due to inactive session'."


@onready var canvas_layer_line : LineEdit = $Settings/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/CanvasLayerLineEdit
var canvas_layer_tt : String = "Sets the layer of the CanvasLayer containing the copy popup prompt and Controller."

@onready var drag_offset_x : LineEdit = $Settings/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/XLineEdit
@onready var drag_offset_y : LineEdit = $Settings/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/YLineEdit
@onready var drag_offset_tt : String = "Offset the controller window while dragging."

@onready var controller_start_btn : CheckButton = $Settings/HBoxContainer/ColumnD/VBoxContainer/ShowOnStartCheckButton
var controller_start_tt : String = "Show the controller by default."

@onready var controller_monitor_side__btn : CheckButton = $Settings/HBoxContainer/ColumnD/VBoxContainer/MonitorSideCheckButton
var controller_monitor_side_tt : String = "Set the side of the controller the log file monitor panel."

# Category tab
@onready var category_add_btn : Button = $Categories/MarginContainer/VBoxContainer/GridContainer/AddButton
@onready var category_container : GridContainer = $Categories/MarginContainer/VBoxContainer/GridContainer
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
var cats : Array[Panel] = []
 
var config = ConfigFile.new()
const CONFIG_PATH = "user://GoLogs/settings.ini"

func _ready() -> void: 
	category_add_btn.button_up.connect(add_category)
	base_dir.text = Log.base_directory
	for i in range(Log.categories.size()):
		var _n = category_scene.instantiate()
		_n.cat_name = Log.categories[i].category_name
		_n.index = i
		category_container.add_child(_n)




func _physics_process(delta: float) -> void:

	tooltip.text 
	
## Adds a new category element to the dock. Adds a corresponding [LogFileResource] to the [param categories].
func add_category(name : String) -> void:
	# Load/create settings.ini
	if !FileAccess.file_exists(CONFIG_PATH):
		var _a : Array[LogFileResource] = [preload("res://addons/GoLogger/Resources/DefaultLogFile.tres")]
		config.set_value("plugin", "categories", _a)
		config.set_value("plguin", "base_directory", "user://GoLogger/")
		config.set_value("settings", "log_header", 0)
		config.set_value("settings", "autostart_session", true)
		config.set_value("settings", "use_utc", false)
		config.set_value("settings", "dash_separator", false)
		config.set_value("settings", "limit_method", 0)
		config.set_value("settings", "limit_actio", 0)
		config.set_value("settings", "file_cap", 10)
		config.set_value("settings", "entry_count_limit", 1000)
		config.set_value("settings", "session_timer_wait_time", 600.0)
		config.set_value("settings", "error_reporting", 0)
		config.set_value("settings", "print_session_changes", 0)
		config.set_value("settings", "disable_session_warning", false)
		config.set_value("settings", "disable_entry_warning", false)
		config.set_value("settings", "canvaslayer_layer", 5)
		config.set_value("settings", "hide_controller", true)
		config.set_value("settings", "controller_drag_offset", Vector2(0,0))
		config.save(CONFIG_PATH)
	else:
		config.load(CONFIG_PATH)
	
	var _n = category_scene.instantiate()
	_n.dock = self
	category_container.add_child(_n)
	cats.append(_n)
	Log.categories.append(_n)



func change_category_name(current_name : String, new_name : String) -> void:
	for i in Log.categories:
		if i.category_name == current_name:
			i.category_name = new_name


## Remove [LogFileResource] from array 
func remove_category(name : String) -> void:
	for i in range(Log.categories.size()):
		if Log.categories[i].category_name == name:
			Log.categories.remove_at(i)



func save_plugin_setting(section : String, key : String, value) -> void:
	config.set_value(section, key, value)
	config.save(CONFIG_PATH)



func load_plugin_settings(section : String) -> Dictionary:
	var settings = {}
	for key in config.get_section_keys(section):
		settings[key] = config.get_value(section, key)
	return settings