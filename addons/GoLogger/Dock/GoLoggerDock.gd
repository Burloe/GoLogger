@tool
extends TabContainer

#region Category tab
## Add category [Button]. Instantiates a [param category_scene] and adds it as a child of [param category_container].
@onready var add_category_btn : Button = %AddCategoryButton
## Category [GridContainer] node. Holds all the LogCategory nodes that represent each category.
@onready var category_container : GridContainer = %CategoryGridContainer
## Open directory [Button] node. Opens the [param base_directory] folder using the OS file explorer. 
@onready var open_dir_btn : Button = %OpenDirCatButton
## Reset to default categories [Button] node. Removes all existing categories and adds "game" and "player" categories.
@onready var defaults_btn : Button = %DefaultsCatButton

## LogCategory scene. Instantiated into [param LogCategory].
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
## [ConfigFile]. All settings are added to this instance and then saves the stored settings to the settings.ini file.
var config = ConfigFile.new()
## Path to settings.ini file. This path is a contant and doesn't change if you set your own [param base_directory]
const PATH = "user://GoLogger/settings.ini"
## Emitted whenever an action that changes the display order is potentially made. Updates the index of all LogCategories.
signal update_index
#endregion


#region Settings tab
@onready var tooltip : Panel = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/ToolTip
@onready var tooltip_lbl : RichTextLabel = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/ToolTip/MarginContainer/Label
@onready var reset_settings_btn : Button = %ResetSettingsButton

@onready var base_dir_line : LineEdit = %BaseDirLineEdit
@onready var base_dir_apply_btn : Button = %BaseDirApplyButton
@onready var base_dir_opendir_btn : Button = %BaseDirOpenDirButton
@onready var base_dir_reset_btn : Button = %BaseDirResetButton
@onready var base_dir_btn_container : HBoxContainer = %BaseDirBtnContainer

@onready var log_header_btn : OptionButton = %LogHeaderOptButton
@onready var log_header_container : HBoxContainer = %LogHeaderHBox
var log_header_string : String

@onready var canvas_layer_spinbox : SpinBox = %CanvasLayerSpinBox
var canvas_spinbox_line : LineEdit
@onready var canvas_layer_container : HBoxContainer = %CanvasLayerHBox


@onready var autostart_btn : CheckButton = %AutostartCheckButton

@onready var timestamp_entries_btn : CheckButton = %TimestampEntriesButton

@onready var utc_btn : CheckButton = %UTCCheckButton

@onready var dash_btn : CheckButton = %SeparatorCheckButton


@onready var limit_method_btn : OptionButton = %LimitMethodOptButton

@onready var limit_method_container : HBoxContainer = %LimitMethodHBox

@onready var limit_action_btn : OptionButton = %LimitActionOptButton 

@onready var limit_action_container : HBoxContainer = %LimitActionHBox

@onready var file_count_spinbox : SpinBox = %FileCountSpinBox
var file_count_spinbox_line : LineEdit
@onready var file_count_container : HBoxContainer = %FileCountHBox

@onready var entry_count_spinbox : SpinBox = %EntryCountSpinBox
var entry_count_spinbox_line : LineEdit
@onready var entry_count_container : HBoxContainer = %EntryCountHBox

@onready var session_duration_spinbox : SpinBox = %SessionDurationHBox/SessionDurationSpinBox
var session_duration_spinbox_line : LineEdit
@onready var session_duration_container : HBoxContainer = %SessionDurationHBox

@onready var error_rep_btn : OptionButton = %ErrorRepOptButton
@onready var error_rep_container : HBoxContainer = %ErrorRepHBox

@onready var session_print_btn : OptionButton = %SessionChangeOptButton
@onready var session_print_container : HBoxContainer = %SessionDurationHBox


@onready var disable_warn1_btn : CheckButton = %DisableWarn1CheckButton
@onready var disable_warn2_btn : CheckButton = %DisableWarn2CheckButton 

