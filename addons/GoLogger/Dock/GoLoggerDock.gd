@tool
extends TabContainer

# TODO:
	# Implement a print_rich() calls whenever a setting is changed to notify the user of the change in the output console.
	# [Done]Add new setting for the custom header format called "log_header_fomat" to the config file creation, saving and loading logic <see Log.gd _get_header() for reference>
	#
	# DOCK CATEGORY TAB:
		# [TBD] Remove 'category index' entirely in favor of using strings as unique identifiers for categories with regards to the new .ini format
		# Handle adding/removing categories with new .ini format
		# is_locked property handling
		# Add feature to remove setting keys from [settings] section in .ini file when saving/loading the file

signal update_index
signal change_category_name_finished

@onready var add_category_btn: Button = %AddCategoryButton
@onready var category_container: GridContainer = %CategoryGridContainer
@onready var open_dir_btn: Button = %OpenDirCatButton
@onready var defaults_btn: Button = %DefaultsCatButton
@onready var category_warning_lbl: Label = %CategoryWarningLabel

@onready var columns_slider: HSlider = %ColumnsHSlider
@onready var reset_settings_btn: Button = %ResetSettingsButton

@onready var base_dir_line: LineEdit = %BaseDirLineEdit
@onready var base_dir_lbl: Label = %BaseDirLabel
@onready var base_dir_apply_btn: Button = %BaseDirApplyButton
@onready var base_dir_opendir_btn: Button = %BaseDirOpenDirButton
@onready var base_dir_reset_btn: Button = %BaseDirResetButton
@onready var base_dir_container: HBoxContainer = %BaseDirHBox

@onready var log_header_line: LineEdit = %LogHeaderLineEdit
@onready var log_header_lbl: Label = %LogHeaderLabel
@onready var log_header_apply_btn: Button = %LogHeaderApplyButton
@onready var log_header_reset_btn: Button = %LogHeaderResetButton
@onready var log_header_container: HBoxContainer = %LogHeaderHBox

@onready var entry_format_line: LineEdit = %EntryFormatLineEdit
@onready var entry_format_lbl: Label = %EntryFormatLabel
@onready var entry_format_apply_btn: Button = %EntryFormatApplyButton
@onready var entry_format_reset_btn: Button = %EntryFormatResetButton
@onready var entry_format_warning: Panel = %EntryFormatWarning
@onready var entry_format_container: HBoxContainer = %EntryFormatHBox

var canvas_spinbox_line: LineEdit
@onready var canvas_layer_spinbox: SpinBox = %CanvasLayerSpinBox
@onready var canvas_layer_lbl: Label = %CanvasLayerLabel
@onready var canvas_layer_container: HBoxContainer = %CanvasLayerHBox

@onready var autostart_btn: CheckButton = %AutostartCheckButton
@onready var utc_btn: CheckButton = %UTCCheckButton

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

@onready var plugin_version_cat_lbl: Label = %PluginVersionCatLabel
@onready var plugin_version_sett_lbl: Label = %PluginVersionSettLabel


const PATH = "user://GoLogger/settings.ini"

var valid_line_edit_stylebox := preload("uid://b8w5i8chks7st")
var invalid_line_edit_stylebox := preload("uid://cjxw1ngoxnqnv")
var category_scene = preload("res://addons/GoLogger/Dock/LogCategory.tscn")
var config = ConfigFile.new()
var plugin_version: String =  "1.3.2":
	set(value):
		plugin_version = value
		if plugin_version_cat_lbl != null:
			plugin_version_cat_lbl.text = str("GoLogger v.", value)
		if plugin_version_sett_lbl != null:
			plugin_version_sett_lbl.text = str("GoLogger v.", value)
