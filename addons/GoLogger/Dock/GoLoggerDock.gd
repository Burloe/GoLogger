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

@onready var base_dir_line : LineEdit = %BaseDirLineEdit
@onready var base_dir_apply_btn : Button = %BaseDirApplyButton
@onready var base_dir_opendir_btn : Button = %BaseDirOpenDirButton
@onready var base_dir_reset_btn : Button = %BaseDirResetButton
@onready var base_dir_btn_container : HBoxContainer = %BaseDirBtnContainer

@onready var log_header_btn : OptionButton = %LogHeaderOptButton
@onready var log_header_container : HBoxContainer = %LogHeaderHBox
var log_header_string : String

@onready var canvas_layer_spinbox : SpinBox = %CanvasLayerSpinBox
var canvas_spinbox_line 
@onready var canvas_layer_container : HBoxContainer = %CanvasLayerHBox


@onready var autostart_btn : CheckButton = %AutostartCheckButton

@onready var utc_btn : CheckButton = %UTCCheckButton

@onready var dash_btn : CheckButton = %SeparatorCheckButton


@onready var limit_method_btn : OptionButton = %LimitMethodOptButton

@onready var limit_method_container : HBoxContainer = %LimitMethodHBox

@onready var limit_action_btn : OptionButton = %LimitActionOptButton 

@onready var limit_action_container : HBoxContainer = %LimitActionHBox

@onready var file_count_spinbox : SpinBox = %FileCountSpinBox
var file_count_spinbox_line
@onready var file_count_container : HBoxContainer = %FileCountHBox

@onready var entry_count_spinbox : SpinBox = %EntryCountSpinBox
var entry_count_spinbox_line
@onready var entry_count_container : HBoxContainer = %EntryCountHBox

@onready var session_duration_spinbox : SpinBox = %SessionDurationHBox/SessionDurationSpinBox
var session_duration_spinbox_line
@onready var session_duration_container : HBoxContainer = %SessionDurationHBox


@onready var drag_offset_x : SpinBox = %XSpinBox
var dragx_line

@onready var drag_offset_y : SpinBox = %YSpinBox
var dragy_line
@onready var drag_offset_container : HBoxContainer = %DragOffsetHBox



@onready var controller_start_btn : CheckButton = %ShowOnStartCheckButton

@onready var controller_monitor_side_btn : CheckButton = %MonitorSideCheckButton

@onready var error_rep_btn : OptionButton = %ErrorRepOptButton
@onready var error_rep_container : HBoxContainer = %ErrorRepHBox

@onready var session_print_btn : OptionButton = %SessionChangeOptButton
@onready var session_print_container : HBoxContainer = %SessionDurationHBox


@onready var disable_warn1_btn : CheckButton = %DisableWarn1CheckButton
@onready var disable_warn2_btn : CheckButton = %DisableWarn2CheckButton 
var btn_array : Array[Control] = []
var container_array : Array[Control] = []
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
		base_dir_line.text = config.get_value("plugin", "base_directory")
		btn_array = [
			base_dir_line,
			base_dir_apply_btn,
			base_dir_opendir_btn,
			base_dir_reset_btn,
			log_header_btn,
			canvas_layer_spinbox,
			autostart_btn,
			utc_btn,
			dash_btn,
			limit_method_btn,
			limit_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			drag_offset_x,
			drag_offset_y,
			controller_start_btn,
			controller_monitor_side_btn,
			error_rep_btn,
			session_print_btn,
			disable_warn1_btn,
			disable_warn2_btn
		]

		# Check and disconnect any existing signal connections > Connect the signals
		for i in range(btn_array.size()):
			if btn_array[i].mouse_entered.is_connected(update_tooltip):
				btn_array[i].mouse_entered.disconnect(update_tooltip)
			btn_array[i].mouse_entered.connect(update_tooltip.bind(btn_array[i]))
			
			if btn_array[i].focus_entered.is_connected(update_tooltip):
				print(str(btn_array[i].get_name(), " is already connected"))
				btn_array[i].focus_entered.disconnect(update_tooltip)
			btn_array[i].focus_entered.connect(update_tooltip.bind(btn_array[i]))


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


		# Connect the underlying LineEdit signal "text submitted" of all the SpinBoxes
		if canvas_spinbox_line == null: canvas_spinbox_line = canvas_layer_spinbox.get_line_edit()
		canvas_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(canvas_spinbox_line))

		if file_count_spinbox_line == null: file_count_spinbox_line = file_count_spinbox.get_line_edit()
		file_count_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(file_count_spinbox_line))

		if entry_count_spinbox_line == null: entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
		entry_count_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(entry_count_spinbox_line))

		if session_duration_spinbox_line == null: session_duration_spinbox_line = session_duration_spinbox.get_line_edit()
		session_duration_spinbox_line.text_submitted.connect(_on_line_edit_text_submitted.bind(session_duration_spinbox_line))

		if dragx_line == null: dragx_line = drag_offset_x.get_line_edit()
		dragx_line.focus_entered.connect(update_tooltip.bind(drag_offset_x))

		if dragy_line == null: dragy_line = drag_offset_y.get_line_edit()
		dragy_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(drag_offset_y))

		
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

		# Check and disconnect any existing signal connections > Connect signals
		for i in range(container_array.size()):
			if container_array[i].mouse_entered.is_connected(update_tooltip):
				container_array[i].mouse_entered.disconnect(update_tooltip)
			container_array[i].mouse_entered.connect(update_tooltip.bind(corresponding_btns[i]))
			
			printerr(str(container_array[i].get_name(), " mouse_entered signal connection status: ", 
			container_array[i].mouse_entered.is_connected(update_tooltip)))

	