# Controller settings
@onready var controller_xpos_spinbox : SpinBox = %XPosSpinBox
var controller_xpos_line : LineEdit
@onready var controller_ypos_spinbox : SpinBox = %YPosSpinBox
var controller_ypos_line : LineEdit

@onready var drag_offset_x : SpinBox = %XOffSpinBox
var dragx_line : LineEdit

@onready var drag_offset_y : SpinBox = %YOffSpinBox
var dragy_line : LineEdit
@onready var drag_offset_container : HBoxContainer = %DragOffsetHBox

@onready var controller_start_btn : CheckButton = %ShowOnStartCheckButton

@onready var controller_monitor_side_btn : CheckButton = %MonitorSideCheckButton

var btn_array : Array[Control] = []
var container_array : Array[Control] = []
#endregion


#TODO Add a 'validate settings' function

# Debug
# func _physics_process(delta: float) -> void:
# 	$Settings/MarginContainer/Panel/HBoxContainer/ColumnE/Column/Label2.text = str("FileCount status: ", file_count_spinbox_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted))
# 	var _c = config.get_value("plugin", "categories") 
# 	$Categories/MarginContainer/VBoxContainer/Label.text = str("Current .ini setting(size = ", _c.size(), "):\n      ", _c, "\nCurrent GridContainer.get_children()[size = ",category_container.get_children().size(), "]:\n      ", category_container.get_children())


