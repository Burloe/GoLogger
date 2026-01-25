extends Node


## Autoload containing the entire framework that makes up the framework.
##
## The GoLogger Wiki can be found at [url]https://github.com/Burloe/GoLogger/wiki[/url] with information on how to use the plugin, how it works and more information.
## The GitHub repository [url]https://github.com/Burloe/GoLogger[/url] will always have the latest version of
## GoLogger to download. For installation, setup and how to use instructions, see the README.md or in the Github
## repo.

#TODO:
	# [Done] Implement the custom header format in start_session()
	# [Done] Implement the custom entry format in entry()
	# [Done] Add new setting for the custom header format called "log_header_fomat" to the config file creation, saving and loading logic
	# [Done] Add new setting for the custom entry format called "entry_format" to the config file creation, saving and loading logic
	# [Done] Consider adding {instance_id} tag to entry format
	#	[Done] Add 'instance_id' to solve issue with concurrency in multiplayer projects
	# [Done] Refactor .ini settings handling <needed to do to finish instance_id task
	#	[Done] Remove 'category_index' parameter from entry() method, in favor of using category_name only
	# [Done] Move 'base_directory' to 'settings' section in .ini file
	# [Done] Add a new hotkey -> Print instance_id and a corresponding button in the dock to change it.
	# [Done] BUG - Enabling/disabling plugin erases all settings in .ini file.
	# [Done] BUG - When enabling the plugin, the .ini file's settings are reset to default values. Technically isn't an issue because the dock loads the settings correctly before they're overwritten and should overwrite the default values whenever anything is changed, but still not ideal.
	#
	# [Not started] Add checkbox to LogCategory that marks one category as Default. When marked, that category is used whenever an unspecified category name is passed to entry()
	# [Postponed?]Add proper error codes to all error/warning messages. Link to a wiki page detailing each error code?
	#
	# [Proposal] Add create_category(category_name:String, id: String) method allow users to create temporary categories programmatically - Store temporary categories in a runtime memory structure only, not in the .ini file
	# [Proposal] Add remove_category(category_name:String) method to allow users to remove temporary categories programmatically
	# [Proposal] Add list_categories() method to return an array of current category names
	# [Proposal] Add a custom node that users can attach to objects in their scene tree that creates a unique temp category for that object only while the scene is running

#BUG:
	# Entry count isn't working

#TODO - Debugging:
	# Check that file count actually deletes old files when file cap is reached
	# Check that file count deletes the correct files (oldest first)

### Release Checklist: ###
	# REMOVE Test manual test entry with KEY_COMMA in _input()
	# Check all settings load and save correctly
	# File counting and deletion works correctly when file cap is reached
	# Entry counting and limit methods work correctly when entry cap is reached
	# Session timer limit method works correctly when time is up
	# start_session():
		# File count is updated and managed properly
		# current file is saved to ConfigFile
	# entry():
		# uses entry_format,
		# entry_count is managed properly
		# default_category is handled appropriately
	# stop_session():
		# Session is stopped
		# current_file in ConfigFile is cleared
##########################


##  Started adding default cateogry but not finished yet.
## Need to handle clearing default category when a category is deleted, etc.
## In entry(), added logic for it that sets the parameter category_name to the default category if no category name is specified but can you really do that?



signal session_started ## Emitted when a log session has started.
signal session_stopped ## Emitted when a log session has been stopped.

const PATH = "user://gologger_data.ini" # Mirror in GoLoggerDock.gd
var config := ConfigFile.new()
var copy_name : String = ""
var session_status: bool = false:
	set(value):
		session_status = value
		if value: session_started.emit()
		else: session_stopped.emit()

var cat_data : Dictionary = {
	"game": {
		"category_name": "game",
		"category_index": 0,
		"file_name": "game(251113_161313).log",
		"file_path": "user://GoLogger/game_logs/game(251113_161313).log",
		"file_count": 0,
		"entry_count": 0,
		"is_locked": false
	}
}

## Instance ID is a unique ID for each runtime instance of GoLogger. Used to differentiate between multiple instances when debugging multiplayer projects.
var instance_id: String = "":
	set(value):
		instance_id = value
		instance_id_label.text = str("Gologger\nInstance ID: ", value)

