@tool
extends TabContainer

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
#endregion


#region Settings tab
@onready var tooltip : Panel = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/ToolTip
@onready var tooltip_lbl : RichTextLabel = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/ToolTip/MarginContainer/Label

@onready var base_dir_node : LineEdit = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/BaseDirLineEdit
@onready var base_dir_apply_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/ApplyButton
@onready var base_dir_opendir_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/OpenDirButton
@onready var base_dir_reset_btn : Button = $Settings/MarginContainer/Panel/HBoxContainer/ColumnA/VBox/HBoxContainer2/ResetButton

@onready var log_header_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/LogHeaderHBox/LogHeaderOptButton
@onready var log_header_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/LogHeaderHBox
var log_header_string : String

@onready var canvas_layer_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/CanvasLayerHBox/CanvasLayerSpinBox
var canvas_spinbox_line 
@onready var canvas_layer_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/CanvasLayerHBox


@onready var autostart_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/AutostartCheckButton 

@onready var utc_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/UTCCheckButton

@onready var dash_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnB/VBoxContainer/SeparatorCheckButton


@onready var limit_method_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/LimitMethodHBox/LimitMethodOptButton

@onready var limit_method_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/LimitMethodHBox

@onready var limit_action_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/LimitActionHBox/LimitActionOptButton 

@onready var limit_action_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/LimitActionHBox


@onready var file_count_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/FileCountHBox/FileCountSpinBox
var file_count_spinbox_line
@onready var file_count_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/FileCountHBox

@onready var entry_count_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/EntryCountHBox/EntryCountSpinBox
var entry_count_spinbox_line
@onready var entry_count_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/EntryCountHBox

@onready var session_duration_spinbox : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/SessionDurationHBox/SessionDurationSpinBox
var session_duration_spinbox_line
@onready var session_duration_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnC/HBoxContainer/VBoxContainer/SessionDurationHBox


@onready var drag_offset_x : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/DragOffsetHBox/XSpinBox
var dragx_line

@onready var drag_offset_y : SpinBox = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/DragOffsetHBox/YSpinBox
var dragy_line
@onready var drag_offset_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/DragOffsetHBox



@onready var controller_start_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/ShowOnStartCheckButton

@onready var controller_monitor_side_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/MonitorSideCheckButton

@onready var error_rep_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/ErrorRepHBox/ErrorRepOptButton
@onready var error_rep_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/ErrorRepHBox

@onready var session_print_btn : OptionButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/SessionDurationHBox/SessionChangeOptButton
@onready var session_print_container : HBoxContainer = $Settings/MarginContainer/Panel/HBoxContainer/ColumnD/VBoxContainer/SessionDurationHBox


