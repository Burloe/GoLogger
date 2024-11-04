@tool
extends TabContainer

#region Settings
@onready var tooltip : Panel = $Settings/HBoxContainer/ToolTip

# var base_dir : Array = [
# 	"user://GoLogger/", 
# 	$Settings/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/BaseDirLineEdit,
# 	"Directory. GoLogger will create folders within the base directory for each log category to store the logs."
# ]











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

@onready var tooltip_lbl : Label = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/ToolTip/MarginContainer/Label
#endregion

# Category tab
## Add category [Button]. Instantiates a [param category_scene] and adds it as a child of [param category_container].
@onready var add_category_btn : Button = $Categories/MarginContainer/VBoxContainer/HBoxContainer/AddButton
## Category [GridContainer] node. Holds all the LogCategory nodes that represent each category.
@onready var category_container : GridContainer = $Categories/MarginContainer/VBoxContainer/HBoxContainer/GridContainer
## Open directory [Button] node. Opens the [param base_directory] folder using the OS file explorer. 
@onready var open_dir_btn : Button = $Categories/MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/OpenDirButton
## Reset to default categories [Button] node. Removes all existing categories and adds "game" and "player" categories.
@onready var defaults_btn : Button = $Categories/MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DefaultsButton

## LogCategory scene. Instantiated into [param LogCategory].
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
## [ConfigFile]. All settings are added to this instance and then saves the stored settings to the settings.ini file.
var config = ConfigFile.new()
## Path to settings.ini file.
const PATH = "user://GoLogger/settings.ini"
## Emitted whenever an action that changes the display order is potentially made. Updates the index of all LogCategories.
signal update_index

# func _physics_process(delta: float) -> void:
# 	var _c = config.get_value("plugin", "categories") 
# 	$Categories/MarginContainer/VBoxContainer/Label.text = str("Current .ini setting(size = ", _c.size(), "):\n      ", _c, "\nCurrent GridContainer.get_children()[size = ",category_container.get_children().size(), "]:\n      ", category_container.get_children())


func _ready() -> void: 
	if Engine.is_editor_hint():
		# Load/create settings.ini
		if !FileAccess.file_exists(PATH):
			create_settings_file()
		else:
			config.load(PATH)
		# Categories
		add_category_btn.button_up.connect(add_category)
		
		open_dir_btn.button_up.connect(open_directory)
		defaults_btn.button_up.connect(reset_to_default)

		# Remove any existing categories
		for i in category_container.get_children():
			if i is not Button:
				i.queue_free()

		load_categories()

		
		# Settings
		# Base directory
		base_dir_node.text_submitted.connect(_on_basedir_text_submitted)
		base_dir_reset_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_reset_btn))
		base_dir_reset_btn.mouse_entered.connect(update_tooltip.bind(base_dir_reset_btn))
		base_dir_reset_btn.focus_entered.connect(update_tooltip.bind(base_dir_reset_btn))

		base_dir_opendir_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_opendir_btn))
		base_dir_opendir_btn.mouse_entered.connect(update_tooltip.bind(base_dir_opendir_btn))
		base_dir_opendir_btn.focus_entered.connect(update_tooltip.bind(base_dir_opendir_btn))

		base_dir_apply_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_apply_btn))
		base_dir_apply_btn.mouse_entered.connect(update_tooltip.bind(base_dir_apply_btn))
		base_dir_apply_btn.focus_entered.connect(update_tooltip.bind(base_dir_apply_btn))
		base_dir_node.text = config.get_setting("base_directory")

		# Log header
		log_header.item_selected.connect(_on_logheader_item_selected)
		log_header.mouse_entered.connect(update_tooltip.bind(log_header))
		log_header.focus_entered.connect(update_tooltip.bind(log_header))

		# Autostart session, UTC and Dash Separator
		autostart_btn.toggled.connect(_on_checkbutton_toggled.bind(autostart_btn))
		autostart_btn.mouse_entered.connect(update_tooltip)

		utc_btn.toggled.connect(_on_checkbutton_toggled.bind(utc_btn))
		utc_btn.mouse_entered.connect(update_tooltip)

		dash_btn.toggled.connect(_on_checkbutton_toggled.bind(autostart_btn))
		dash_btn.mouse_entered.connect(update_tooltip)

		limit_method_btn.item_selected.connect(_on_limit_method_item_selected)
		limit_method_btn.mouse_entered.connect(update_tooltip.bind(limit_method_btn))
		limit_method_btn.focus_entered.connect(update_tooltip.bind(limit_method_btn))

		limit_action_btn.item_selected.connect(_on_limit_action_item_selected)
		limit_action_btn.mouse_entered.connect(update_tooltip.bind(limit_action_btn))
		limit_action_btn.focus_entered.connect(update_tooltip.bind(limit_action_btn))

		entry_count_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(entry_count_spinbox))
		wait_time_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(wait_time_spinbox))
		file_count_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(file_count_spinbox))
		canvas_layer_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(canvas_layer_spinbox))