# var cat_data : Dictionary = {
# 	"game": {
# 		"category_name": "game",
# 		"category_index": 0,
# 		"file_count": 0,
# 		"is_locked": false,
# 		"instances": {
# 			"D44r3": {
# 				"id": "D44r3",
# 				"file_name": "game_D44r3.log",
# 				"file_path": "user://GoLogger/game_logs/game(251113_161313)_D44r3.log",
# 				"entry_count": 0
# 			},
# 			"X45jR": {
# 				"id": "X45jR",
# 				"file_name": "game_X45jR.log",
# 				"file_path": "user://GoLogger/game_logs/game(251113_161313)_X43jR.log",
# 				"entry_count": 0
# 			}
# 		}
# 	},
# 	"player": {
# 		"category_name": "game",
# 		"category_index": 0,
# 		"file_count": 0,
# 		"is_locked": false,
# 		"instances": {
# 			"U4j9K": {
# 				"id": "U4j9K",
# 				"file_name": "player_U4j9K.log",
# 				"file_path": "user://GoLogger/player_logs/player(251113_161313)_U4j9K.log",
# 				"file_count": 0,
# 				"instances": {
# 					"U4j9K": {
# 						"id": "U4j9K",
# 						"file_name": "player_U4j9K.log",
# 						"file_path": "user://GoLogger/player_logs/player(251113_161313)_U4j9K",
# 						"entry_count": 0
# 					}
# 				}
# 			}
# 		}
# 	}
# }

var focused_category: Array = []
var btn_array: Array[Control] = []
var container_array: Array[Control] = []
var c_font_normal := Color("9d9ea0")
var c_font_hover := Color("f2f2f2")
var c_print_history := "[color=878787][GoLogger] "

# Mirror Dictionary in Log.gd -> Keep both in sync.
var default_settings := {
		"base_directory": "user://GoLogger/",
		"log_header_format": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:",
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
		"columns": 6
}