@onready var elements_canvaslayer: CanvasLayer = %GoLoggerElements
@onready var session_timer: Timer = %SessionTimer
@onready var instance_id_label: Label = %InstanceIDLabel
@onready var popup: CenterContainer = %Popup
@onready var popup_line_edit: LineEdit = %CopyNameLineEdit
@onready var popup_yesbtn: Button = %PopupYesButton
@onready var popup_nobtn: Button = %PopupNoButton
@onready var prompt_label: RichTextLabel = %PromptLabel
@onready var popup_errorlbl: RichTextLabel = %PopupErrorLabel
@onready var inaction_timer: Timer = %InactionTimer
var popup_state : bool = false:
	set(value):
		popup_state = value
		if session_status:
			toggle_copy_popup(value)

# Mirror in GoLoggerDock.gd
var default_settings := {
		"category_names": ["game"],
		"base_directory": "user://GoLogger/",
		"log_header_format": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:",
		"entry_format": "[{hh}:{mi}:{ss}] {instance_id}: {entry}",
		"default_category": "",
		"canvaslayer_layer": 5,
		"autostart_session": true,
		"use_utc": false,
		"print_instance_id": false,
		"limit_method": 0,
		"entry_count_action": 0,
		"session_timer_action": 0,
		"file_cap": 10,
		"entry_cap": 300,
		"session_duration": 300,
		"error_reporting": 0,
		"columns": 5
}
## Mirror in GoLoggerDock.gd
var expected_types = {
		"categories/category_names": 			TYPE_ARRAY,
		"settings/base_directory": 				TYPE_STRING,
		"settings/columns": 							TYPE_INT,
		"settings/log_header_format": 		TYPE_STRING,
		"settings/entry_format" : 				TYPE_STRING,
		"settings/default_category": 			TYPE_STRING,
		"settings/canvaslayer_layer": 		TYPE_INT,
		"settings/autostart_session": 		TYPE_BOOL,
		"settings/use_utc": 							TYPE_BOOL,
		"settings/print_instance_id": 		TYPE_BOOL,
		"settings/limit_method": 					TYPE_INT,
		"settings/entry_count_action": 		TYPE_INT,
		"settings/session_timer_action": 	TYPE_INT,
		"settings/file_cap": 							TYPE_INT,
		"settings/entry_cap": 						TYPE_INT,
		"settings/session_duration": 			TYPE_INT,
		"settings/error_reporting": 			TYPE_INT
	}

var hotkey_start_session: InputEventShortcut = preload("res://addons/GoLogger/StartSessionShortcut.tres")
var hotkey_stop_session: InputEventShortcut = preload("res://addons/GoLogger/StopSessionShortcut.tres")
var hotkey_copy_session: InputEventShortcut = preload("res://addons/GoLogger/CopySessionShortcut.tres")
var hotkey_print_instance_id: InputEventShortcut = preload("res://addons/GoLogger/PrintInstanceIDShortcut.tres")

enum ErrorCodes { #NYI - For future use in error/warning messages
		ERR_NONE,
		ERR_LOAD_CATEGORIES_FAILED,
		ERR_SAVE_CATEGORIES_FAILED,
		ERR_SESSION_ACTIVE,
		ERR_NO_CATEGORIES,
		ERR_INVALID_CATEGORY,
		ERR_INVALID_ENTRY,
		ERR_INVALID_FILE_PATH,
		ERR_SESSION_INACTIVE,
		ERR_SETTINGS_FILE_CREATION_FAIL,
		ERR_FILE_ACCESS,
		ERR_DIR_ACCESS
}




func _ready() -> void:
	if !FileAccess.file_exists(PATH):
		create_settings_file()

	config.load(PATH)

	elements_canvaslayer.layer = _get_config_value("settings", "canvaslayer_layer")
	session_timer.timeout.connect(_on_timer_timeout.bind(session_timer))
	inaction_timer.timeout.connect(_on_timer_timeout.bind(inaction_timer))
	popup_line_edit.text_changed.connect(_on_line_edit_text_changed)
	popup_line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	popup_yesbtn.button_up.connect(_on_button_up.bind(popup_yesbtn))
	popup_nobtn.button_up.connect(_on_button_up.bind(popup_nobtn))
	popup.visible = popup_state
	popup_errorlbl.visible = false
	popup_yesbtn.disabled = true

	assert(_check_category_name_conflicts().is_empty(), str("GoLogger: Conflicting category name(s) found: ", _check_category_name_conflicts()))
	instance_id = _get_instance_id()
	instance_id_label.hide()

	validate_settings()
	load_category_data()

	if _get_config_value("settings", "autostart_session"):
		start_session()