func _ready() -> void: 
	if Engine.is_editor_hint():
		# Load/create settings.ini
		var _d = DirAccess.open("user://GoLogger/")
		if !_d:
			_d.make_dir("user://GoLogger/")


		if !FileAccess.file_exists(PATH):
			create_settings_file()
		else:
			config.load(PATH)
		# Categories
		add_category_btn.button_up.connect(add_category)
		open_dir_btn.button_up.connect(open_directory)
		defaults_btn.button_up.connect(reset_to_default.bind(0))

		# Remove any existing categories
		for i in category_container.get_children():
			if i is not Button:
				i.queue_free()
		# Load categories as saved in settings.ini
		load_categories()

		
		# Settings	
		reset_settings_btn.button_up.connect(reset_to_default.bind(1))
		reset_settings_btn.mouse_entered.connect(update_tooltip.bind(reset_settings_btn))
		reset_settings_btn.focus_entered.connect(update_tooltip.bind(reset_settings_btn))
		
		btn_array = [
			base_dir_line,
			base_dir_apply_btn,
			base_dir_opendir_btn,
			base_dir_reset_btn,
			log_header_btn,
			canvas_layer_spinbox,
			autostart_btn,
			utc_btn,
			timestamp_entries_btn,
			dash_btn,
			limit_method_btn,
			limit_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			error_rep_btn,
			session_print_btn,
			disable_warn1_btn,
			disable_warn2_btn,
			drag_offset_x,
			drag_offset_y,
			controller_start_btn,
			controller_monitor_side_btn,
		]

		# Check and disconnect any existing signal connections > Connect the signals
		for i in range(btn_array.size()):
			# Connect mouse_entered signal(regardless of type) to update tooltip
			if btn_array[i].mouse_entered.is_connected(update_tooltip):
				btn_array[i].mouse_entered.disconnect(update_tooltip)
			btn_array[i].mouse_entered.connect(update_tooltip.bind(btn_array[i]))
			# Connect focus_entered signal(regardless of type) to update tooltip
			if btn_array[i].focus_entered.is_connected(update_tooltip):
				print(str(btn_array[i].get_name(), " is already connected"))
				btn_array[i].focus_entered.disconnect(update_tooltip)
			btn_array[i].focus_entered.connect(update_tooltip.bind(btn_array[i]))

			# Connect signal of each type that performs the action of the button
			if btn_array[i] is Button:
				if btn_array[i].button_up.is_connected(_on_button_button_up):
					btn_array[i].button_up.disconnect(_on_button_button_up)
				btn_array[i].button_up.connect(_on_button_button_up.bind(btn_array[i]))
			
			if btn_array[i] is CheckButton:
				if btn_array[i].toggled.is_connected(_on_checkbutton_toggled):
					btn_array[i].toggled.disconnect(_on_checkbutton_toggled)
				btn_array[i].toggled.connect(_on_checkbutton_toggled.bind(btn_array[i]))
			
			elif btn_array[i] is OptionButton:
				if btn_array[i].item_selected.is_connected(_on_optbtn_item_selected):
					btn_array[i].item_selected.disconnect(_on_optbtn_item_selected)
				btn_array[i].item_selected.connect(_on_optbtn_item_selected.bind(btn_array[i]))
			
			elif btn_array[i] is LineEdit:
				if btn_array[i].text_submitted.is_connected(_on_line_edit_text_submitted):
					btn_array[i].text_submitted.disconnect(_on_line_edit_text_submitted)
				btn_array[i].text_submitted.connect(_on_line_edit_text_submitted.bind(btn_array[i]))
			
			elif btn_array[i] is SpinBox:
				if btn_array[i].value_changed.is_connected(_on_spinbox_value_changed):
					btn_array[i].value_changed.disconnect(_on_spinbox_value_changed)
				btn_array[i].value_changed.connect(_on_spinbox_value_changed.bind(btn_array[i]))
			# printerr(str(btn_array[i].get_name(), " mouse_entered signal connection status: ", btn_array[i].mouse_entered.is_connected(update_tooltip)))


		# Connect the "text submitted" signa of SpinBoxes underlying LineEdit node
		if canvas_spinbox_line == null: canvas_spinbox_line = canvas_layer_spinbox.get_line_edit()
		canvas_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(canvas_spinbox_line))

		if file_count_spinbox_line == null: file_count_spinbox_line = file_count_spinbox.get_line_edit()
		file_count_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(file_count_spinbox_line))

		if entry_count_spinbox_line == null: entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
		entry_count_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(entry_count_spinbox_line))

		if session_duration_spinbox_line == null: session_duration_spinbox_line = session_duration_spinbox.get_line_edit()
		session_duration_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(session_duration_spinbox_line))

		if dragx_line == null: dragx_line = drag_offset_x.get_line_edit()
		dragx_line.focus_entered.connect(update_tooltip.bind(dragx_line))

		if dragy_line == null: dragy_line = drag_offset_y.get_line_edit()
		dragy_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(dragy_line))
	
		
		container_array = [
			base_dir_btn_container,
			log_header_container,
			canvas_layer_container,
			limit_method_container,
			limit_action_container,
			file_count_container,
			entry_count_container,
			session_duration_container,
			drag_offset_container,
			error_rep_container,
			session_print_container
		]
		
		var corresponding_btns = [
			base_dir_line,
			log_header_btn,
			canvas_layer_spinbox,
			limit_method_btn,
			limit_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			drag_offset_x,
			error_rep_btn,
			session_print_btn
		]

		# Connect mouse + focus_entered signals to container nodes
		for i in range(container_array.size()):
			if container_array[i].mouse_entered.is_connected(update_tooltip):
				container_array[i].mouse_entered.disconnect(update_tooltip)
			container_array[i].mouse_entered.connect(update_tooltip.bind(corresponding_btns[i]))
			
			# printerr(str(container_array[i].get_name(), " mouse_entered signal connection status: ", container_array[i].mouse_entered.is_connected(update_tooltip)))
		load_settings_state()
	

#region settings.ini
func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, true], ["player", 1, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "log_header", 0)
	config.set_value("settings", "canvaslayer_layer", 5)
	config.set_value("settings", "autostart_session", true)
	config.set_value("settings", "timestamp_entries", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "dash_separator", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "limit_action", 0)
	config.set_value("settings", "file_cap", 10)
	config.set_value("settings", "entry_cap", 1000)
	config.set_value("settings", "session_duration", 600.0)
	config.set_value("settings", "controller_xpos", 0.0)
	config.set_value("settings", "controller_ypos", 0.0)
	config.set_value("settings", "drag_offset_x", 0.0)
	config.set_value("settings", "drag_offset_y", 0.0)
	config.set_value("settings", "show_controller", false)
	config.set_value("settings", "controller_monitor_side", true)
	config.set_value("settings", "error_reporting", 0)
	config.set_value("settings", "session_print", 0)
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))


