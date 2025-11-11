@tool
extends TabContainer

# TODO:
	# Implement a print_rich() calls whenever a setting is changed to notify the user of the change in the output console.
	# Add new setting for the custom header format called "log_header_fomat" to the config file creation, saving and loading logic <see Log.gd _get_header() for reference>

signal update_index

@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton
@onready var defaults_btn: Button = %DefaultsCatButton
@onready var category_warning_lbl: Label = %CategoryWarningLabel

@onready var columns_slider: HSlider = %ColumnsHSlider
@onready var reset_settings_btn: Button = %ResetSettingsButton

@onready var base_dir_line: LineEdit = %BaseDirLineEdit
@onready var base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var base_dir_opendir_btn: Button = %BaseDirOpenDirButton
@onready var base_dir_reset_btn: Button = %BaseDirResetButton

@onready var log_header_line: LineEdit = %LogHeaderLineEdit
@onready var log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var log_header_reset_btn: Button = %LogHeaderResetButton

@onready var entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var entry_format_reset_btn: Button = %EntryFormatResetButton
@onready var entry_format_warning: Panel = %EntryFormatWarning

@onready var log_header_btn: OptionButton = %LogHeaderOptButton
@onready var log_header_container: HBoxContainer = %LogHeaderHBox
@onready var log_header_lbl: Label = %LogHeaderLabel

var canvas_spinbox_line: LineEdit
@onready var canvas_layer_spinbox: SpinBox = %CanvasLayerSpinBox
@onready var canvas_layer_lbl: Label = %CanvasLayerLabel
@onready var canvas_layer_container: HBoxContainer = %CanvasLayerHBox

@onready var autostart_btn: CheckButton = %AutostartCheckButton
@onready var timestamp_entries_btn: CheckButton = %TimestampEntriesButton
@onready var utc_btn: CheckButton = %UTCCheckButton
@onready var dash_btn: CheckButton = %SeparatorCheckButton

@onready var limit_method_btn: OptionButton = %LimitMethodOptButton
@onready var limit_method_lbl: Label = %LimitMethodLabel
@onready var limit_method_container: HBoxContainer = %LimitMethodHBox

@onready var entry_count_action_btn: OptionButton = %EntryActionOptButton
@onready var entry_count_action_lbl: Label = %EntryActionLabel
@onready var entry_count_action_container: HBoxContainer = %EntryCountActionHBox

@onready var session_timer_action_btn: OptionButton = %SessionTimerActionOptButton
@onready var session_timer_action_lbl: Label = %SessionTimerActionLabel
@onready var session_timer_action_container: HBoxContainer = %SessionTimerActionHBox

var file_count_spinbox_line: LineEdit
@onready var file_count_spinbox: SpinBox = %FileCountSpinBox
@onready var file_count_lbl: Label = %FileCountLabel
@onready var file_count_container: HBoxContainer = %FileCountHBox

var entry_count_spinbox_line: LineEdit
@onready var entry_count_spinbox: SpinBox = %EntryCountSpinBox
@onready var entry_count_lbl: Label = %EntryCountLabel
@onready var entry_count_container: HBoxContainer = %EntryCountHBox

var session_duration_spinbox_line: LineEdit
@onready var session_duration_spinbox: SpinBox = %SessionDurationHBox/SessionDurationSpinBox
@onready var session_duration_lbl: Label = %SessionDurationLabel
@onready var session_duration_container: HBoxContainer = %SessionDurationHBox

@onready var error_rep_btn: OptionButton = %ErrorRepOptButton
@onready var error_rep_lbl: Label = %ErrorRepLabel
@onready var error_rep_container: HBoxContainer = %ErrorRepHBox

@onready var disable_warn1_btn: CheckButton = %DisableWarn1CheckButton
@onready var disable_warn2_btn: CheckButton = %DisableWarn2CheckButton

@onready var plugin_version_cat_lbl: Label = %PluginVersionCatLabel
@onready var plugin_version_sett_lbl: Label = %PluginVersionSettLabel


const PATH = "user://GoLogger/settings.ini"