func update_tooltip(node : Control) -> void:
	match node:
		# Base directory tooltips
		base_dir_node:
			tooltip_lbl.text = "The base directory used to create and store log files within."
		base_dir_reset_btn:
			tooltip_lbl.text = "The base directory used to create and store log files within.\nResets the base directory to the default user://GoLogger/"
		base_dir_opendir_btn:
			tooltip_lbl.text = "The base directory used to create and store log files within.\nOpens the currently applied base directory folder."
		base_dir_apply_btn:
			tooltip_lbl.text = "The base directory used to create and store log files within.\nAttempts to apply and create the base directory folder using the entered path. The directory path resets to the previously saved path if the new path was rejected."

		# Bool settings [CheckButtons]
		autostart_btn:
			tooltip_lbl.text = "Autostarts a session when running your project."
		utc_btn:
			tooltip_lbl.text = "Use UTC time for date/timestamps as opposed to the local system time."
		dash_btn:
			tooltip_lbl.text = "Uses dashes(-) to separate date/timestamps. \nEnabled: category_name(yy-mm-dd_hh-mm-ss).log\nDisabled: category_name(yymmdd_hhmmss).log"
		
		# Enum settings [OptionButtons]
		log_header:
			tooltip_lbl.text = "Used to set what to include in the log header. Project name and version is fetched from Project Settings."
		limit_method_btn:
			tooltip_lbl.text = "Method used to limit log file length/size. Action taken is when this condition is met is set with 'Limit Action'. Entry count will execute an action when the number of entries hits the cap. Session timer executes an action on timer timeout."
		limit_action_btn:
			tooltip_lbl.text = "Action taken when 'Limit Method' condition is met. "
		
		# Int settings [LineEdits]
		entry_count_spinbox:
			tooltip_lbl.text = "Entry count limit of any log. Used when 'Limit Method' is set to use Entry Count."
		wait_time_spinbox:
			tooltip_lbl.text = "Wait time for the Session Timer. Used when 'Limit Method' is set to use Session Timer."
		file_count_spinbox:
			tooltip_lbl.text = "File count limit. Limits the number of files in any log category folder."
		canvas_layer_spinbox:
			tooltip_lbl.text = "Sets the layer of the CanvasLayer node that contains the in-game Controller and the 'Save copy' popup."
		

		

#region Base Directory setting: 
@onready var base_dir_node : LineEdit = $Settings/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/BaseDirLineEdit
@onready var base_dir_reset_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/ResetButton
@onready var base_dir_opendir_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/OpenDirButton
@onready var base_dir_apply_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/ApplyButton


func _on_basedir_text_submitted(new_text : String) -> void:
	var old_dir = config.get_value("plugin", "base_directory")
	var _d = DirAccess.open(new_text)
	_d.make_dir(new_text)
	var _e = DirAccess.get_open_error()
	# Create directory was successful > Allow/set as new directory
	if _e == OK:
		save_setting("plugin", "base_directory", new_text)
	else:
		print(_e)
		base_dir_node.text = old_dir
	base_dir_node.release_focus()


func _on_basedir_button_up(btn : Button) -> void:
	match btn:
		base_dir_reset_btn:
			config.set_value("plugin", "base_directory", "user://GoLogger/")
		base_dir_opendir_btn:
			open_directory()
		base_dir_apply_btn:
			var old_dir = config.get_value("plugin", "base_directory")
			var new = base_dir_node.text
			var _d = DirAccess.open(new)
			_d.make_dir(new)
			var _e = DirAccess.get_open_error()
			if _e == OK: # New directory approved and created
				save_setting("plugin", "base_directory", new)
			else: # New directory rejected
				base_dir_node = old_dir 
	base_dir_node.release_focus()
#endregion


#region Log Header
@onready var log_header : OptionButton = $Settings/HBoxContainer/ColumnA/VBox/HBoxContainer/VBoxContainer2/LogHeaderOptButton
var log_header_string : String