## Sets the state of all the buttons in the dock depending on the settings retrived
## from the settings.ini.
func load_settings_state() -> void:
	base_dir_line.text = 							config.get_value("plugin", 	 "base_directory")
	log_header_btn.selected = 						config.get_value("settings", "log_header")
	canvas_layer_spinbox.value = 					config.get_value("settings", "canvaslayer_layer")
	autostart_btn.button_pressed = 					config.get_value("settings", "autostart_session")
	timestamp_entries_btn.button_pressed = 			config.get_value("settings", "timestamp_entries")
	utc_btn.button_pressed = 						config.get_value("settings", "use_utc")
	dash_btn.button_pressed = 						config.get_value("settings", "dash_separator")
	limit_method_btn.selected = 					config.get_value("settings", "limit_method")
	limit_action_btn.selected = 					config.get_value("settings", "limit_action")
	file_count_spinbox.value = 						config.get_value("settings", "file_cap")
	entry_count_spinbox.value = 					config.get_value("settings", "entry_cap")
	session_duration_spinbox.value = 				config.get_value("settings", "session_duration")
	controller_xpos_spinbox.value =					config.get_value("settings", "controller_xpos")
	controller_ypos_spinbox.value =					config.get_value("settings", "controller_ypos")
	drag_offset_x.value = 							config.get_value("settings", "drag_offset_x")
	drag_offset_y.value = 							config.get_value("settings", "drag_offset_y")
	controller_start_btn.button_pressed = 			config.get_value("settings", "show_controller")
	controller_monitor_side_btn.button_pressed = 	config.get_value("settings", "controller_monitor_side")
	error_rep_btn.selected = 						config.get_value("settings", "error_reporting")
	session_print_btn.selected =					config.get_value("settings", "session_print")
	disable_warn1_btn.button_pressed = 				config.get_value("settings", "disable_warn1")
	disable_warn2_btn.button_pressed = 				config.get_value("settings", "disable_warn2")



## Resets the categories to default by removing any existing category elements, 
## overwriting the saved categories in the .ini file and then loading default 
## categories "game" and "player".
func reset_to_default(tab : int) -> void:
	if tab == 0: # Categories
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
		config.save(PATH)
		if !config:
			var _e = config.get_open_error()
			printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))

	# Settings
	else: 
		config.clear()
		create_settings_file()
		load_settings_state()
#endregion