var valid_line_edit_stylebox := preload("uid://b8w5i8chks7st")
var invalid_line_edit_stylebox := preload("uid://cjxw1ngoxnqnv")
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
var config = ConfigFile.new()
var log_header_string: String
var plugin_version: String =  "1.3.2":
	set(value):
		plugin_version = value
		if plugin_version_cat_lbl != null:
			plugin_version_cat_lbl.text = str("GoLogger v.", value)
		if plugin_version_sett_lbl != null:
			plugin_version_sett_lbl.text = str("GoLogger v.", value)
var btn_array: Array[Control] = []
var container_array: Array[Control] = []
var c_font_normal := Color("9d9ea0")
var c_font_hover := Color("f2f2f2")
var c_print_history := Color("878787")

# Note that this dictionary is also present in Log.gd. If you update it here, update it there too.
var default_settings := {
		"base_directory": "user://GoLogger/",
		"log_header_format": "{project_name} {version} {category} session [{yy-mm-dd} | {hh}:mi}:{ss}]:",
		"entry_format": "[{hh}:{mi}:{ss}]: {entry}",
		"canvaslayer_layer": 5,
		"autostart_session": true,
		"use_utc": false,
		"limit_method": 0,
		"entry_count_action": 0,
		"session_timer_action": 0,
		"file_cap": 10,
		"entry_cap": 300,
		"session_duration": 300.0,
		"error_reporting": 0,
		"disable_warn1": false,
		"disable_warn2": false,
		"columns": 6
}

# When adding new settings, add the Labels and any Control nodes to the
# container_array, btns_array, corresponding_lbls arrays respectively in
# _ready() to enable the label highlighting feature.



func _ready() -> void:
	if Engine.is_editor_hint():
		entry_format_warning.visible = !_check_valid_entry_format(entry_format_line.text)

		# Ensure or create settings.ini
		var _d = DirAccess.open("user://GoLogger/")
		if !_d:
			_d = DirAccess.open(".")
			DirAccess.make_dir_absolute("user://GoLogger/")

		if !FileAccess.file_exists(PATH):
			create_settings_file()
		else:
			config.load(PATH)

		# Remove any existing categories
		for i in category_container.get_children():
			if i is LogCategory:
				i.queue_free()
			else: print_rich("GoLogger error: Uknown node in category container. Expected LogCategory, got ", i.get_name(), "\nThis is a bug, please report it to the developer @[url]https://github.com/Burloe/GoLogger/issues[/url]")

		# Load categories as saved in settings.ini
		load_categories()

		add_category_btn.button_up.connect(add_category)
		open_dir_btn.button_up.connect(open_directory)
		defaults_btn.button_up.connect(reset_to_default.bind(0))
		columns_slider.value_changed.connect(_on_columns_slider_value_changed)
		reset_settings_btn.button_up.connect(reset_to_default.bind(1))

		btn_array = [
			base_dir_line,
			base_dir_apply_btn,
			base_dir_opendir_btn,
			base_dir_reset_btn,
			log_header_line,
			log_header_apply_btn,
			entry_format_line,
			entry_format_apply_btn,
			log_header_btn,
			canvas_layer_spinbox,
			autostart_btn,
			utc_btn,
			timestamp_entries_btn,
			dash_btn,
			limit_method_btn,
			entry_count_action_btn,
			session_timer_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			error_rep_btn,
			disable_warn1_btn,
			disable_warn2_btn
		]

		for i in range(btn_array.size()):
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
				if btn_array[i].text_changed.is_connected(_on_line_edit_text_changed):
					btn_array[i].text_changed.disconnect(_on_line_edit_text_changed)
				btn_array[i].text_changed.connect(_on_line_edit_text_changed.bind(btn_array[i]))

				if btn_array[i].text_submitted.is_connected(_on_line_edit_text_submitted):
					btn_array[i].text_submitted.disconnect(_on_line_edit_text_submitted)
				btn_array[i].text_submitted.connect(_on_line_edit_text_submitted.bind(btn_array[i]))

			elif btn_array[i] is SpinBox:
				if btn_array[i].value_changed.is_connected(_on_spinbox_value_changed):
					btn_array[i].value_changed.disconnect(_on_spinbox_value_changed)
				btn_array[i].value_changed.connect(_on_spinbox_value_changed.bind(btn_array[i]))


		# Connect the "text submitted" signal of SpinBoxes underlying LineEdit node
		if canvas_spinbox_line == null: canvas_spinbox_line = canvas_layer_spinbox.get_line_edit()
		if canvas_spinbox_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted):
			canvas_spinbox_line.text_submitted.disconnect(_on_spinbox_lineedit_submitted)
		canvas_spinbox_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(canvas_spinbox_line))

		if file_count_spinbox_line == null: file_count_spinbox_line = file_count_spinbox.get_line_edit()
		if file_count_spinbox_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted):
			file_count_spinbox_line.text_submitted.disconnect(_on_spinbox_lineedit_submitted)
		file_count_spinbox_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(file_count_spinbox_line))

		if entry_count_spinbox_line == null: entry_count_spinbox_line = entry_count_spinbox.get_line_edit()
		if entry_count_spinbox_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted):
			entry_count_spinbox_line.text_submitted.disconnect(_on_spinbox_lineedit_submitted)
		entry_count_spinbox_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(entry_count_spinbox_line))

		if session_duration_spinbox_line == null: session_duration_spinbox_line = session_duration_spinbox.get_line_edit()
		if session_duration_spinbox_line.text_submitted.is_connected(_on_spinbox_lineedit_submitted):
			session_duration_spinbox_line.text_submitted.disconnect(_on_spinbox_lineedit_submitted)
		session_duration_spinbox_line.text_submitted.connect(_on_spinbox_lineedit_submitted.bind(session_duration_spinbox_line))

		container_array = [
			log_header_container,
			canvas_layer_container,
			limit_method_container,
			entry_count_action_container,
			session_timer_action_container,
			file_count_container,
			entry_count_container,
			session_duration_container,
			error_rep_container
		]

		var btns_array = [
			# base_dir_line,
			log_header_btn,
			canvas_layer_spinbox,
			limit_method_btn,
			entry_count_action_btn,
			session_timer_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			error_rep_btn
		]

		var corresponding_lbls = [
			log_header_lbl,
			canvas_layer_lbl,
			limit_method_lbl,
			entry_count_action_lbl,
			session_timer_action_lbl,
			file_count_lbl,
			entry_count_lbl,
			session_duration_lbl,
			error_rep_lbl,
		]

		for i in range(container_array.size()):
			# Update font color on mouse over containers signals
			container_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			container_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

			# Update font color on mouse over Buttons signals
			btns_array[i].mouse_entered.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], true))
			btns_array[i].mouse_exited.connect(_on_dock_mouse_hover_changed.bind(corresponding_lbls[i], false))

		load_settings_state()



