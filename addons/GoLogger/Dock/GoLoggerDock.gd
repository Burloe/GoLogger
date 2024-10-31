@tool
extends Panel


@onready var tooltip : Panel = $ScrollContainer/HBoxContainer/ToolTip

@onready var base_dir : LineEdit = $ScrollContainer/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/LineEdit
var base_dir_tt : String = "Directory. GoLogger will create folders within the base directory for each log category to store the logs."

@onready var log_header : OptionButton = $ScrollContainer/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/OptionButton
var log_header_tt : String = "Sets the header used in logs. Gets the name and version from Project Settings."

@onready var autostart_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnA/VBox/AutostartButton
var autostart_tt : String = "Autostarts a session when you run your project."

@onready var utc_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnA/VBox/UTCButton
var utc_tt : String = "Use UTC time as opposed to the local system time."

@onready var dash_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnA/VBox/DashButton
var dash_tt : String = "Uses - to separate date/timestamp. With categoryname(yy-mm-dd_hh-mm-ss).log. Without = categoryname(yymmdd_hhmmss).log."


@onready var limit_method_btn : OptionButton = $ScrollContainer/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/LogManOptButton
var limit_method_tt : String = "Sets the method used to limit log files from becoming excessively large.\nEntry count is triggered when the number of entries exceeds the entry count limit.\n Session Timer will trigger upon timer's timeout signal."

@onready var limit_action_btn : OptionButton = $ScrollContainer/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/ManageTriggerOptButton
var limit_action_tt : String = "Sets the action taken when the limit method is triggered."

@onready var entry_count_line : LineEdit = $ScrollContainer/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/EntryCountLineEdit
var entry_count_tt : String = "The entry count limit of any log."

@onready var wait_time_line : LineEdit = $ScrollContainer/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/WaitTimeLineEdit
var wait_time_tt : String = "Wait time of the session timer."

@onready var file_count_line : LineEdit = $ScrollContainer/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/FileCountLineEdit
var file_count_tt : String = "The limit of files in a category folder. The oldest log file is deleted when a new one is created."


@onready var error_rep_btn : OptionButton = $ScrollContainer/HBoxContainer/ColumnC/Column/HBoxContainer/VBoxContainer2/ErrorRepOptBtn
var error_rep_tt : String = "Sets the level of error reporting. Errors will pause execution while warnings are added to the Debugger > Error tab. You can also turn them off entirely."

@onready var session_print_btn : OptionButton = $ScrollContainer/HBoxContainer/ColumnC/Column/HBoxContainer/VBoxContainer2/SessionPrintOptBtn
var session_print_tt : String = "Prints messages to the output whenever a session is started, copied or stopped. You can also turn them off entirely."

@onready var disable_warn1_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnC/Column/DisableWarnBtn1
var disable_warn1_tt : String = "Disable: 'Failed to start session, a session is already active'."

@onready var disable_warn2_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnC/Column/DisableWarnBtn2
var disable_warn2_tt : String = "Disable warning: 'Failed to log entry due to inactive session'."


@onready var canvas_layer_line : LineEdit = $ScrollContainer/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/CanvasLayerLine
var canvas_layer_tt : String = "Sets the layer of the CanvasLayer containing the copy popup prompt and Controller."

@onready var drag_offset_x : LineEdit = $ScrollContainer/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/XLineEdit
@onready var drag_offset_y : LineEdit = $ScrollContainer/HBoxContainer/ColumnD/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/YLineEdit
@onready var drag_offset_tt : String = "Offset the controller window while dragging."

@onready var controller_start_btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnD/VBoxContainer/ControllerOnStartButton
var controller_start_tt : String = "Show the controller by default."

@onready var controller_monitor_side__btn : CheckButton = $ScrollContainer/HBoxContainer/ColumnD/VBoxContainer/ControllerMonitorSideButton
var controller_monitor_side_tt : String = "Set the side of the controller the log file monitor panel."





# var config = ConfigFile.new()
# const SETTINGS_PATH = "user://GoLogger/settings.ini"
 




func _ready() -> void:
	# if !FileAccess.file_exists(SETTINGS_PATH):
	# 	config.set_value("base_settings", "base_directory", Log.base_directory)
	# 	config.set_value("base_settings", "categories", Log.categories)
	# 	config.set_value("base_settings", "log_header", Log.log_header)
	# 	config.set_value("base_settings", "autostart_session", Log.autostart_session)
	# 	config.set_value("base_settings", "use_utc", Log.use_utc)
	# 	config.set_value("base_settings", "dash_timestamp_separator", Log.dash_timestamp_separator)
	# 	config.set_value("base_settings", "limit_method", Log.limit_method)
	# 	config.set_value("base_settings", "limit_action", Log.limit_action)
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )
	# 	config.set_value("base_settings", )

	base_dir.text = Log.base_directory
	


func _physics_process(delta: float) -> void:

	tooltip.text 
	