var settings_control := {
	"base_directory": base_dir_line,
	"log_header_format": log_header_line,
	"entry_format": entry_format_line,
	"canvaslayer_layer": canvas_layer_spinbox,
	"autostart_session": autostart_btn,
	"use_utc": utc_btn,
	"limit_method": limit_method_btn,
	"entry_count_action": entry_count_action_btn,
	"session_timer_action": session_timer_action_btn,
	"file_cap": file_count_spinbox,
	"entry_cap": entry_count_spinbox,
	"session_duration": session_duration_spinbox,
	"error_reporting": error_rep_btn,
	"columns": columns_slider
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
			canvas_layer_spinbox,
			autostart_btn,
			utc_btn,
			limit_method_btn,
			entry_count_action_btn,
			session_timer_action_btn,
			file_count_spinbox,
			entry_count_spinbox,
			session_duration_spinbox,
			error_rep_btn,
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
			base_dir_container,
			log_header_container,
			entry_format_container,
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
			base_dir_line,
			log_header_line,
			entry_format_line,
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
			base_dir_lbl,
			log_header_lbl,
			entry_format_lbl,
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

		load_data()



func load_data() -> void:
	var _c = ConfigFile.new()
	_c.load(PATH)

	# Categories
	for name in _c.get_value("categories", "category_names", []):
		add_category(
			name,
			_c.get_value("category." + name, "category_index", 0),
			_c.get_value("category." + name, "is_locked", false)
		)

	# Settings
	for key in default_settings.keys():
		if settings_control[key] == null:
			continue
		elif settings_control[key] is LineEdit:
			settings_control[key].text = _c.get_value("settings", key, default_settings[key])
		elif settings_control[key] is SpinBox:
			settings_control[key].value = int(_c.get_value("settings", key, default_settings[key]))
		elif settings_control[key] is CheckButton:
			settings_control[key].button_pressed = _c.get_value("settings", key, default_settings[key])
		elif settings_control[key] is OptionButton:
			settings_control[key].selected = _c.get_value("settings", key, default_settings[key])
		elif settings_control[key] is HSlider:
			settings_control[key].value = int(_c.get_value("settings", key, default_settings[key]))

	config.load(PATH) # Reload config to ensure it's up to date



## Saves all the dock data ( categories and settings state ) to file according to the state/data of the dock(not the file).
func save_data(deferred: bool = false) -> void:
	if deferred:
		await get_tree().physics_frame

	var _c := ConfigFile.new() # Using a new ConfigFile to avoid clobbering existing data

	# Categories
	var _cat_names: Array[String] = []
	for log_category in category_container.get_children():
		if log_category is LogCategory:
			_cat_names.append(log_category.category_name)
			var section_name := str("category." + log_category.category_name)
			_c.set_value(section_name, "category_name", log_category.category_name)
			_c.set_value(section_name, "category_index", log_category.index)
			_c.set_value(section_name, "file_count", log_category.file_count)
			_c.set_value(section_name, "is_locked", log_category.is_locked)
			_c.set_value(section_name, "instances", [])
	_c.set_value("categories", "category_names", _cat_names)

	# Settings
	for key in default_settings.keys():
		if settings_control[key] == null:
			continue
		elif settings_control[key] is LineEdit:
			_c.set_value("settings", key, settings_control[key].text)
		elif settings_control[key] is SpinBox:
			_c.set_value("settings", key, int(settings_control[key].value))
		elif settings_control[key] is CheckButton:
			_c.set_value("settings", key, settings_control[key].button_pressed)
		elif settings_control[key] is OptionButton:
			_c.set_value("settings", key, settings_control[key].selected)
		elif settings_control[key] is HSlider:
			_c.set_value("settings", key, int(settings_control[key].value))

	var err := _c.save(PATH)
	if err != OK:
		var open_err = _c.get_open_error()
		printerr(str("GoLogger error: Failed to save settings.ini file! ", get_error(open_err, "ConfigFile")))
		return
	config.load(PATH) # Reload config to ensure it's up to date





func _on_log_category_changed(cat_obj: LogCategory, category_name: String, new_name: String, index: int, is_locked: bool, to_delete: bool) -> void:
	var cf := ConfigFile.new() # use new ConfigFile to avoid clobbering existing data
	cf.load(PATH)

	for log_category in category_container.get_children():
		if log_category is LogCategory:
			if log_category == cat_obj:
				continue
			elif log_category.category_name == new_name:
				# Conflict found
				cat_obj.invalid_name = true
				return
	save_data()



func change_category_order(category: LogCategory, direction: int) -> void:
	var new_index = category.index + direction
	if new_index < 0 or new_index >= category_container.get_child_count():
		return

	category_container.move_child(category, category.index + direction)
	update_category_indices() # save_data() called within


func update_category_indices() -> void:
	var idx: int = 0
	for log_category in category_container.get_children():
		if log_category is LogCategory:
			log_category.index = idx
			idx += 1
	save_data()
	update_move_buttons()


func update_move_buttons() -> void:
	for i in range(category_container.get_child_count()):
		var category = category_container.get_child(i)
		category.move_left_btn.disabled = (category.index == 0)
		category.move_right_btn.disabled = (category.index == category_container.get_child_count() - 1)


## Use save_after when Log Categories are added manually via the dock.
## Not when loading categories from config.
func add_category(_name: String = "", _index: int = 0, _is_locked: bool = false, save_after: bool = false) -> void:
	var _n = category_scene.instantiate()
	_n.dock = self
	_n.category_name = _name
	_n.is_locked = _is_locked
	_n.index = category_container.get_children().size() - 1
	category_container.add_child(_n)

	_n.log_category_changed.connect(_on_log_category_changed)
	_n.name_warning.connect(_on_name_warning)
	_n.move_category_requested.connect(change_category_order)
	_n.line_edit.focus_entered.connect(_on_category_line_focus.bind([_n, _n.line_edit.text], true))
	_n.line_edit.focus_exited.connect(_on_category_line_focus.bind([], false))
	# _n.line_edit.grab_focus() # This causes the last added category to always grab focus on load, which is undesirable.
	update_move_buttons()
	if save_after:
		save_data()


func check_conflict_name(cat_obj: LogCategory, new_name: String) -> bool:
	for log_category in category_container.get_children():
		if log_category == cat_obj: # Disregard category being checked
			continue
		elif log_category.category_name == new_name:
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


func create_settings_file() -> void: # Note mirror function present in GoLoggerDock.gd. Keep both in sunc.
	var cf := ConfigFile.new() # Use new ConfigFile to avoid clobbering existing data
	cf.set_value("settings", "base_directory", default_settings["base_directory"])
	cf.set_value("settings", "columns", default_settings["columns"])
	cf.set_value("settings", "log_header_format", default_settings["log_header_format"])
	cf.set_value("settings", "entry_format", default_settings["entry_format"])
	cf.set_value("settings", "canvaslayer_layer", default_settings["canvaslayer_layer"])
	cf.set_value("settings", "autostart_session", default_settings["autostart_session"])
	cf.set_value("settings", "use_utc", default_settings["use_utc"])
	cf.set_value("settings", "limit_method", default_settings["limit_method"])
	cf.set_value("settings", "entry_count_action", default_settings["entry_count_action"])
	cf.set_value("settings", "session_timer_action", default_settings["session_timer_action"])
	cf.set_value("settings", "file_cap", default_settings["file_cap"])
	cf.set_value("settings", "entry_cap", default_settings["entry_cap"])
	cf.set_value("settings", "session_duration", default_settings["session_duration"])
	cf.set_value("settings", "error_reporting", default_settings["error_reporting"])

	cf.set_value("categories", "category_names", default_settings["category_names"])
	cf.set_value("categories", "instance_ids", [])

	for i in default_settings["category_names"].size():
		var c_name: String = default_settings["category_names"][i]
		var base_section := "categories." + str(c_name)
		cf.set_value(base_section, "category_name", c_name)
		cf.set_value(base_section, "category_index", i)
		cf.set_value(base_section, "file_count", 0)
		cf.set_value(base_section, "is_locked", false)

	var _s = cf.save(PATH)
	if _s != OK:
		var _e = cf.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))
		return
	load_settings_state()
	config.load(PATH) # Reload config to ensure it's up to date