func load_categories(deferred: bool = false) -> void:
	if deferred:
		await get_tree().physics_frame
	config.load(PATH)
	var _c = config.get_value("plugin", "categories")
	for i in range(_c.size()):
		var _n = category_scene.instantiate()
		_n.dock = self
		_n.is_locked = _c[i][6]
		category_container.add_child(_n)
		_n.name_warning.connect(_on_name_warning)
		_n.index_changed.connect(_on_index_changed)
		_n.category_name = _c[i][0]
		_n.index = i
	update_move_buttons()


func add_category() -> void:
	var _n = category_scene.instantiate()
	_n.dock = self
	_n.is_locked = false
	category_container.add_child(_n)
	_n.name_warning.connect(_on_name_warning)
	_n.index_changed.connect(_on_index_changed)
	_n.category_deleted.connect(_on_category_deleted)
	_n.index = category_container.get_children().size() - 1
	save_categories()
	_n.line_edit.grab_focus()
	update_move_buttons()


func save_categories(deferred: bool = false) -> void:
	# [0 category name, 1 category index, 2 current filename, 3 current filepath, 4 file count, 5 entry count, 6 is locked]
	if deferred:
		await get_tree().physics_frame
	var main : Array
	var children = category_container.get_children()
	for i in range(children.size()):
		var _n : Array = [children[i].category_name, children[i].index, children[i].file_name, children[i].file_path, children[i].file_count, children[i].entry_count, children[i].is_locked]
		main.append(_n)
	config.set_value("plugin", "categories", main)
	config.save(PATH)


func open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(config.get_value("plugin", "base_directory"))
	OS.shell_open(abs_path)


func update_category_name(cat_obj: LogCategory, new_name: String) -> void:
	var final_name = new_name
	var add_name : int = 1
	while check_conflict_name(cat_obj, final_name):
		final_name = new_name + str(add_name)
		add_name += 1
	if cat_obj.category_name != final_name:
		cat_obj.category_name = final_name
	save_categories()