@onready var disable_warn1_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnE/Column/DisableWarn1CheckButton
@onready var disable_warn2_btn : CheckButton = $Settings/MarginContainer/Panel/HBoxContainer/ColumnE/Column/DisableWarn2CheckButton 
#endregion



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
		if canvas_spinbox_line == null: canvas_spinbox_line = canvas_layer_spinbox.get_line_edit()
		if file_count_spinbox_line == null: file_count_spinbox_line = file_count_spinbox.get_line_edit()
		if entry_count_spinbox_line == null: entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
		if session_duration_spinbox_line == null: session_duration_spinbox_line = session_duration_spinbox.get_line_edit()
		if dragx_line == null: dragx_line = drag_offset_x.get_line_edit()
		if dragy_line == null: dragy_line = drag_offset_y.get_line_edit()
		# Base directory
		base_dir_node.text_submitted.connect(_on_basedir_text_submitted)
		base_dir_node.mouse_entered.connect(update_tooltip.bind(base_dir_node))
		base_dir_node.focus_entered.connect(update_tooltip.bind(base_dir_node))
		base_dir_reset_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_reset_btn))
		base_dir_reset_btn.mouse_entered.connect(update_tooltip.bind(base_dir_reset_btn))
		base_dir_reset_btn.focus_entered.connect(update_tooltip.bind(base_dir_reset_btn))

		base_dir_opendir_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_opendir_btn))
		base_dir_opendir_btn.mouse_entered.connect(update_tooltip.bind(base_dir_opendir_btn))
		base_dir_opendir_btn.focus_entered.connect(update_tooltip.bind(base_dir_opendir_btn))

		base_dir_apply_btn.button_up.connect(_on_basedir_button_up.bind(base_dir_apply_btn))
		base_dir_apply_btn.mouse_entered.connect(update_tooltip.bind(base_dir_apply_btn))
		base_dir_apply_btn.focus_entered.connect(update_tooltip.bind(base_dir_apply_btn))
		base_dir_node.text = config.get_value("plugin", "base_directory")

		log_header_btn.item_selected.connect(_on_optbtn_item_selected)
		log_header_btn.mouse_entered.connect(update_tooltip.bind(log_header_btn))
		log_header_btn.focus_entered.connect(update_tooltip.bind(log_header_btn))
		log_header_container.mouse_entered.connect(update_tooltip.bind(log_header_btn)) 
		
		canvas_layer_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(canvas_layer_spinbox))
		canvas_layer_spinbox.mouse_entered.connect(update_tooltip.bind(canvas_layer_spinbox))
		canvas_layer_spinbox.focus_entered.connect(update_tooltip.bind(canvas_layer_spinbox))
		canvas_layer_container.mouse_entered.connect(update_tooltip.bind(canvas_layer_spinbox)) 

		autostart_btn.toggled.connect(_on_checkbutton_toggled.bind(autostart_btn))
		autostart_btn.mouse_entered.connect(update_tooltip.bind(autostart_btn))

		utc_btn.toggled.connect(_on_checkbutton_toggled.bind(utc_btn))
		utc_btn.mouse_entered.connect(update_tooltip.bind(utc_btn))

		dash_btn.toggled.connect(_on_checkbutton_toggled.bind(dash_btn))
		dash_btn.mouse_entered.connect(update_tooltip.bind(dash_btn))

		limit_method_btn.item_selected.connect(_on_optbtn_item_selected)
		limit_method_btn.mouse_entered.connect(update_tooltip.bind(limit_method_btn))
		limit_method_container.mouse_entered.connect(update_tooltip.bind(limit_method_btn))
		limit_method_btn.focus_entered.connect(update_tooltip.bind(limit_method_btn)) 

		limit_action_btn.item_selected.connect(_on_optbtn_item_selected)
		limit_action_container.mouse_entered.connect(update_tooltip.bind(limit_action_btn))
		limit_action_btn.mouse_entered.connect(update_tooltip.bind(limit_action_btn)) 
		limit_action_btn.focus_entered.connect(update_tooltip.bind(limit_action_btn))

		entry_count_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(entry_count_spinbox))
		entry_count_spinbox.gui_input.connect(_on_spinbox_gui_input.bind(entry_count_spinbox))
		entry_count_spinbox.mouse_entered.connect(update_tooltip.bind(entry_count_spinbox))
		entry_count_spinbox.focus_entered.connect(update_tooltip.bind(entry_count_spinbox))
		entry_count_container.mouse_entered.connect(update_tooltip.bind(entry_count_spinbox))

		session_duration_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(session_duration_spinbox))
		session_duration_spinbox.mouse_entered.connect(update_tooltip.bind(session_duration_spinbox))
		session_duration_spinbox.focus_entered.connect(update_tooltip.bind(session_duration_spinbox))
		session_duration_container.mouse_entered.connect(update_tooltip.bind(session_duration_spinbox))

		file_count_spinbox.value_changed.connect(_on_spinbox_value_changed.bind(file_count_spinbox))
		file_count_spinbox.mouse_entered.connect(update_tooltip.bind(file_count_spinbox))
		file_count_spinbox.focus_entered.connect(update_tooltip.bind(file_count_spinbox))
		file_count_container.mouse_entered.connect(update_tooltip.bind(file_count_spinbox))

		drag_offset_x.value_changed.connect(_on_spinbox_value_changed.bind(drag_offset_x))
		drag_offset_x.mouse_entered.connect(update_tooltip.bind(drag_offset_x))
		drag_offset_x.focus_entered.connect(update_tooltip.bind(drag_offset_x))
		dragx_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(dragx_line))
		drag_offset_y.value_changed.connect(_on_spinbox_value_changed.bind(drag_offset_y))
		drag_offset_y.mouse_entered.connect(update_tooltip.bind(drag_offset_y))
		drag_offset_y.focus_entered.connect(update_tooltip.bind(drag_offset_y))
		dragy_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(dragy_line))
		drag_offset_container.mouse_entered.connect(update_tooltip.bind(drag_offset_x))

		error_rep_btn.item_selected.connect(_on_optbtn_item_selected.bind(error_rep_btn))
		error_rep_btn.mouse_entered.connect(update_tooltip.bind(error_rep_btn))
		error_rep_btn.focus_entered.connect(update_tooltip.bind(error_rep_btn))
		error_rep_container.mouse_entered.connect(update_tooltip.bind(error_rep_btn))

		session_print_btn.item_selected.connect(_on_optbtn_item_selected.bind(session_print_btn))
		session_print_btn.mouse_entered.connect(update_tooltip.bind(session_print_btn))
		session_print_btn.focus_entered.connect(update_tooltip.bind(session_print_btn))
		session_print_container.mouse_entered.connect(update_tooltip.bind(session_print_btn))

		controller_start_btn.toggled.connect(_on_checkbutton_toggled.bind(controller_start_btn))
		controller_start_btn.mouse_entered.connect(update_tooltip.bind(controller_start_btn))
		controller_start_btn.focus_entered.connect(update_tooltip.bind(controller_start_btn))

		controller_monitor_side_btn.toggled.connect(_on_checkbutton_toggled.bind(controller_monitor_side_btn))
		controller_monitor_side_btn.mouse_entered.connect(update_tooltip.bind(controller_monitor_side_btn))
		controller_monitor_side_btn.focus_entered.connect(update_tooltip.bind(controller_monitor_side_btn))

		disable_warn1_btn.toggled.connect(_on_checkbutton_toggled.bind(disable_warn1_btn))
		disable_warn1_btn.mouse_entered.connect(update_tooltip.bind(disable_warn1_btn))
		disable_warn1_btn.focus_entered.connect(update_tooltip.bind(disable_warn1_btn))

		disable_warn2_btn.toggled.connect(_on_checkbutton_toggled.bind(disable_warn2_btn))
		disable_warn2_btn.mouse_entered.connect(update_tooltip.bind(disable_warn2_btn))
		disable_warn2_btn.focus_entered.connect(update_tooltip.bind(disable_warn2_btn))