func load_settings_state() -> void:
	config.load(PATH)
	base_dir_apply_btn.disabled = 		true

	for setting in default_settings.keys():
		settings_control[setting] = config.get_value("settings", setting, default_settings[setting])

	# base_dir_line.text = 							config.get_value("settings", 	 "base_directory", default_settings["base_directory"])
	# log_header_line.text = 						config.get_value("settings", "log_header_format", default_settings["log_header_format"])
	# entry_format_line.text = 					config.get_value("settings", "entry_format", default_settings["entry_format"])
	# canvas_layer_spinbox.value = 			config.get_value("settings", "canvaslayer_layer", default_settings["canvaslayer_layer"])
	# autostart_btn.button_pressed = 		config.get_value("settings", "autostart_session", default_settings["autostart_session"])
	# utc_btn.button_pressed = 					config.get_value("settings", "use_utc", default_settings["use_utc"])
	# limit_method_btn.selected = 			config.get_value("settings", "limit_method", default_settings["limit_method"])
	# entry_count_action_btn.selected = config.get_value("settings", "entry_count_action", default_settings["entry_count_action"])
	# entry_count_action_btn.selected = config.get_value("settings", "session_timer_action", default_settings["session_timer_action"])
	# file_count_spinbox.value = 				config.get_value("settings", "file_cap", default_settings["file_cap"])
	# entry_count_spinbox.value = 			config.get_value("settings", "entry_cap", default_settings["entry_cap"])
	# session_duration_spinbox.value = 	config.get_value("settings", "session_duration", default_settings["session_duration"])
	# error_rep_btn.selected = 					config.get_value("settings", "error_reporting", default_settings["error_reporting"])
	# columns_slider.value = 						config.get_value("settings", "columns", default_settings["columns"])
	config.save(PATH)