func check_conflict_name(cat_obj: LogCategory, new_name: String) -> bool:
	for i in category_container.get_children():
		if i == cat_obj: # Disregard category being checked
			continue
		elif i.category_name == new_name:
			if name == "": return false
			return true
	return false


static func get_error(error: int, object_type: String = "") -> String:
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



func create_settings_file() -> void:
	var _a = [["game", 0, "null", "null", 0, 0, true], ["error", 1, "null", "null", 0, 0, true]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)
	config.set_value("settings", "log_header_format", "{project_name} {version} {category} session {yy-mm-dd} {hh:mi:ss}:")
	config.set_value("settings", "entry_format", "[{hh}:{mi}:{ss}]: {entry}")
	# config.set_value("settings", "log_header", 0)
	config.set_value("settings", "canvaslayer_layer", 5)
	config.set_value("settings", "autostart_session", true)
	# config.set_value("settings", "timestamp_entries", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "dash_separator", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "entry_count_action", 0)
	config.set_value("settings", "session_timer_action", 0)
	config.set_value("settings", "file_cap", 10)
	config.set_value("settings", "entry_cap", 300)
	config.set_value("settings", "session_duration", 300.0)
	config.set_value("settings", "error_reporting", 0)
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false)
	config.set_value("settings", "columns", 6)
	var _s = config.save(PATH)
	if _s != OK:
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_s, "ConfigFile")))


func load_settings_state() -> void:
	config.load(PATH)
	base_dir_line.text = 										config.get_value("plugin", 	 "base_directory", "user://GoLogger/")
	base_dir_apply_btn.disabled = true
	log_header_btn.selected = 							config.get_value("settings", "log_header", 0)
	canvas_layer_spinbox.value = 						config.get_value("settings", "canvaslayer_layer", 5)
	autostart_btn.button_pressed = 					config.get_value("settings", "autostart_session", true)
	timestamp_entries_btn.button_pressed = 	config.get_value("settings", "timestamp_entries", true)
	utc_btn.button_pressed = 								config.get_value("settings", "use_utc", false)
	dash_btn.button_pressed = 							config.get_value("settings", "dash_separator", false)
	limit_method_btn.selected = 						config.get_value("settings", "limit_method", 0)
	entry_count_action_btn.selected = 			config.get_value("settings", "entry_count_action", 0)
	entry_count_action_btn.selected = 			config.get_value("settings", "session_timer_action", 0)
	file_count_spinbox.value = 							config.get_value("settings", "file_cap", 10)
	entry_count_spinbox.value = 						config.get_value("settings", "entry_cap", 300)
	session_duration_spinbox.value = 				config.get_value("settings", "session_duration", 300.0)
	error_rep_btn.selected = 								config.get_value("settings", "error_reporting", 0)
	disable_warn1_btn.button_pressed = 			config.get_value("settings", "disable_warn1", false)
	disable_warn2_btn.button_pressed = 			config.get_value("settings", "disable_warn2", false)
	columns_slider.value = 									config.get_value("settings", "columns", 6)
	config.save(PATH)