func _physics_process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		if popup_state and inaction_timer != null and !inaction_timer.is_stopped():
			prompt_label.text = str("[center]Save copies of the current logs?[font_size=12]\nAutomatically cancelled in ", snapped(inaction_timer.time_left, 1.0),"s!\n[color=lightblue]Limit methods are paused during this prompt.")
			session_timer.paused = true
		else:
			if session_timer != null and session_timer.is_paused():
				session_timer.paused = false



func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey\
		or event is InputEventJoypadButton\
		or event is InputEventJoypadMotion and event.axis == 4\
		or event is InputEventJoypadMotion and event.axis == 5: # Only allow trigger axes
			if hotkey_start_session.shortcut.matches_event(event) and event.is_released():
				start_session()
			if hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
				stop_session()
			if hotkey_copy_session.shortcut.matches_event(event) and event.is_released():
				save_copy()
			if hotkey_print_instance_id.shortcut.matches_event(event) and event.is_pressed():
				instance_id_label.show()
			if hotkey_print_instance_id.shortcut.matches_event(event) and event.is_released():
				instance_id_label.hide()
				if _get_config_value("settings", "print_instance_id"):
					print_rich("[font_size=12][color=fc4674][GoLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")


		# Test entry logging with Comma Key.
		if event is InputEventKey and event.keycode == KEY_COMMA and event.is_released():
			var v1: int = 1234
			var v2: float = 56.78
			entry("Test entry " + str(v1) + " - " + str(v2), "game", true)
		if event is InputEventKey and event.keycode == KEY_PERIOD and event.is_released():
			entry("Test entry without category name.")
		if event is InputEventKey and event.keycode == KEY_M and event.is_released():
			entry("Test entry in non-existent category.", "non_existant_category")




## Loads category data from the config file into the cat_data dictionary.[br]
## Use instead of 'config.load(PATH)' whenever category data is needed.
func load_category_data(new_session: bool = false) -> void:
	config.load(PATH)
	cat_data.clear()

	var cat_names: Array = config.get_value("categories", "category_names", [])

	cat_data["categories"] = {
		"category_names": cat_names.duplicate(),
	}

	for name in cat_names:

		cat_data[name] = {
			"category_name": name,
			"category_index": config.get_value("categories." + str(name), "category_index", 0),
			"file_name": "", #config.get_value("categories", name + ".log", ""),
			"file_path": "",
			"file_count": config.get_value("categories." + str(name), "file_count", 0),
			"entry_count": 0,
			"is_locked": config.get_value("categories." + str(name), "is_locked", false)
		}
		config.save(PATH)


## Saves category data from the cat_data dictionary into the config file.[br]
## Use instead of 'config.save(PATH)' whenever category data is modified.
func save_category_data() -> void:
	if !cat_data.has("categories"):
		return

	var err = config.load(PATH)
	if err != OK:
		if _get_config_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to load existing config file while saving category data.")
		return

	config.set_value("categories", "category_names", cat_data["categories"]["category_names"])

	for name in cat_data["categories"]["category_names"]:
		if !cat_data.has(name):
			continue
		var c = cat_data[name]
		var base_section := "categories." + str(c["category_name"])

		config.set_value(base_section, "category_name", c.get("category_name", name))
		config.set_value(base_section, "category_index", c.get("category_index", 0))
		config.set_value(base_section, "file_count", c.get("file_count", 0))
		config.set_value(base_section, "entry_count", c.get("entry_count", 0))
		config.set_value(base_section, "is_locked", c.get("is_locked", false))

	config.save(PATH)



