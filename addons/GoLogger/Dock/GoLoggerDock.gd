@tool
extends TabContainer

#region Settings
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


@onready var canvas_layer_line : LineEdit = $Settings/HBoxContainer/ColumnC/VBoxContainer/HBoxContainer/VBoxContainer2/CanvasLayerLineEdit
var canvas_layer_tt : String = "Sets the layer of the CanvasLayer containing the copy popup prompt and Controller."

@onready var drag_offset_x : LineEdit = $Settings/HBoxContainer/ColumnC/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/XLineEdit
@onready var drag_offset_y : LineEdit = $Settings/HBoxContainer/ColumnC/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/YLineEdit
@onready var drag_offset_tt : String = "Offset the controller window while dragging."

@onready var controller_start_btn : CheckButton = $Settings/HBoxContainer/ColumnC/VBoxContainer/ShowOnStartCheckButton
var controller_start_tt : String = "Show the controller by default."

@onready var controller_monitor_side__btn : CheckButton = $Settings/HBoxContainer/ColumnC/VBoxContainer/MonitorSideCheckButton
var controller_monitor_side_tt : String = "Set the side of the controller the log file monitor panel."


@onready var error_rep_btn : OptionButton = $Settings/HBoxContainer/ColumnD/Column/HBoxContainer/VBoxContainer2/ErrorRepOptButton
var error_rep_tt : String = "Sets the level of error reporting. Errors will pause execution while warnings are added to the Debugger > Error tab. You can also turn them off entirely."

@onready var session_print_btn : OptionButton = $Settings/HBoxContainer/ColumnD/Column/HBoxContainer/VBoxContainer2/SessionChangeOptButton
var session_print_tt : String = "Prints messages to the output whenever a session is started, copied or stopped. You can also turn them off entirely."

@onready var disable_warn1_btn : CheckButton = $Settings/HBoxContainer/ColumnD/Column/DisableWarn1CheckButton
var disable_warn1_tt : String = "Disable: 'Failed to start session, a session is already active'."

@onready var disable_warn2_btn : CheckButton = $Settings/HBoxContainer/ColumnD/Column/DisableWarn2CheckButton
var disable_warn2_tt : String = "Disable warning: 'Failed to log entry due to inactive session'."
#endregion

# Category tab
@onready var add_category_btn : Button = $Categories/MarginContainer/VBoxContainer/HBoxContainer/AddButton
@onready var category_container : GridContainer = $Categories/MarginContainer/VBoxContainer/HBoxContainer/GridContainer
@onready var open_dir_btn : Button = $Categories/MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/OpenDirButton
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
# var categ : Array[Array] = []
var max_name_length : int = 20
var config = ConfigFile.new()
const PATH = "user://GoLogger/settings.ini"

signal update_index


func _ready() -> void: 
	if Engine.is_editor_hint():
		# Load/create settings.ini
		if !FileAccess.file_exists(PATH):
			create_settings_file()
		else:
			config.load(PATH)

		add_category_btn.button_up.connect(add_category)
		open_dir_btn.button_up.connect(open_directory)
		base_dir.text = Log.base_directory

		# Remove existing categories
		for i in category_container.get_children():
			if i is not Button:
				i.queue_free()

		# Add categories as saved in .ini file
		load_categories()



func _physics_process(delta: float) -> void:
	var _c = config.get_value("plugin", "categories") 
	$Categories/MarginContainer/VBoxContainer/Label.text = str("Current .ini setting(size = ", _c.size(), "):\n      ", _c, "\nCurrent GridContainer.get_children()[size = ",category_container.get_children().size(), "]:\n      ", category_container.get_children())


func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, true], ["player", 1, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

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
	config.save(PATH)




#region Main category functions
func load_categories() -> void:
	var _c = config.get_value("plugin", "categories")
	for i in range(_c.size()):
		var _n = category_scene.instantiate()
		_n.dock = self
		_n.category_name = _c[i][0]
		_n.index = i 
		_n.is_locked = _c[i][2]
		category_container.add_child(_n)
		category_container.move_child(_n, _n.index)
	update_indices()
	# config.save_value("plugin", "categories", _c)


## Adds a new category instance to the dock.
func add_category() -> void:
	var _n = category_scene.instantiate()
	_n.dock = self 
	_n.index = category_container.get_children().size()
	_n.is_locked = false
	category_container.add_child(_n)
	category_container.move_child(_n, _n.index)
	update_indices()
	save_categories()
	_n.line_edit.grab_focus()

## Saves categories by looping through each category element. Storing and appending its 
## name, index and locked status into an array and then saving it into a [ConfigFile].[br]
## [param deferred] is used when removing a category. Deferring the function ensures that
## categories are saved the next frame after [method queue_free] is completed at the end 
## of the frame it's called.
func save_categories(deferred : bool = false) -> void:
	if deferred:
		await get_tree().physics_frame
	var main : Array # Main array
	var children = category_container.get_children()
	for i in range(children.size()): # Loop through each child
		# Create and append a nested array inside main [["game", 0, false], ["player", 1, false]]
		var _n : Array = [children[i].category_name, children[i].index, children[i].is_locked] 
		main.append(_n)
	config.set_value("plugin", "categories", main)
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
	config.save(PATH)
#endregion



#region Helpers
func update_category_name(obj : Panel, new_name : String) -> void:
	var final_name = new_name
	var add_name : int = 1
	while check_conflict_name(obj, final_name):
		final_name = new_name + str(add_name)
		add_name += 1
	if obj.category_name != final_name:
		obj.category_name = final_name
	save_categories()


func check_conflict_name(obj : Panel, name : String) -> bool:
	for i in category_container.get_children():
		if i.category_name == name and i != obj:
			if name == "": return false
			return true
	return false


func update_indices(deferred : bool = false) -> void:
	if deferred:
		await get_tree().physics_frame
	var refresh_table = []
	var _c = category_container.get_children()
	for i in range(_c.size()):
		_c[i].index = i # updates actual dock elements
		_c[i].refresh_index_label(i)
		var _e : Array = [_c[i].category_name, i, _c[i].is_locked]
		refresh_table.append(_e)
	config.set_value("plugin", "categories", refresh_table)
	config.save(PATH)
	printt("Update indices:\n", refresh_table)
#endregion






func load_settings(section : String) -> Dictionary:
	var settings = {}
	for key in config.get_section_keys(section):
		settings[key] = config.get_value(section, key)
	return settings


func save_setting(value, key : String, section : String = "settings") -> void:
	config.set_value(section, key, value)
	config.save(PATH) 


func open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(config.get_value("plugin", "base_directory"))
	print(abs_path)
	OS.shell_open(abs_path)