func validate_settings() -> void: # Note mirror function also present in Log.gd. Ensure both are kept in sync.
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
		"error_reporting": "settings/error_reporting"
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
		"settings/error_reporting": TYPE_INT
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
		"Transform2D",
		"Plane",
		"Quaternion",
		"AABB",
		"Basis",
		"Transform3D",
		"Color",
		"StringName",
		"NodePath",
		"RID",
		"Object",
		"Callable",
		"Signal",
		"Dictionary",
		"Array",
		"PackedByteArray",
		"PackedInt32Array",
		"PackedInt64Array",
		"PackedFloat32Array",
		"PackedFloat64Array",
		"PackedStringArray",
		"PackedVector2Array",
		"PackedVector3Array",
		"PackedColorArray"
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
	if tab == 0: # Categories tab
		var children = category_container.get_children()
		for i in range(children.size()):
			children[i].queue_free()

		defaults_btn.disabled = true
		add_category_btn.disabled = true
		await get_tree().create_timer(0.5).timeout
		var cf := ConfigFile.new()
		cf.set_value("categories", "category_names", ["game"])
		cf.set_value("categories.game", "category_name", "game")
		cf.set_value("categories.game", "category_index", 0)
		cf.set_value("categories.game", "file_count", 0)
		cf.set_value("categories.game", "is_locked", false)
		load_data()
		defaults_btn.disabled = false
		add_category_btn.disabled = false
		if !cf:
			var _e = cf.get_open_error()
			printerr(str("GoLogger error: Failed to save to settings.ini file! ", get_error(_e, "ConfigFile")))

	else: # Settings tab
		create_settings_file()


func open_directory() -> void:
	var abs_path = ProjectSettings.globalize_path(config.get_value("settings", "base_directory"))
	OS.shell_open(abs_path)


func _check_valid_entry_format(format: String) -> bool:
	return true if format.contains("{entry}") else false


func _on_dock_mouse_hover_changed(node: Label, is_hovered: bool) -> void:
	if is_hovered:
		node.add_theme_color_override("font_color", c_font_hover)
	else:
		node.add_theme_color_override("font_color", c_font_normal)


func _on_button_button_up(node: Button) -> void:
	config.load(PATH)
	match node:
		base_dir_apply_btn:
			var old_dir = config.get_value("settings", "base_directory")
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
			config.set_value("settings", "base_directory", new_dir)
			print_rich("[color=878787][GoLogger] Base directory changed to: ", new_dir)

		base_dir_opendir_btn:
			if config.get_value("settings", "base_directory") == "":
				push_warning("GoLogger: Base directory path isn't set. Please set a valid directory path before opening the directory.")
			open_directory()

		base_dir_reset_btn:
			config.set_value("settings", "base_directory", "user://GoLogger/")
			base_dir_line.text = config.get_value("settings", "base_directory")
			print_rich("[color=878787][GoLogger] Base directory reset to default.")

		log_header_apply_btn:
			config.set_value("settings", "log_header_format", log_header_line.text)
			print_rich("[color=878787][GoLogger] New Log Header applied.")
			log_header_apply_btn.disabled = true
			log_header_line.release_focus()

		log_header_reset_btn:
			log_header_line.text = default_settings["log_header_format"]
			config.set_value("settings", "log_header_format", default_settings["log_header_format"])
			print_rich("[color=878787][GoLogger] Log header option reset to default.")
			log_header_apply_btn.disabled = true
			log_header_line.release_focus()

		entry_format_apply_btn:
			config.set_value("settings", "entry_format", entry_format_line.text)
			var err := config.save(PATH)
			print_rich("[color=878787][GoLogger] New Entry Format Applied.")
			entry_format_apply_btn.disabled = true
			entry_format_line.release_focus()

		entry_format_reset_btn:
			entry_format_line.text = config.get_value("settings", "entry_format", default_settings["entry_format"])
			config.set_value("settings", "entry_format", default_settings["entry_format"])
			print_rich("[color=878787][GoLogger] Entry format reset to default.")
			entry_format_apply_btn.disabled = true
	save_data()