#region Tooltip
func update_tooltip(node : Control) -> void:
	match node:
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

		# Enum settings [OptionButtons]
		log_header_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Log Header:[color=white][font_size=11]\nUsed to set what to include in the log header. Project name and version is fetched from Project Settings."
		limit_method_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Limit Method:[color=white][font_size=11]\nMethod used to limit log file length/size. Used in conjunction with 'Limit Action' which dictates the action taken when method condition is met."
		limit_action_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Limit Action:[color=white][font_size=11]\nAction taken when 'Limit Method' condition is met. "
		error_rep_btn:
			tooltip_lbl.text = "[font_size=14][color=green]Error Reporting:[color=white][font_size=11]\nSome of the errors and warnings GoLogger provides are not always useful. Set whether or not you want to disable errors, warnings or both."
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
		drag_offset_x:
			tooltip_lbl.text = "[font_size=14][color=green]Controller Drag Offset:[color=white][font_size=11]\nController window drag offset. Used to correct the window position while dragging if needed."
		drag_offset_y:
			tooltip_lbl.text = "[font_size=14][color=green]Controller Drag Offset:[color=white][font_size=11]\nController window drag offset. Used to correct the window position while dragging if needed."
		
		
		 
#endregion

# func _on_basedir_text_submitted(new_text : String) -> void:
# 	var old_dir = config.get_value("plugin", "base_directory")
# 	var _d = DirAccess.open(new_text)
# 	_d.make_dir(new_text)
# 	var _e = DirAccess.get_open_error()
# 	# Create directory was successful > Allow/set as new directory
# 	if _e == OK:
# 		save_setting("plugin", "base_directory", new_text)
# 	else:
# 		print(_e)
# 		base_dir_line.text = old_dir
# 	base_dir_line.release_focus()


# func _on_basedir_button_up(btn : Button) -> void:
# 	match btn:
# 		base_dir_reset_btn:
# 			config.set_value("plugin", "base_directory", "user://GoLogger/")
# 		base_dir_opendir_btn:
# 			open_directory()
# 		base_dir_apply_btn:
# 			var old_dir = config.get_value("plugin", "base_directory")
# 			var new = base_dir_line.text
# 			var _d = DirAccess.open(new)
# 			_d.make_dir(new)
# 			var _e = DirAccess.get_open_error()
# 			if _e == OK: # New directory approved and created
# 				save_setting("plugin", "base_directory", new)
# 			else: # New directory rejected
# 				base_dir_line = old_dir 
# 	base_dir_line.release_focus()
#endregion


#region Button
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

#region LineEdit
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
	
	config.save(PATH)
#endregion


#region CheckButtons
func _on_checkbutton_toggled(toggled_on : bool, node : CheckButton) -> void:
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
func _on_spinbox_value_changed(value : float, node : SpinBox) -> void:
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