#region Tooltip
## Updates the tooltip with pertinent information about each setting on mouseover and focus entered.
func update_tooltip(node : Control) -> void:
	match node:
		reset_settings_btn:
			tooltip_lbl.text = "[font_size=14][color=red]Reset Settings to Default:[color=white][font_size=11]\nReset all settings to their default values."

		# String settings [LineEdits]
		base_dir_line:
			tooltip_lbl.text = "[font_size=14][color=green]Base Directory:[color=white][font_size=11]\nThe base directory used to create and store log files within."
		base_dir_reset_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Base Directory:[color=white][font_size=11]\nThe base directory used to create and store log files within.\n[color=orange]Resets the base directory to the default:\n[center]user://GoLogger/"
		base_dir_opendir_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Base Directory:[color=white][font_size=11]\nThe base directory used to create and store log files within.\n[color=orange]Opens the currently applied base directory folder."
		base_dir_apply_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Base Directory:[color=white][font_size=11]\nThe base directory used to create and store log files within.\n[color=orange]Reverts back if directory creation/access failed."

		# Bool settings [CheckButtons]
		autostart_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Autostart Session:[color=white][font_size=11]\nAutostarts a session when running your project."
		timestamp_entries_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Timestamp entries inside log files:[color=white][font_size=11]\nEnables whether or not entries are timestamped inside the log files.\n[i]Recommended to turn on.[/i]"
		utc_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Use UTC:[color=white][font_size=11] Uses UTC time for date/timestamps as opposed to the local system time."
		dash_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Use '-' Separator:[color=white][font_size=11]\nUses dashes(-) to separate date/timestamps. \nEnabled: category_name(yy-mm-dd_hh-mm-ss).log\nDisabled: category_name(yymmdd_hhmmss).log"
		controller_start_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Show GoLogger Controller at Runtime:[color=white][font_size=11]\nShows the controller by default When running your project."
		controller_monitor_side_btn:
			tooltip_lbl.text = "[font_size=14][color=green]LogFile Monitoring Default Side:[color=white][font_size=11]\nSets the side(left or right) of the monitoring panel."
		disable_warn1_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Disable Warning:[color=white][font_size=11]\nEnable/disable the warning 'Failed to start session without stopping the previous'."
		disable_warn2_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Disable Warning:[color=white][font_size=11]\nEnable/disable the warning 'Failed to log entry due to no session being active."

		# Enum-style int settings [OptionButtons]
		log_header_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Log Header:[color=white][font_size=11]\nUsed to set what to include in the log header. Project name and version is fetched from Project Settings."
		limit_method_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Limit Method:[color=white][font_size=11]\nMethod used to limit log file length/size. Used in conjunction with 'Limit Action' which dictates the action taken when method condition is met."
		limit_action_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Limit Action:[color=white][font_size=11]\nAction taken when 'Limit Method' condition is met. "
		error_rep_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Error Reporting:[color=white][font_size=11]\nAllows you to disable non-critical errors and/or warnings. Using 'Warnings only' converts non-critical errors to warnings, 'None' turns all warnings and non-critical errors."
		session_print_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Print Session Changes:[color=white][font_size=11]\nGoLogger can print to Output whenever its base functions are called."
		
		# Int settings [SpinBoxes]
		entry_count_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]Entry Count Limit:[color=white][font_size=11]\nEntry count limit of any log. Used when 'Limit Method' is set to use Entry Count."
		session_duration_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]Session Duration:[color=white][font_size=11]\nWait time for the Session Timer. Used when 'Limit Method' is set to use Session Timer."
		file_count_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]File Limit:[color=white][font_size=11]\nFile count limit. Limits the number of files in any log category folder."
		canvas_layer_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]CanvasLayer Layer:[color=white][font_size=11]\nSets the layer of the CanvasLayer node that contains the in-game Controller and the 'Save copy' popup."
		controller_xpos_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]Position of GoLoggerController:[color=white][font_size=11]\nSets the original/start position of the GoLoggerController."
		controller_ypos_spinbox:
			tooltip_lbl.text = "[font_size=14][color=green]Position of GoLoggerController:[color=white][font_size=11]\nSets the original/start position of the GoLoggerController."
		drag_offset_x:
			tooltip_lbl.text = "[font_size=14][color=green]Controller Drag Offset:[color=white][font_size=11]\nController window drag offset. Used to correct the window position while dragging if needed."
		drag_offset_y:
			tooltip_lbl.text = "[font_size=14][color=green]Controller Drag Offset:[color=white][font_size=11]\nController window drag offset. Used to correct the window position while dragging if needed."
#endregion


#region Buttons
func _on_button_button_up(node : Button) -> void:
	match node:
		base_dir_apply_btn:
			var old_dir = config.get_value("plugin", "base_directory")
			var new = base_dir_line.text
			var _d = DirAccess.open(new)
			_d.make_dir(new)
			var _e = DirAccess.get_open_error()
			if _e == OK: # New directory approved and created
				save_setting("plugin", "base_directory", new)
			else: # New directory rejected
				base_dir_line = old_dir
		
		base_dir_opendir_btn:
			open_directory()

		base_dir_reset_btn:
			config.set_value("plugin", "base_directory", "user://GoLogger/")
#endregion