func start_session() -> void:
	if session_status: # ErrCheck -> Session already started
		if _get_config_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to start session, a session is already active.")
		return

	load_category_data(true)

	if _get_config_value("settings", "limit_method") == 1 or _get_config_value("settings", "limit_method") == 2:
		session_timer.start(_get_config_value("settings", "session_duration"))


	for i in range(cat_data["categories"]["category_names"].size()):
		var c_name: String = cat_data["categories"]["category_names"][i]
		var f_name: String = _get_file_name(c_name) # e.g. "game.log"
		var f_path: String = str(config.get_value("settings", "base_directory", default_settings["base_directory"]), c_name, "_logs/", f_name)

		config.set_value("categories." + str(c_name), "file_name", f_name)
		config.set_value("categories." + str(c_name), "file_path", f_path)
		config.save(PATH)

		# Open/create directory
		var path: String = str(config.get_value("settings", "base_directory", "user://GoLogger/"), c_name, "_logs/")
		var dir : DirAccess
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)

		if !DirAccess.dir_exists_absolute(str(path, "saved_logs/")):
			DirAccess.make_dir_recursive_absolute(str(path, "saved_logs/"))
		dir = DirAccess.open(path)

		if !dir and _get_config_value("settings", "error_reporting") != 2: # ErrCheck
			var _err = DirAccess.get_open_error()
			if _err != OK: push_warning("GoLogger: ", get_error(_err, "DirAccess"), " (", config.get_value(str("categories.", c_name), "file_path", "EMPTY FILEPATH!"), ").")
			continue

		# Create/open file
		var _f = FileAccess.open(f_path, FileAccess.WRITE)
		if !_f and _get_config_value("settings", "error_reporting") != 2:
			push_warning("GoLogger: Failed to create log file for session(", f_path, ").")
			continue

		var _files = dir.get_files()
		cat_data[c_name]["file_count"] = _files.size()

		if _get_config_value("settings", "file_cap") > 0:
			while _files.size() > _get_config_value("settings", "file_cap") -1:
				_files.sort()
				dir.remove(_files[0])
				_files.remove_at(0)

				var _err = DirAccess.get_open_error() # Checks for errors during dir.remove()
				if _err != OK and _get_config_value("settings", "error_reporting") != 2:
					push_warning("GoLoggger Error: Failed to remove old log file -> ", get_error(_err, "DirAccess"))

		var header: String = _get_header(c_name)
		if header != "":
			_f.store_line(header)
		_f.close()

	# Update ConfigFile / Start SessionTimer / Close up
	save_category_data()
	session_status = true
	if session_timer.is_stopped() and _get_config_value("settings", "session_timer_action") == 1\
	or session_timer.is_stopped() and _get_config_value("settings", "session_timer_action") == 2:
		if session_timer != null: session_timer.start()
	session_started.emit()


func entry(log_entry : String, category_name: String = "", print_entry: bool = false) -> void:
	# Load base category data from file
	load_category_data()
	# var _d: Dictionary = cat_data.get(category_name, {})
	var cats: Array = config.get_value("categories", "category_names", [])
	var default_cat: String = _get_config_value("settings", "default_category", "")
	var target_cat: String = category_name
	var entry: String = _get_entry_format(log_entry, category_name)
	var target_filepath: String = config.get_value(str("categories." + category_name), "file_path", "")
	var err_lv = _get_config_value("settings", "error_reporting")

	# Early Returns
	if log_entry == "":
		if err_lv != 2:
			printerr("GoLogger: Attempted to log empty entry.")
		return

	if category_name == "": # Unspecified category -> Use Default category
		if default_cat != "" and cats.has(default_cat):
			target_cat = default_cat
			target_filepath = config.get_value(str("categories." + default_cat), "file_path", "")
		else:
			if err_lv != 2:
				printerr("GoLogger: Attempted to log entry into a default category[", default_cat,"] that doesn't exist."\
				if default_cat!= "" else "GoLogger: Unable to log entry into a default category without a category assigned as default."
				)
			return

	if cats.is_empty():
		if err_lv != 2:
			printerr("GoLogger: Attempted to log entry without categories.")
		return

	if target_cat not in cats:
		if err_lv != 2:
			printerr("GoLogger: Category '" + target_cat + "' not found. Check correct spelling.")
		return

	if !session_status:
		return

	if target_filepath == "":
		if err_lv != 2:
			printerr("GoLogger: No valid file path found for category '" + target_cat + "[" + instance_id + "]'.")
		return


	# Read existing Entries (note that first entry is Log Header)
	var _f = FileAccess.open(target_filepath, FileAccess.READ)
	if !_f: # ER
		var _err = FileAccess.get_open_error()
		if _err != OK and err_lv != 2:
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return

	var lines : Array[String] = []
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l)
	_f.close()
	config.load(PATH)
	config.set_value("categories." + str(target_cat), "entry_count", lines.size())
	config.save(PATH)

	# Handle Limit Methods
	if !popup_state: # Enforce limits while inactive popup
		match _get_config_value("settings", "limit_method"):

			0: # Entry count
				match _get_config_value("settings", "entry_count_action"):
					0: # Remove old entries
						while lines.size() >= _get_config_value("settings", "entry_cap"):
							lines.remove_at(1) # Keeping header line 0

					1: # Stop & start
						if lines.size() >= _get_config_value("settings", "entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, target_cat)
							return

					2: # Stop only
						if lines.size() >= _get_config_value("settings", "entry_cap"):
							stop_session()
							return

			1: # Session timer
				match _get_config_value("settings", "session_timer_action"):
					0: # Stop & start session
						stop_session()
						start_session()
						entry(log_entry, target_cat)
						return

					1: # Stop session
						stop_session()
						return

			2: # Both Entry count limit and Session Timer
				match _get_config_value("settings", "entry_count_action"):
					0: # Stop & start session
						if lines.size() >= _get_config_value("settings", "entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, target_cat)
							return

					1: # Stop session
						if lines.size() >= _get_config_value("settings", "entry_cap"):
							stop_session()
							return

	# Rewrite file with existing lines / Update entry count
	cat_data[target_cat]["entry_count"] = lines.size()
	# cat_data[target_cat]["instances"][instance_id]["entry_count"] = lines.size()
	var _fw = FileAccess.open(target_filepath, FileAccess.WRITE)
	if !_fw: # ErrCheck
		var err = FileAccess.get_open_error()
		if err != OK and err_lv != 2:
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "")

	for line in lines:
		_fw.store_line(str(line))

	# Write new entry
	var new_entry: String = _get_entry_format(log_entry, target_cat)
	_fw.store_line(new_entry)
	_fw.close()
	if print_entry:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] <", target_cat, "> ", new_entry.dedent())