func _on_logheader_item_selected(index : int) -> void:
	match index:
		0: # Project name and version
			var _n = str(ProjectSettings.get_setting("application/config/name"))
			var _v = str(ProjectSettings.get_setting("application/config/version"))
			if _n == "": printerr("GoLogger warning: Undefined project name in 'ProjectSettings/application/config/name'.")
			if _v == "": printerr("GoLogger warning: Undefined project version in 'ProjectSettings/application/config/version'.")
			log_header_string = str(_n, " V.", _v)
		1: # Project name
			log_header_string = str(ProjectSettings.get_setting("application/config/name"))
		2: # Version
			log_header_string = str(ProjectSettings.get_setting("application/config/version"))
	config.set_value("settings", "log_header", index)
	config.save(PATH) # ? Doesn't this save a settings.ini file with just this one setting?
#endregion


#region Autostart session, UTC and Dash separator
@onready var autostart_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/MarginContainer/VBoxContainer/AutostartCheckButton 
@onready var utc_btn : CheckButton = $Settings/HBoxContainer/ColumnA/VBox/UTCCheckButton 
@onready var dash_btn : CheckButton = $Settings/HBoxContainer/ColumnA/VBox/SeparatorCheckButton 

func _on_checkbutton_toggled(toggled_on : bool, node : Control) -> void:
	match node:
		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)
		utc_btn:
			config.set_value("settings", "use_utc", toggled_on)
		dash_btn:
			config.set_value("settings", "dash_separator", toggled_on)
	
	config.save(PATH)
#endregion


#region Limit Method & Limit Action
@onready var limit_method_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/LimitMethodOptButton
var limit_method_tt : String = "Sets the method used to limit log files from becoming excessively large.\nEntry count is triggered when the number of entries exceeds the entry count limit.\n Session Timer will trigger upon timer's timeout signal."

@onready var limit_action_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/LimitActionOptButton
var limit_action_tt : String = "Sets the action taken when the limit method is triggered."

func _on_limit_method_item_selected(index : int) -> void:
	config.set_value("settings", "limit_method", index)
	config.save(PATH)

func _on_limit_action_item_selected(index : int) -> void:
	config.set_value("settings", "limit_action", index)
	config.save(PATH)
#endregion


#region File & Entry cap, Session wait time and CanvasLayer layer
@onready var entry_count_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/EntryCountLineEdit
@onready var wait_time_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/SessionTimerSpinBox
@onready var file_count_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/HBoxContainer/VBoxContainer2/FileCountSpinBox
@onready var canvas_layer_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/VBoxContainer/HBoxContainer/VBoxContainer2/CanvasLayerSpinBox

func _on_spinbox_value_changed(value : float, node : Control) -> void:
	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_count_limit", value)
		wait_time_spinbox:
			config.set_value("settings", "session_timer_wait_time", value)
		file_count_spinbox:
			config.set_value("settings", "file_cap", value)
		canvas_layer_spinbox:
			config.set_value("settings", "canvaslayer_layer", value)
	config.save(PATH)
#endregion


#region Main category functions
func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, true], ["player", 1, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "log_header", 0)
	config.set_value("settings", "autostart_session", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "dash_separator", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "limit_action", 0)
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


## Resets the categories to default by removing any existing category elements, 
## overwriting the saved categories in the .ini file and then loading default 
## categories "game" and "player".
func reset_to_default() -> void:
	# Remove existing category elements from dock
	var children = category_container.get_children()
	for i in range(children.size()):
		children[i].queue_free()

	# Set/load default categories deferred to ensure completed deletion
	# Preventative "cooldown" added to disable reset and add to be called
	# during this cooldown period.
	defaults_btn.disabled = true
	add_category_btn.disabled = true
	await get_tree().create_timer(0.5).timeout
	config.set_value("plugin", "categories", [["game", 0, false], ["player", 1, false]])
	load_categories()
	defaults_btn.disabled = false
	add_category_btn.disabled = false


## Loads categories from settings.ini and creates corresponding LogCategory elements.
func load_categories(deferred : bool = false) -> void:
	if deferred:
		await get_tree().physics_frame
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


### Helpers ###
## Updates the name of a category, then saves all categories.
func update_category_name(obj : Panel, new_name : String) -> void:
	var final_name = new_name
	var add_name : int = 1
	while check_conflict_name(obj, final_name):
		final_name = new_name + str(add_name)
		add_name += 1
	if obj.category_name != final_name:
		obj.category_name = final_name
	save_categories()

## Helper function - Iterates through all children and compares the name of other nodes. 
func check_conflict_name(obj : Panel, name : String) -> bool:
	for i in category_container.get_children():
		# Continue if the current loop 
		# is the object being renamed
		if i == obj:
			continue
		elif i.category_name == name:
			printerr(str("FOUND CONFLICTING NAME ON OBJECT: ", i.category_name, "[", i, "] - ", obj.category_name, "[", obj, "]\nall children: ", category_container.get_children()))
			if name == "": return false
			return true
	return false

## Helper function - Updates indices of all the categories.
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



#region Settings
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