func validate_settings() -> void:
	var present_settings_faults : int = 0
	var value_type_faults : int = 0
	var expected_settings ={
		"base_directory": "plugin/base_directory",
		"categories": "plugin/categories",
		"columns": "settings/columns",
		"log_header_format": "settings/log_header_format",
		"entry_format": "settings/entry_format",
		"canvaslayer_layer": "settings/canvaslayer_layer",
		"autostart_session": "settings/autostart_session",
		"use_utc": "settings/use_utc",
		"limit_method": "settings/limit_method",
		"entry_count_action": "settings/entry_count_action",
		"session_timer_action": "settings/session_timer_action",
		"file_cap": "settings/file_cap",
		"entry_cap": "settings/entry_cap",
		"session_duration": "settings/session_duration",
		"error_reporting": "settings/error_reporting",
		"disable_warn1": "settings/disable_warn1",
		"disable_warn2": "settings/disable_warn2"
	}

	var expected_types = {
		"plugin/base_directory": TYPE_STRING,
		"plugin/categories": TYPE_ARRAY,
		"settings/columns": TYPE_INT,
		"settings/log_header_format": TYPE_STRING,
		"settings/entry_format" : TYPE_STRING,
		"settings/canvaslayer_layer": TYPE_INT,
		"settings/autostart_session": TYPE_BOOL,
		"settings/use_utc": TYPE_BOOL,
		"settings/limit_method": TYPE_INT,
		"settings/entry_count_action": TYPE_INT,
		"settings/session_timer_action": TYPE_INT,
		"settings/file_cap": TYPE_INT,
		"settings/entry_cap": TYPE_INT,
		"settings/session_duration": TYPE_FLOAT,
		"settings/error_reporting": TYPE_INT,
		"settings/disable_warn1": TYPE_BOOL,
		"settings/disable_warn2": TYPE_BOOL
	}

	var types : Array[String] = [
		"Nil",
		"Bool",
		"Integer",
		"Float",
		"String",
		"Vector2",
		"Vector2i",
		"Rect2",
		"Rect2i",
		"Vector3",
		"Vector3i",
		"Color",
		"StringName",
		"Dictionary",
		"Array",
	]

	# Validate presence of settings -> Apply default if missing
	for setting in expected_settings.keys():
		var splits = expected_settings[setting].split("/")
		if !config.has_section(splits[0]) or !config.has_section_key(splits[0], splits[1]):
			printerr(str("Gologger Error: Validate settings failed. Missing setting '", splits[1], "' in section '", splits[0], "'."))
			present_settings_faults += 1
			config.set_value(splits[0], splits[1], default_settings[splits[1]])
	if present_settings_faults > 0: push_warning("GoLogger: One or more settings were missing from the settings.ini file. Default values have been restored for the missing settings.")

	# Valodate types of settings -> Apply default if type mismatch
	for setting_key in expected_types.keys():
		var splits = setting_key.split("/")
		var expected_type = expected_types[setting_key]
		var value = config.get_value(splits[0], splits[1])

		if typeof(value) != expected_type:
			printerr(str("Gologger Error: Validate settings failed. Invalid type for setting '", splits[1], "'. Expected ", types[expected_type], " but got ", types[value], "."))
			value_type_faults += 1
			config.set_value(splits[0], splits[1], default_settings[splits[1]])

	config.save(PATH)


func reset_to_default(tab : int) -> void:
	# [0 category name, 1 category index, 2 current filename, 3 current filepath, 4 file count, 5 entry count, 6 is locked]

	if tab == 0: # Categories tab
		var children = category_container.get_children()
		for i in range(children.size()):
			children[i].queue_free()

		defaults_btn.disabled = true
		add_category_btn.disabled = true
		await get_tree().create_timer(0.5).timeout
		config.set_value("plugin", "categories", [
			])
		config.save(PATH)
		load_categories()
		defaults_btn.disabled = false
		add_category_btn.disabled = false
		if !config:
			var _e = config.get_open_error()
			printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))

	else: # Settings tab
		config.clear()
		create_settings_file()
		load_settings_state()


func reorder_categories() -> void:
	var children = category_container.get_children()
	var temp: Array[LogCategory] = []

	for child in children:
		temp.append(child)
		category_container.remove_child(child)

	for i in range(temp.size() - 1):
		for j in range(i + 1, temp.size()):
			if temp[i].index > temp[j].index:
				# Swap elements
				var temp_child = temp[i]
				temp[i] = temp[j]
				temp[j] = temp_child

	for child in temp:
		category_container.add_child(child)
	category_container.queue_sort()
	var new_categories: Array[LogCategory] = []
	for child in category_container.get_children():
		new_categories.append(child)
	config.set_value("plugin", "categories", new_categories)
	config.save(PATH)
	update_move_buttons()


func update_move_buttons() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		category.move_left_btn.disabled = (category.index == 0)
		category.move_right_btn.disabled = (category.index == category_container.get_child_count() - 1)


func _on_dock_mouse_hover_changed(node: Label, is_hovered: bool) -> void:
	if is_hovered:
		node.add_theme_color_override("font_color", c_font_hover)
	else:
		node.add_theme_color_override("font_color", c_font_normal)