func save_copy(_name: String = "") -> void:
	if !session_status:
		return

	# No specified name -> prompt popup for name
	if _name == "" and !popup_state:
		popup_state = true

	# Name specified, i.e. called programmatically -> save copy using predetermines name
	else:
		copy_name = _name
		complete_copy()


func complete_copy() -> void:
	if !session_status: # ER
		if _get_config_value("settings", "error_reporting") != 2: push_warning("GoLogger: Failed to save copies due to inactive session.")
		return

	load_category_data()

	if config.get_value("categories", "category_names").is_empty():
		if config.get_value("settings", "error_reporting"):
			push_warning("GoLogger: Unable to complete copy action. No categories are present.")

	var reject_str: Array[String] = [".log", ".txt", ".cfg", ".ini", ".json", ".xml", ".yml", ".yaml", ".csv"]
	var reject_ch: Array[String] = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]

	for ch in reject_ch:
		if copy_name.find(ch) != -1:
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Invalid character [", ch, "] found in file name.")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return

	for strg in reject_str:
		if copy_name.ends_with(strg):
			copy_name.erase(copy_name.length() - strg.length(), strg.length())

	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_config_value("settings", "use_utc")), "] ")

	for category in range(config.get_value("categories", "category_names").size()):
		var dirpath: String = str(config.get_value("settings", "base_directory"), "/", category, "_logs/saved_logs/")
		var _f := FileAccess.open(dirpath, FileAccess.READ)
		if !_f:
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to open file to copy the session [", dirpath,"].")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return

		var content: String = _f.get_as_text()
		var fw = FileAccess.open(str(dirpath, _get_file_name(copy_name)), FileAccess.WRITE)
		if !fw:
			var err = FileAccess.get_open_error()
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to create copy of file [", dirpath, _get_file_name(copy_name),"] - ", get_error(err), ".")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return
		fw.store_line(str(content, "\nCopy of ", category, " session saved."))
		fw.close()

	save_category_data()
	popup_state = false


func stop_session() -> void:
	if !session_status:	return

	load_category_data()
	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_config_value("settings", "use_utc")), "] Stopped log session.")

	# for category in cat_data["categories"]["category_names"]
	for category in config.get_value("categories", "category_names", []):
		# Read existing file content
		var _f = FileAccess.open(cat_data[category]["file_path"], FileAccess.READ)
		if !_f:
			var _err = FileAccess.get_open_error()
			if _get_config_value("settings", "error_reporting") != 2:
				if _err != OK: push_warning("GoLogger: Failed to open file ", cat_data[category]["file_path"], " with READ ", get_error(_err))
			push_warning("GoLogger: Stopped session but failed to do so properly. Couldn't open the file.")
			session_status = false
			return
		var _content := _f.get_as_text()
		_f.close()

		# Write to file that session is stopping
		var _fw = FileAccess.open(cat_data[category]["file_path"], FileAccess.WRITE)
		if !_fw and _get_config_value("settings", "error_reporting") != 2:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				push_warning("GoLogger: Attempting to stop session by writing to file (", cat_data[category]["file_path"], ") -> Error[", _err, "]")
				return
		var _s := str(_content, str(_timestamp + "Stopped Log Session."))
		_fw.store_line(_s)
		_fw.close()

		config.set_value("categories." + str(category), "file_name", "")
		config.set_value("categories." + str(category), "file_path", "")
		config.set_value("categories." + str(category), "entry_count", 0)

	config.save(PATH)
	session_status = false