func _on_line_edit_text_changed(new_text: String, node: LineEdit) -> void:
	config.load(PATH)
	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
			if new_text != config.get_value("settings", "base_directory"):
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
	config.load(PATH)
	match node:
		base_dir_line:
			if new_text == "":
				base_dir_apply_btn.disabled = true
				return

			var old_dir = config.get_value("settings", "base_directory")
			var _d = DirAccess.open(new_text)
			_d.make_dir(new_text)
			var _e = DirAccess.get_open_error()
			if _e == OK:
				config.set_value("settings", "base_directory", new_text)
			else:
				base_dir_line.text = old_dir
			base_dir_line.release_focus()

		log_header_line:
			if new_text == "": return

			var old_header = config.get_value("settings", "log_header_format", "")

			if new_text != old_header:
				config.set_value("settings", "log_header_format", new_text)
			log_header_line.release_focus()

		entry_format_line:
			var old_format = config.get_value("settings", "entry_format", "")
			if new_text != old_format:
				entry_format_apply_btn.disabled = false
			if new_text == "":
				entry_format_line.text = "{entry}"
			entry_format_line.release_focus()
	save_data()


func _on_optbtn_item_selected(index: int, node: OptionButton) -> void:
	match node:
		limit_method_btn:
			config.set_value("settings", "limit_method", index)
			print_rich(c_print_history, "Limit method changed.")

		entry_count_action_btn:
			config.set_value("settings", "entry_count_action", index)
			print_rich(c_print_history, "Entry Count Action changed")

		session_timer_action_btn:
			config.set_value("settings", "session_timer_action", index)
			print_rich(c_print_history, "Session Timer Action changed.")

		error_rep_btn:
			config.set_value("settings", "error_reporting", index)
			print_rich(c_print_history, "Error Reporting level changed.")
	save_data()


func _on_checkbutton_toggled(toggled_on: bool, node: CheckButton) -> void:
	match node:

		autostart_btn:
			config.set_value("settings", "autostart_session", toggled_on)
			print_rich(c_print_history + "Autostart session option " + "enabled." if toggled_on else "disabled.")

		utc_btn:
			config.set_value("settings", "use_utc", toggled_on)
			print_rich(c_print_history, "Use UTC option " + "enabled." if toggled_on else "disabled.")

	save_data()


func _on_spinbox_value_changed(value: float, node: SpinBox) -> void:
	var u_line = node.get_line_edit()
	u_line.set_caret_column(u_line.text.length())
	if u_line.get_caret_column() == u_line.text.length() - 1:
		u_line.set_caret_column(u_line.text.length())
	else: u_line.set_caret_column(u_line.get_caret_column() + 1)

	match node:
		entry_count_spinbox:
			config.set_value("settings", "entry_cap", int(value))
			print_rich(c_print_history, "Entry cap changed to ", str(int(value)), ".")

		session_duration_spinbox:
			config.set_value("settings", "session_duration", int(value))
			print_rich(c_print_history, "Session duration changed to ", str(int(value)), " seconds.")

		file_count_spinbox:
			config.set_value("settings", "file_cap", int(value))
			print_rich(c_print_history, "File cap changed to ", str(int(value)), ".")

		canvas_layer_spinbox:
			config.set_value("settings", "canvaslayer_layer", int(value))
			print_rich(c_print_history, "Save Copy canvas layer changed to ", str(int(value)), ".")

	save_data()


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

	save_data()


func _on_category_line_focus(data: Array, focused: bool) -> void:
	if focused and data.size() > 0:
		focused_category.append(data)
	else:
		focused_category.clear()


func _on_columns_slider_value_changed(value: int) -> void:
	category_container.columns = value
	columns_slider.tooltip_text = str(value)
	config.set_value("settings", "columns", value)
	save_data()


func _on_name_warning(toggled_on: bool, type : int) -> void:
	if toggled_on:
		category_warning_lbl.visible = true
		match type:
			0: category_warning_lbl.text = "Empty category names are not used. Please enter a unique name."
			1: category_warning_lbl.text = "Names are not changed if they're not applied."
	else:
		category_warning_lbl.visible = false


# func _on_category_deleted() -> void: # DEPRECATED # Refactored into _on_log_category_changed
# 	await get_tree().create_timer(0.1).timeout
# 	print("Category deleted -> reordering category indices:\n")
# 	for i in range(category_container.get_child_count()):
# 		var category: LogCategory = category_container.get_child(i)
# 		category.index = i
# 	update_move_buttons()