#region LineEdits
func _on_line_edit_text_submitted(new_text : String, node : LineEdit) -> void:
	match node:
		base_dir_line:
			var old_dir = config.get_value("plugin", "base_directory")
			var _d = DirAccess.open(new_text)
			_d.make_dir(new_text)
			var _e = DirAccess.get_open_error()
			# Create directory was successful > Allow/set as new directory
			if _e == OK:
				save_setting("plugin", "base_directory", new_text)
			else:
				print(_e)
				base_dir_line.text = old_dir
			base_dir_line.release_focus()
#endregion


#region OptionButtons
func _on_optbtn_item_selected(index : int, node : OptionButton) -> void:
	match node:
		log_header_btn:
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
		limit_method_btn:
			config.set_value("settings", "limit_method", index)
		limit_action_btn:
			config.set_value("settings", "limit_action", index)
		error_rep_btn:
			config.set_value("settings", "error_reporting", index)
		session_print_btn:
			config.set_value("settings", "print_session_changes", index)
	
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))
#endregion


#region CheckButtons
func _on_checkbutton_toggled(toggled_on : bool, node : CheckButton) -> void:
	match node:
		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)
		timestamp_entries_btn:
			config.set_value("settings", "timestamp_entries", toggled_on)
		utc_btn:
			config.set_value("settings", "use_utc", toggled_on)
		dash_btn:
			config.set_value("settings", "dash_separator", toggled_on)
		controller_start_btn:
			config.set_value("settings", "show_controller", toggled_on)
		controller_monitor_side_btn:
			config.set_value("settings", "controller_monitor_side", toggled_on)
		disable_warn1_btn:
			config.set_value("settings", "disable_warn1", toggled_on)
		disable_warn2_btn:
			config.set_value("settings", "disable_warn2", toggled_on)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))
#endregion


#region Spinboxes
func _on_spinbox_value_changed(value : float, node : SpinBox) -> void:
	var u_line = node.get_line_edit()
	# printerr(str("textsubmit connx status = ", u_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted)))
	u_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(u_line))
	# printerr(str("textsubmit connx status = ", u_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted)))
	u_line.set_caret_column(u_line.text.length())
	# print(str("Line Edit value_changed: ", node.get_name, " - ", value, ". ", u_line.get_name()))
	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_cap", value)
		session_duration_spinbox:
			config.set_value("settings", "session_duration", value)
		file_count_spinbox:
			config.set_value("settings", "file_cap", value)
		canvas_layer_spinbox:
			config.set_value("settings", "canvaslayer_layer", value)
		controller_xpos_spinbox:
			config.set_value("settings", "controller_start_pos_x", value)
		controller_ypos_spinbox:
			config.set_value("settings", "controller_start_pos_y", value)
		drag_offset_x:
			config.set_value("settings", "controller_drag_offset_x", value)
		drag_offset_y:
			config.set_value("settings", "controller_drag_offset_y", value)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))

func _on_spinbox_lineedit_submitted(new_text : String, node : Control) -> void:
	print(str("Line Edit text_submitted: ", node.get_name, " - ", new_text, "."))
	match node:
		canvas_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "canvaslayer_layer", value)
			canvas_layer_spinbox.release_focus()
			canvas_spinbox_line.release_focus()
		file_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "file_cap", value)
			file_count_spinbox_line.release_focus()
			file_count_spinbox.release_focus()
		entry_count_spinbox_line:
			var value = int(new_text)
			config.set_value("settings", "entry_cap", value)
			entry_count_spinbox.release_focus()
			entry_count_spinbox_line.release_focus()
		session_duration_spinbox_line:
			var value = float(new_text)
			config.set_value("settings", "session_duration", value)
			session_duration_spinbox.release_focus()
			session_duration_spinbox_line.release_focus()
		dragx_line:
			var value = float(new_text)
			if value >= drag_offset_x.min_value or value <= drag_offset_x.max_value:
				config.set_value("settings", "controller_drag_offset_x", value)
				drag_offset_x.release_focus()
				dragx_line.release_focus()
		dragy_line:
			var value = float(new_text)
			if value >= drag_offset_y.min_value or value <= drag_offset_y.max_value:
				config.set_value("settings", "controller_drag_offset_y", value)
				drag_offset_y.release_focus()
				dragy_line.release_focus()
	# node.release_focus()
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))
#endregion