func toggle_copy_popup(toggle_on : bool) -> void:
	popup.visible              =  toggle_on
	popup_line_edit.editable   =  toggle_on
	popup_nobtn.disabled       = !toggle_on
	popup_yesbtn.disabled      = !toggle_on
	popup_line_edit.focus_mode =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	popup_yesbtn.focus_mode    =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	popup_nobtn.focus_mode     =  Control.FOCUS_ALL if toggle_on else Control.FOCUS_NONE
	if session_timer != null and !session_timer.is_stopped():
		session_timer.paused   =  toggle_on
	if toggle_on:
		popup_line_edit.grab_focus()
		inaction_timer.start(30)
	else:
		copy_name = ""
		popup_line_edit.text = ""
		popup_line_edit.release_focus()


func create_settings_file() -> void: # Mirror in GoLoggerDock.gd
	var cf := ConfigFile.new() # Use new ConfigFile to avoid clobbering existing data
	cf.set_value("settings", "base_directory", default_settings["base_directory"])
	cf.set_value("settings", "columns", default_settings["columns"])
	cf.set_value("settings", "log_header_format", default_settings["log_header_format"])
	cf.set_value("settings", "entry_format", default_settings["entry_format"])
	cf.set_value("settings", "canvaslayer_layer", default_settings["canvaslayer_layer"])
	cf.set_value("settings", "autostart_session", default_settings["autostart_session"])
	cf.set_value("settings", "use_utc", default_settings["use_utc"])
	cf.set_value("settings", "print_instance_id", default_settings["print_instance_id"])
	cf.set_value("settings", "limit_method", default_settings["limit_method"])
	cf.set_value("settings", "entry_count_action", default_settings["entry_count_action"])
	cf.set_value("settings", "session_timer_action", default_settings["session_timer_action"])
	cf.set_value("settings", "file_cap", default_settings["file_cap"])
	cf.set_value("settings", "entry_cap", default_settings["entry_cap"])
	cf.set_value("settings", "session_duration", default_settings["session_duration"])
	cf.set_value("settings", "error_reporting", default_settings["error_reporting"])

	cf.set_value("categories", "category_names", ["game"])

	var _s = cf.save(PATH)
	if _s != OK:
		var _e = cf.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))
		return

	config.load(PATH) # Reload config to ensure it's up to date


func validate_settings() -> void: # Mirror in GoLoggerDock.gd
	var expected_settings ={
		"category_names": 			"categories/category_names",
		"base_directory": 			"settings/base_directory",
		"columns": 							"settings/columns",
		"log_header_format": 		"settings/log_header_format",
		"entry_format": 				"settings/entry_format",
		"canvaslayer_layer": 		"settings/canvaslayer_layer",
		"autostart_session": 		"settings/autostart_session",
		"use_utc": 							"settings/use_utc",
		"limit_method": 				"settings/limit_method",
		"entry_count_action": 	"settings/entry_count_action",
		"session_timer_action": "settings/session_timer_action",
		"file_cap": 						"settings/file_cap",
		"entry_cap": 						"settings/entry_cap",
		"session_duration": 		"settings/session_duration",
		"error_reporting": 			"settings/error_reporting",
		"print_instance_id": 		"settings/print_instance_id"
	}

	# Validate presence -> Write default
	for setting in expected_settings.keys():
		var splits = expected_settings[setting].split("/")
		if !config.has_section(splits[0]) or !config.has_section_key(splits[0], splits[1]):
			config.set_value(splits[0], splits[1], default_settings[splits[1]])

	# Validate types -> Apply default
	for setting_key in expected_types.keys():
		var splits = setting_key.split("/")
		var expected_type = expected_types[setting_key]
		var value = config.get_value(splits[0], splits[1])

		if typeof(value) != expected_type:
			config.set_value(splits[0], splits[1], default_settings[splits[1]])

	config.save(PATH)