#region Tooltip
func update_tooltip(node : Control) -> void:
	match node:
		# String settings [LineEdits]
		base_dir_node:
			tooltip_lbl.text = "[color=green]Base Directory:[color=white][font_size=12]\nThe base directory used to create and store log files within."
		base_dir_reset_btn:
			tooltip_lbl.text = "[color=green]Base Directory:[color=white][font_size=12]\nThe base directory used to create and store log files within.\n[color=orange]Resets the base directory to the default:\n[center]user://GoLogger/"
		base_dir_opendir_btn:
			tooltip_lbl.text = "[color=green]Base Directory:[color=white][font_size=12]\nThe base directory used to create and store log files within.\n[color=orange]Opens the currently applied base directory folder."
		base_dir_apply_btn:
			tooltip_lbl.text = "[color=green]Base Directory:[color=white][font_size=12]\nThe base directory used to create and store log files within.\n[color=orange]Reverts back if directory creation/access failed."

		# Bool settings [CheckButtons]
		autostart_btn:
			tooltip_lbl.text = "[color=green]Autostart Session:[color=white][font_size=12]\nAutostarts a session when running your project."
		utc_btn:
			tooltip_lbl.text = "[color=green]Use UTC:[color=white][font_size=12] Uses UTC time for date/timestamps as opposed to the local system time."
		dash_btn:
			tooltip_lbl.text = "[color=green]Use '-' Separator:[color=white][font_size=12]\nUses dashes(-) to separate date/timestamps. \nEnabled: category_name(yy-mm-dd_hh-mm-ss).log\nDisabled: category_name(yymmdd_hhmmss).log"
		controller_start_btn:
			tooltip_lbl.text = "[color=green]Show GoLogger Controller at Runtime:[color=white][font_size=12]\nShows the controller by default When running your project."
		controller_monitor_side_btn:
			tooltip_lbl.text = "[color=green]LogFile Monitoring Default Side:[color=white][font_size=12]\nSets the side(left or right) of the monitoring panel."
		disable_warn1_btn:
			tooltip_lbl.text = "[color=green]Disable Warning:[color=white][font_size=12]\nEnable/disable the warning 'Failed to start session without stopping the previous'."
		disable_warn2_btn:
			tooltip_lbl.text = "[color=green]Disable Warning:[color=white][font_size=12]\nEnable/disable the warning 'Failed to log entry due to no session being active."

		# Enum settings [OptionButtons]
		log_header_btn:
			tooltip_lbl.text = "[color=green]Log Header:[color=white][font_size=12]\nUsed to set what to include in the log header. Project name and version is fetched from Project Settings."
		limit_method_btn:
			tooltip_lbl.text = "[color=green]Limit Method:[color=white][font_size=12]\nMethod used to limit log file length/size. Used in conjunction with 'Limit Action' which dictates the action taken when method condition is met."
		limit_action_btn:
			tooltip_lbl.text = "[color=green]Limit Action:[color=white][font_size=12]\nAction taken when 'Limit Method' condition is met. "
		error_rep_btn:
			tooltip_lbl.text = "[color=green]Error Reporting:[color=white][font_size=12]\nSome of the errors and warnings GoLogger provides are not always useful. Set whether or not you want to disable errors, warnings or both."
		session_print_btn:
			tooltip_lbl.text = "[color=green]Print Session Changes:[color=white][font_size=12]\nGoLogger can print to Output whenever its base functions are called."
		
		# Int settings [SpinBoxes]
		entry_count_spinbox:
			tooltip_lbl.text = "[color=green]Entry Count Limit:[color=white][font_size=12]\nEntry count limit of any log. Used when 'Limit Method' is set to use Entry Count."
		session_duration_spinbox:
			tooltip_lbl.text = "[color=green]Session Duration:[color=white][font_size=12]\nWait time for the Session Timer. Used when 'Limit Method' is set to use Session Timer."
		file_count_spinbox:
			tooltip_lbl.text = "[color=green]File Limit:[color=white][font_size=12]\nFile count limit. Limits the number of files in any log category folder."
		canvas_layer_spinbox:
			tooltip_lbl.text = "[color=green]CanvasLayer Layer:[color=white][font_size=12]\nSets the layer of the CanvasLayer node that contains the in-game Controller and the 'Save copy' popup."
		drag_offset_x:
			tooltip_lbl.text = "[color=green]Controller Drag Offset:[color=white][font_size=12]\nController window drag offset. Used to correct the window position while dragging if needed."
		drag_offset_y:
			tooltip_lbl.text = "[color=green]Controller Drag Offset:[color=white][font_size=12]\nController window drag offset. Used to correct the window position while dragging if needed."
		
		
		 