func _on_button_button_up(node: Button) -> void:
	config.load(PATH)
	match node:
		base_dir_apply_btn:
			var old_dir = config.get_value("plugin", "base_directory")
			var new_dir = base_dir_line.text
			var _d = DirAccess.open(new_dir)
			if _d == null:
				var _res : int
				_d = DirAccess.open(".")
				if new_dir.begins_with("res://") or new_dir.begins_with("user://"):
					_res = _d.make_dir(new_dir)
				else:
					_res = DirAccess.make_dir_absolute(new_dir)
				if _res != OK:
					if config.get_value("settings", "error_reporting") != 2:
						push_warning("GoLogger: Failed to create directory using path[", new_dir, "]. Reverting back to previous directory path[", old_dir, "].")
					base_dir_line.text = old_dir
					base_dir_apply_btn.disabled = true
					return
				_d = DirAccess.open(new_dir)
			if _d == null or DirAccess.get_open_error() != OK:
				if config.get_value("settings", "error_reporting") != 2:
					push_warning("GoLogger: Failed to access newly created directory using path[", new_dir, "]. Reverting back to previous directory path[", old_dir, "].")
				base_dir_line.text = old_dir
				base_dir_apply_btn.disabled = true
				return
			config.set_value("plugin", "base_directory", new_dir)
			config.save(PATH)
			print_rich("[color=878787][GoLogger] Base directory changed to: ", new_dir)

		base_dir_opendir_btn:
			if config.get_value("plugin", "base_directory") == "":
				push_warning("GoLogger: Base directory path isn't set. Please set a valid directory path before opening the directory.")
			open_directory()

		base_dir_reset_btn:
			config.set_value("plugin", "base_directory", "user://GoLogger/")
			config.save(PATH)
			base_dir_line.text = config.get_value("plugin", "base_directory")
			print_rich("[color=878787][GoLogger] Base directory reset to default.")

		log_header_apply_btn:
			config.set_value("settings", "log_header_format", log_header_line.text)
			config.save(PATH)

		log_header_reset_btn:
			log_header_line.text = default_settings["log_header_format"]
			config.set_value("settings", "log_header_format", default_settings["log_header_format"])
			config.save(PATH)
			print_rich("[color=878787][GoLogger] Log header option reset to default.")

		entry_format_apply_btn:
			config.set_value("settings", "entry_format", entry_format_line.text)
			config.save(PATH)
			print_rich("[color=878787][GoLogger] Entry format changed to: ", entry_format_line.text)

		entry_format_reset_btn:
			entry_format_line.text = config.get_value("settings", "entry_format", default_settings["entry_format"])
			config.set_value("settings", "entry_format", default_settings["entry_format"])
			config.save(PATH)
			print_rich("[color=878787][GoLogger] Entry format reset to default.")


func _on_line_edit_text_changed(new_text: String, node: LineEdit) -> void:
	# if node.get_caret_column() == node.text.length() - 1:
	# 	node.set_caret_column(node.text.length())
	# else: node.set_caret_column(node.get_caret_column() + 1)

	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
			if new_text != config.get_value("plugin", "base_directory"):
				base_dir_apply_btn.disabled = false
			else:
				base_dir_apply_btn.disabled = true

		log_header_line:
			if new_text != config.get_value("settings", "log_header_format", ""):
				log_header_apply_btn.disabled = false
			else:
				log_header_apply_btn.disabled = true

		entry_format_line:
			if _check_valid_entry_format(new_text):
				entry_format_line.add_theme_stylebox_override("normal", valid_line_edit_stylebox)
				entry_format_warning.visible = false
			else:
				entry_format_line.add_theme_stylebox_override("normal", invalid_line_edit_stylebox)
				entry_format_warning.visible = true

			if new_text != config.get_value("settings", "entry_format", "") and _check_valid_entry_format(new_text):
				entry_format_apply_btn.disabled = false
			else:
				entry_format_apply_btn.disabled = true




func _on_line_edit_text_submitted(new_text: String, node: LineEdit) -> void:
	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
				return

			config.load(PATH)
			var old_dir = config.get_value("plugin", "base_directory")
			var _d = DirAccess.open(new_text)
			_d.make_dir(new_text)
			var _e = DirAccess.get_open_error()
			if _e == OK:
				config.set_value("plugin", "base_directory", new_text)
			else:
				base_dir_line.text = old_dir
			base_dir_line.release_focus()

		log_header_line:
			if new_text == "": return

			config.load(PATH)
			var old_header = config.get_value("settings", "log_header_format", "")

			if new_text != old_header:
				config.set_value("settings", "log_header_format", new_text)
			log_header_line.release_focus()

		entry_format_line:
			config.load(PATH)
			var old_format = config.get_value("settings", "entry_format", "")
			if new_text != old_format:
				entry_format_apply_btn.disabled = false
			if new_text == "":
				entry_format_line.text = "{entry}"
			entry_format_line.release_focus()