static func get_error(error : int, object_type : String = "") -> String:
	match error:
		1:  return str("<Error[1] ",  object_type, " Failed>")
		2:  return str("<Error[2] ",  object_type, " Unavailable>")
		3:  return str("<Error[3] ",  object_type, " Unconfigured>")
		4:  return str("<Error[4] ",  object_type, " Unauthorized>")
		5:  return str("<Error[5] ",  object_type, " Parameter range>")
		6:  return str("<Error[6] ",  object_type, " Out of memory>")
		7:  return str("<Error[7] ",  object_type, " File: Not found>")
		8:  return str("<Error[8] ",  object_type, " File: Bad drive>")
		9:  return str("<Error[9] ",  object_type, " File: Bad File path>")
		10: return str("<Error[10] ", object_type, " No File permission>")
		11: return str("<Error[11] ", object_type, " File already in use>")
		12: return str("<Error[12] ", object_type, " Can't open File>")
		13: return str("<Error[13] ", object_type, " Can't write to File>")
		14: return str("<Error[14] ", object_type, " Can't read to File>")
		15: return str("<Error[15] ", object_type, " File unrecognized>")
		16: return str("<Error[16] ", object_type, " File corrupt>")
		17: return str("<Error[17] ", object_type, " File missing dependencies>")
		18: return str("<Error[18] ", object_type, " End of File>")
		19: return str("<Error[19] ", object_type, " Can't open>")
		20: return str("<Error[20] ", object_type, " Can't create>")
		21: return str("<Error[21] ", object_type, " Query failed>")
		22: return str("<Error[22] ", object_type, " Already in use>")
		23: return str("<Error[23] ", object_type, " Locked>")
		24: return str("<Error[24] ", object_type, " Timeout>")
		25: return str("<Error[25] ", object_type, " Can't connect>")
		26: return str("<Error[26] ", object_type, " Can't resolve>")
		27: return str("<Error[27] ", object_type, " Connection error>")
		28: return str("<Error[28] ", object_type, " Can't acquire resource>")
		29: return str("<Error[29] ", object_type, " Can't fork process>")
		30: return str("<Error[30] ", object_type, " Invalid data>")
		31: return str("<Error[31] ", object_type, " Invalid parameter>")
		32: return str("<Error[32] ", object_type, " Already exists>")
		33: return str("<Error[33] ", object_type, " Doesn't exist>")
		34: return str("<Error[34] ", object_type, " Database: Can't read>")
		35: return str("<Error[35] ", object_type, " Database: Can't write>")
		36: return str("<Error[36] ", object_type, " Compilation failed>")
		37: return str("<Error[37] ", object_type, " Method not found>")
		38: return str("<Error[38] ", object_type, " Link failed>")
		39: return str("<Error[39] ", object_type, " Script failed>")
		40: return str("<Error[40] ", object_type, " Cyclic link>")
		41: return str("<Error[41] ", object_type, " Invalid declaration>")
		42: return str("<Error[42] ", object_type, " Duplicate symbol>")
		43: return str("<Error[43] ", object_type, " Parse error>")
		44: return str("<Error[44] ", object_type, " Busy error>")
		46: return str("<Error[45] ", object_type, " Skip error>")
		47: return str("<Error[46] ", object_type, " Help error>")
		48: return str("<Error[47] ", object_type, " Bug error>")
	return "N/A"


## Retrieves a value from the config file, validating settings beforehand. Simple wrapper for ConfigFile.get_value().
func _get_config_value(section: String, value : String, default_value: Variant = null) -> Variant:
	validate_settings()
	var _result = config.load(PATH)

	if !FileAccess.file_exists(PATH):
		push_warning(str("GoLogger: No settings.ini file present in ", PATH, ". Generating a new file with default settings."))
		create_settings_file()

	if _result != OK:
		push_error(str("GoLogger: ConfigFile failed to load settings.ini file."))
		return null

	var _val = config.get_value(section, value, default_settings[value])
	if _val == null:
		push_error(str("GoLogger: ConfigFile failed to load settings value from file."))
	return _val


func _check_category_name_conflicts() -> Array[String]:
	var categories = config.get_value("categories", "category_names" , [])
	if categories.is_empty():
		return []

	var found_conflicts: Array[String] = []
	var seen_names : Array[String] = []

	for name in categories:
		if name in seen_names:
			found_conflicts.append(name)
		else: seen_names.append(name)
	return found_conflicts