#endregion


#region Base Directory
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
	
	config.save(PATH)
#endregion


#region CheckButtons
func _on_checkbutton_toggled(toggled_on : bool, node : Control) -> void:
	match node:
		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)
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
	config.save(PATH)
#endregion


#region Spinboxes
func _on_spinbox_value_changed(value : float, node : Control) -> void:
	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_count_limit", value)
		session_duration_spinbox:
			config.set_value("settings", "session_duration", value)
		file_count_spinbox:
			config.set_value("settings", "file_cap", value)
		canvas_layer_spinbox:
			config.set_value("settings", "canvaslayer_layer", value)
		drag_offset_x:
			config.set_value("settings", "controller_drag_offset_x", value)
		drag_offset_y:
			config.set_value("settings", "controller_drag_offset_y", value)
	config.save(PATH)

func _on_spinbox_lineedit_submitted(value : float, node : Control) -> void:
	match node:
		dragx_line:
			if value >= drag_offset_x.min_value or value <= drag_offset_x.max_value:
				config.set_value("settings", "controller_drag_offset_x", value)
		dragy_line:
			if value >= drag_offset_y.min_value or value <= drag_offset_y.max_value:
				config.set_value("settings", "controller_drag_offset_y", value)
	config.save(PATH)

func _on_spinbox_gui_input(event : InputEvent, node : SpinBox) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and event.is_released():
		match node:
			canvas_layer_spinbox: canvas_layer_spinbox.release_focus()
			file_count_spinbox: file_count_spinbox.release_focus()
			entry_count_spinbox: entry_count_spinbox.release_focus()
			session_duration_spinbox: session_duration_spinbox.release_focus()
			drag_offset_x: drag_offset_x.release_focus()
			drag_offset_y: drag_offset_y.release_focus()
#endregion












#region Main category functions
func create_settings_file() -> void:
	var _a : Array[Array] = [["game", 0, true], ["player", 1, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "log_header", 0)
	config.set_value("settings", "canvaslayer_layer", 5)
	config.set_value("settings", "autostart_session", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "dash_separator", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "limit_action", 0)
	config.set_value("settings", "file_cap", 10)
	config.set_value("settings", "entry_count_limit", 1000)
	config.set_value("settings", "session_duration", 600.0)
	config.set_value("settings", "controller_drag_offset_x", 0)
	config.set_value("settings", "controller_drag_offset_y", 0)
	config.set_value("settings", "show_controller", true)
	config.set_value("settings", "controller_monitor_side", true)
	config.set_value("settings", "error_reporting", 0)
	config.set_value("settings", "print_session_changes", 0)
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false)
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
	# config.set_value("plugin", "base_directory", config.get_value("plugin", "base_directory"))
	config.set_value("plugin", "categories", main)

	# config.set_value("settings", "log_header", 0)
	# config.set_value("settings", "canvaslayer_layer", 5)
	# config.set_value("settings", "autostart_session", true)
	# config.set_value("settings", "use_utc", false)
	# config.set_value("settings", "dash_separator", false)
	# config.set_value("settings", "limit_method", 0)
	# config.set_value("settings", "limit_action", 0)
	# config.set_value("settings", "file_cap", 10)
	# config.set_value("settings", "entry_count_limit", 1000)
	# config.set_value("settings", "session_duration", 600.0)
	# config.set_value("settings", "controller_drag_offset_x", 0)
	# config.set_value("settings", "controller_drag_offset_y", 0)
	# config.set_value("settings", "show_controller", true)
	# config.set_value("settings", "controller_monitor_side", true)
	# config.set_value("settings", "error_reporting", 0)
	# config.set_value("settings", "print_session_changes", 0)
	# config.set_value("settings", "disable_warn1", false)
	# config.set_value("settings", "disable_warn2", false)
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