func _check_valid_entry_format(format: String) -> bool:
	return true if format.contains("{entry}") else false


func _on_optbtn_item_selected(index: int, node: OptionButton) -> void:
	match node:
		log_header_btn:
			match index:
				0: # Project name & version
					var _n = str(ProjectSettings.get_setting("application/config/name"))
					var _v = str(ProjectSettings.get_setting("application/config/version"))
					if _n == "": printerr("GoLogger warning: Undefined project name in 'ProjectSettings/application/config/name'.")
					if _v == "": printerr("GoLogger warning: Undefined project version in 'ProjectSettings/application/config/version'.")
					log_header_string = str(_n, " V.", _v)
				1: # Project name
					log_header_string = str(ProjectSettings.get_setting("application/config/name"))
				2: # Version
					log_header_string = str("Version.", ProjectSettings.get_setting("application/config/version"))
				3: # None
					log_header_string = ""
			config.set_value("settings", "log_header", index)

		limit_method_btn:
			config.set_value("settings", "limit_method", index)

		entry_count_action_btn:
			config.set_value("settings", "entry_count_action", index)

		session_timer_action_btn:
			config.set_value("settings", "session_timer_action", index)

		error_rep_btn:
			config.set_value("settings", "error_reporting", index)

	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))


func _on_checkbutton_toggled(toggled_on: bool, node: CheckButton) -> void:
	match node:

		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)

		timestamp_entries_btn:
			config.set_value("settings", "timestamp_entries", toggled_on)

		utc_btn:
			config.set_value("settings", "use_utc", toggled_on)

		dash_btn:
			config.set_value("settings", "dash_separator", toggled_on)

		disable_warn1_btn:
			config.set_value("settings", "disable_warn1", toggled_on)

		disable_warn2_btn:
			config.set_value("settings", "disable_warn2", toggled_on)
	config.save(PATH)


func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	var u_line = node.get_line_edit()
	u_line.set_caret_column(u_line.text.length())
	if u_line.get_caret_column() == u_line.text.length() - 1:
		u_line.set_caret_column(u_line.text.length())
	else: u_line.set_caret_column(u_line.get_caret_column() + 1)

	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_cap", int(value))

		session_duration_spinbox:
			config.set_value("settings", "session_duration", int(value))

		file_count_spinbox:
			config.set_value("settings", "file_cap", int(value))

		canvas_layer_spinbox:
			config.set_value("settings", "canvaslayer_layer", int(value))
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))


func _on_spinbox_lineedit_submitted(new_text: String, node: Control) -> void:
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

	# node.release_focus()
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))


func _on_columns_slider_value_changed(value: int) -> void:
	category_container.columns = value
	columns_slider.tooltip_text = str(value)
	config.set_value("settings", "columns", value)
	config.save(PATH)


func _on_name_warning(toggled_on: bool, type : int) -> void:
	if toggled_on:
		category_warning_lbl.visible = true
		match type:
			0: category_warning_lbl.text = "Empty category names are not used. Please enter a unique name."
			1: category_warning_lbl.text = "Names are not changed if they're not applied."
	else:
		category_warning_lbl.visible = false


func _on_index_changed(category: LogCategory, new_index: int) -> void:
	var conflict_found := false
	var _c = category_container.get_children()
	for other_category in _c:
		if other_category != category and other_category.index == new_index:
			var temp_index = category.index
			category.index = new_index
			other_category.index = temp_index
			conflict_found = true
			break
	if !conflict_found:
		category.index = new_index
	reorder_categories()
	save_categories()


func _on_category_deleted() -> void:
	await get_tree().create_timer(0.1).timeout
	print("Category deleted -> reordering category indices:\n")
	for i in range(category_container.get_child_count()):
		var category: LogCategory = category_container.get_child(i)
		category.index = i
		print("\t", category.category_name, " Category -> new index: ", category.index)
	update_move_buttons()