#region Main category functions
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
	# config.set_value("plugin", "base_directory", config.get_value("plugin", "base_directory"))
	config.set_value("plugin", "categories", main)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))



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
			# printerr(str("Found conflicting category name on: ", i.category_name, "[", i, "] - ", obj.category_name, "[", obj, "]\nall children: ", category_container.get_children()))
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
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))
	# printt("Update indices:\n", refresh_table)
#endregion



#region Settings
func save_setting(value, key : String, section : String = "settings") -> void:
	config.set_value(section, key, value)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))


func open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(config.get_value("plugin", "base_directory"))
	print(abs_path)
	OS.shell_open(abs_path)
#endregion








## Returns error string from the error code passed.
static func get_error(error : int, object_type : String = "") -> String:
	match error: 
		1:  return str("Error[1] ",  object_type, " Failed")
		2:  return str("Error[2] ",  object_type, " Unavailable")
		3:  return str("Error[3] ",  object_type, " Unconfigured")
		4:  return str("Error[4] ",  object_type, " Unauthorized")
		5:  return str("Error[5] ",  object_type, " Parameter range")
		6:  return str("Error[6] ",  object_type, " Out of memory")
		7:  return str("Error[7] ",  object_type, " File: Not found")
		8:  return str("Error[8] ",  object_type, " File: Bad drive")
		9:  return str("Error[9] ",  object_type, " File: Bad File path")
		10: return str("Error[10] ", object_type, " No File permission")
		11: return str("Error[11] ", object_type, " File already in use")
		12: return str("Error[12] ", object_type, " Can't open File")
		13: return str("Error[13] ", object_type, " Can't write to File")
		14: return str("Error[14] ", object_type, " Can't read to File")
		15: return str("Error[15] ", object_type, " File unrecognized")
		16: return str("Error[16] ", object_type, " File corrupt")
		17: return str("Error[17] ", object_type, " File missing dependencies")
		18: return str("Error[18] ", object_type, " End of File")
		19: return str("Error[19] ", object_type, " Can't open")
		20: return str("Error[20] ", object_type, " Can't create")
		21: return str("Error[21] ", object_type, " Query failed")
		22: return str("Error[22] ", object_type, " Already in use")
		23: return str("Error[23] ", object_type, " Locked")
		24: return str("Error[24] ", object_type, " Timeout")
		25: return str("Error[25] ", object_type, " Can't connect")
		26: return str("Error[26] ", object_type, " Can't resolve")
		27: return str("Error[27] ", object_type, " Connection error")
		28: return str("Error[28] ", object_type, " Can't acquire resource")
		29: return str("Error[29] ", object_type, " Can't fork process")
		30: return str("Error[30] ", object_type, " Invalid data")
		31: return str("Error[31] ", object_type, " Invalid parameter")
		32: return str("Error[32] ", object_type, " Already exists")
		33: return str("Error[33] ", object_type, " Doesn't exist")
		34: return str("Error[34] ", object_type, " Database: Can't read")
		35: return str("Error[35] ", object_type, " Database: Can't write")
		36: return str("Error[36] ", object_type, " Compilation failed")
		37: return str("Error[37] ", object_type, " Method not found")
		38: return str("Error[38] ", object_type, " Link failed")
		39: return str("Error[39] ", object_type, " Script failed")
		40: return str("Error[40] ", object_type, " Cyclic link")
		41: return str("Error[41] ", object_type, " Invalid declaration")
		42: return str("Error[42] ", object_type, " Duplicate symbol")
		43: return str("Error[43] ", object_type, " Parse error")
		44: return str("Error[44] ", object_type, " Busy error")
		46: return str("Error[45] ", object_type, " Skip error")
		47: return str("Error[46] ", object_type, " Help error")
		48: return str("Error[47] ", object_type, " Bug error")
	return "N/A"