func _get_header(category_name: String = "") -> String:
	config.load(PATH)
	var format: String = _get_config_value("settings", "log_header_format")
	var _header: String = ""
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{category}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}"
	]

	if format != null and format != "":
		var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc"))
		var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
		var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
		var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
		var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
		var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
		var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))

		var replacements: Dictionary = {
			"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
			"{version}": str(ProjectSettings.get_setting("application/config/version")),
			"{category}": category_name,
			"{yy}": yy,
			"{mm}": mm,
			"{dd}": dd,
			"{hh}": hh,
			"{mi}": mi,
			"{ss}": ss
		}

		_header = format
		for tag in _tags:
			if tag in replacements:
				_header = _header.replace(tag, replacements[tag])

		return str(_header, " ")
	return ""


func _get_entry_format(entry: String, category_name: String) -> String:
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{instance_id}",
		"{category}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}",
		"{entry}"
	]

	var dt: Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc"))

	var yy: String = str(dt["year"]).substr(2, 2)
	var mm: String = str(dt["month"]  if dt["month"]  > 9 else str("0", dt["month"]))
	var dd: String = str(dt["day"]    if dt["day"]    > 9 else str("0", dt["day"]))
	var hh: String = str(dt["hour"]   if dt["hour"]   > 9 else str("0", dt["hour"]))
	var mi: String = str(dt["minute"] if dt["minute"] > 9 else str("0", dt["minute"]))
	var ss: String = str(dt["second"] if dt["second"] > 9 else str("0", dt["second"]))

	var replacements: Dictionary = {
		"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
		"{version}": str(ProjectSettings.get_setting("application/config/version")),
		"{instance_id}": instance_id,
		"{category}": category_name,
		"{yy}": yy,
		"{mm}": mm,
		"{dd}": dd,
		"{hh}": hh,
		"{mi}": mi,
		"{ss}": ss,
		"{entry}": entry
	}

	var format: String = _get_config_value("settings", "entry_format")
	var final_entry: String = format
	for tag in _tags:
		if tag in replacements:
			final_entry = final_entry.replace(tag, replacements[tag])

	return final_entry


func _get_file_name(category_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_config_value("settings", "use_utc"))
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	var fin : String
	fin = str(category_name, "(", yy, mm, dd, "_", hh,mi, ss, ").log")
	return fin


func _get_instance_id() -> String:
	# Create RNG and initial ID (keeps the old leading underscore format)
	var rng := RandomNumberGenerator.new()
	var letters: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz0123456789"
	var id_len: int = 5
	var id_str: String = ""
	rng.randomize()
	for i in range(id_len):
		var idx: int = rng.randi_range(0, letters.length() - 1)
		id_str += letters[idx]
	return id_str




func _on_timer_timeout(_timer: Timer) -> void:
	match _timer:
		session_timer:
			var _wt: float = _get_config_value("settings", "session_duration")
			match _get_config_value("settings", "limit_method"):
				1: # Session Timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
				2: # Both Count limit + Session timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()

		inaction_timer:
			popup_state = false


func _on_line_edit_text_changed(new_text : String) -> void:
	if inaction_timer != null and !inaction_timer.is_stopped():
		inaction_timer.stop()
	inaction_timer.start(30)

	if new_text != "":
		popup_yesbtn.disabled = false
		popup_line_edit.set_caret_column(popup_line_edit.text.length())
		if new_text.ends_with(".log") or new_text.ends_with(".txt"):
			copy_name = new_text.substr(0, new_text.length() - 4)
		copy_name = popup_line_edit.text
	else:
		popup_yesbtn.disabled = true


func _on_line_edit_text_submitted(new_text : String) -> void:
	if new_text != "": return

	var final_text: String = new_text
	var reject_str: Array[String] = [".log", ".txt", ".cfg", ".ini", ".json", ".xml", ".yml", ".yaml", ".csv"]
	var reject_ch: Array[String] = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]

	for string in reject_str:
		if new_text.ends_with(string):
			new_text = new_text.substr(0, new_text.length() - string.length())

	for ch in reject_ch:
		if new_text.find(ch) != -1:
			new_text = new_text.replace(ch, "")


	if new_text.ends_with(".log") or new_text.ends_with(".txt"):
		copy_name = new_text.substr(0, new_text.length() - 4)
	else:
		copy_name = popup_line_edit.text
	complete_copy()


func _on_button_up(btn: Button) -> void:
	match btn:
		popup_yesbtn:
			complete_copy()
		popup_nobtn:
			popup_state = false
