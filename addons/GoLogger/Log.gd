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
	# [Done] Add checkbox to LogCategory that marks one category as Default. When marked, that category is used whenever an unspecified category name is passed to entry()
	#
	# [Postponed?]Add proper error codes to all error/warning messages. Link to a wiki page detailing each error code?
	#
	# [Proposal] Add create_category(category_name:String, id: String) method allow users to create temporary categories programmatically - Store temporary categories in a runtime memory structure only, not in the .ini file
	# [Proposal] Add remove_category(category_name:String) method to allow users to remove temporary categories programmatically
	# [Proposal] Add list_categories() method to return an array of current category names
	# [Proposal] Add a custom node that users can attach to objects in their scene tree that creates a unique temp category for that object only while the scene is running

#BUG:
	# Creating and applying a name doesn't save the new category in `cateogry_names` array in the .ini file, so the category doesn't persist after the session ends.
	# [FixedEntry count isn't working
	# [Fixed] When deleting a category. The [category.category_name] section remains in the .ini file.

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

@export var gl_hotkeys: GLShortcut = preload("uid://dyi2aml73k4g8")
@onready var elements_canvaslayer: CanvasLayer = %GoLoggerElements
@onready var session_timer: Timer = %SessionTimer
@onready var instance_id_label: RichTextLabel = %InstanceIDLabel

enum LimitMethod {
	ENTRY_COUNT,
	SESSION_TIMER,
	BOTH,
	SEPERATOR,
	NONE
}

enum EntryCountAction {
	OVERWRITE_ENTRIES,
	RESTART,
	STOP
}

enum SessionTimerAction {
	RESTART,
	STOP
}

enum ErrorReportLevel {
	WARNINGS_ERRORS,
	ERRORS,
	NONE
}

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
		config.load(PATH)
		var fnt_sz := int(config.get_value(
			"settings", "id_font_size", 
			settings_dict.get("id_font_size").get("default"))
		)
		var fnt_col := Color.from_string(
			config.get_value("settings", "id_font_color", "ffffffff"), 
			settings_dict.get("id_font_color").get("default")
		)
		var ol_sz := int(config.get_value(
			"settings", "id_outline_size", 
			settings_dict.get("id_outline_size").get("default"))
		)
		var ol_col := Color.from_string(
			config.get_value("settings", "id_outline_color", "00000000"), 
			settings_dict.get("id_outline_color").get("default")
		)
		instance_id_label.text = str("  [font_size=", fnt_sz, "][color=", fnt_col.to_html(), "][outline_size=", ol_sz, "][outline_color=", ol_col.to_html(), "]", value, "  ")


var settings_dict := {
	"category_names": 						{"section": "categories", "name": "category_names", 					 	"type": TYPE_ARRAY,  	"default": ["game"]},
	"default_category": 					{"section": "categories", "name": "default_category", 	 				"type": TYPE_STRING,  "default": ""},
	"base_directory": 						{"section": "settings", 	"name": "base_directory", 						"type": TYPE_STRING, 	"control": null, "default": "user://GoLogger/"},
	"log_header_format": 					{"section": "settings", 	"name": "log_header_format", 					"type": TYPE_STRING,	"control": null,  "default": "{project_name} {version} {category} session [{yy}-{mm}-{dd} | {hh}:{mi}:{ss}]:"},
	"entry_format": 							{"section": "settings", 	"name": "entry_format", 							"type": TYPE_STRING,	"control": null, "default": "[{hh}:{mi}:{ss}] {instance_id}: {entry}"},
	"autostart_session": 					{"section": "settings", 	"name": "autostart_session", 					"type": TYPE_BOOL, 		"control": null, "default": true},
	"use_utc": 										{"section": "settings", 	"name": "use_utc", 										"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_print": 									{"section": "settings", 	"name": "id_print", 									"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_toggle": 									{"section": "settings", 	"name": "id_toggle", 									"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_startup_state": 					{"section": "settings", 	"name": "id_startup_state", 					"type": TYPE_BOOL, 		"control": null, "default": false},
	"id_align":										{"section": "settings", 	"name": "id_align", 									"type": TYPE_INT,			"control": null, "default": 0},
	"id_font_size":								{"section": "settings", 	"name": "id_font_size", 							"type": TYPE_INT, 		"control": null, "default": 12},
	"id_font_color":							{"section": "settings", 	"name": "id_font_color", 							"type": TYPE_STRING, 	"control": null, "default": "ffffff"},
	"id_outline_size":						{"section": "settings", 	"name": "id_outline_size", 						"type": TYPE_INT,			"control": null, "default": 8},
	"id_outline_color":						{"section": "settings", 	"name": "id_outline_color", 					"type": TYPE_STRING,	"control": null, "default": "000000"},
	"limit_method": 							{"section": "settings", 	"name": "limit_method", 							"type": TYPE_INT, 		"control": null, "default": 0},
	"entry_count_action": 				{"section": "settings", 	"name": "entry_count_action", 				"type": TYPE_INT, 		"control": null, "default": 0},
	"session_timer_action": 			{"section": "settings", 	"name": "session_timer_action", 			"type": TYPE_INT, 		"control": null, "default": 0},
	"file_cap": 									{"section": "settings", 	"name": "file_cap", 									"type": TYPE_INT, 		"control": null, "default": 10},
	"entry_cap": 									{"section": "settings", 	"name": "entry_cap", 									"type": TYPE_INT, 		"control": null, "default": 1200},
	"session_duration": 					{"section": "settings", 	"name": "session_duration", 					"type": TYPE_INT, 		"control": null, "default": 900},
	"error_reporting": 						{"section": "settings", 	"name": "error_reporting", 						"type": TYPE_INT, 		"control": null, "default": 0},
	"columns": 										{"section": "settings", 	"name": "columns", 										"type": TYPE_INT, 		"control": null, "default": 5}
}



func _ready() -> void:
	if !FileAccess.file_exists(PATH):
		create_settings_file()

	config.load(PATH)

	var id_toggle = config.get_value("settings", "id_toggle", false)
	var id_startup = config.get_value("settings", "id_startup_state", false)
	if id_toggle:
		instance_id_label.visible = id_startup

	session_timer.timeout.connect(_on_timer_timeout.bind(session_timer))

	assert(_check_category_name_conflicts().is_empty(), str("GoLogger: Conflicting category name(s) found: ", _check_category_name_conflicts()))
	match _get_config_value("settings", "id_align"):
		0: # Top L
			instance_id_label.horizontal_alignment = 	0
			instance_id_label.vertical_alignment = 		0
		1: # Top C
			instance_id_label.horizontal_alignment = 	1
			instance_id_label.vertical_alignment = 		0
		2: # Top R
			instance_id_label.horizontal_alignment = 	2
			instance_id_label.vertical_alignment = 		0
		4: # Center L
			instance_id_label.horizontal_alignment = 	0
			instance_id_label.vertical_alignment = 		1
		5: # Center C
			instance_id_label.horizontal_alignment = 	1
			instance_id_label.vertical_alignment = 		1
		6: # Center R
			instance_id_label.horizontal_alignment = 	2
			instance_id_label.vertical_alignment = 		1
		8: # Bottom L
			instance_id_label.horizontal_alignment = 	0
			instance_id_label.vertical_alignment = 		2
		9: # Bottom C
			instance_id_label.horizontal_alignment = 	1
			instance_id_label.vertical_alignment = 		2
		10: # Bottom R
			instance_id_label.horizontal_alignment = 	2
			instance_id_label.vertical_alignment = 		2


	instance_id = _get_instance_id()

	validate_settings()
	load_category_data()

	if _get_config_value("settings", "autostart_session"):
		start_session()


func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey\
		or event is InputEventJoypadButton\
		or event is InputEventJoypadMotion and event.axis == 4\
		or event is InputEventJoypadMotion and event.axis == 5: # Only allow trigger axes
			if gl_hotkeys.start_session_hotkey.shortcut.matches_event(event) and event.is_released():
				start_session()
			if gl_hotkeys.stop_session_hotkey.shortcut.matches_event(event) and event.is_released():
				stop_session()


			config.load(PATH)
			var id_toggle = config.get_value("settings", "id_toggle", false)
			var id_startup = config.get_value("settings", "id_startup_state", false)

			if gl_hotkeys.display_instance_id_hotkey.shortcut.matches_event(event):
				if id_toggle:
					if event.is_released():
						instance_id_label.hide() if instance_id_label.visible else instance_id_label.show()
						if _get_config_value("settings", "id_print"):
							print_rich("[font_size=12][color=fc4674][GoLogger][color=white] Instance ID: <[color=lightblue]", instance_id, "[/color]>")

				else:
					if event.is_pressed():
						instance_id_label.show()
						if _get_config_value("settings", "id_print"):
							print_rich("[font_size=12][color=fc4674][GoLogger][color=white] Instance ID: ", instance_id)
					if event.is_released():
						instance_id_label.hide()


		# Test entry logging
		if event is InputEventKey and event.keycode == KEY_COMMA and event.is_released():
			msg("Test entry ", "game", true)
		if event is InputEventKey and event.keycode == KEY_PERIOD and event.is_released():
			msg("Test entry without category name.")
		if event is InputEventKey and event.keycode == KEY_M and event.is_released():
			msg("Test entry in non-existent category.", "non_existant_category[THIS SHOULD REPORT ERROR!]")




## Loads category data from the config file into the cat_data dictionary.[br]
## Use instead of 'config.load(PATH)' whenever category data is needed.
func load_category_data(new_session: bool = false) -> void:
	config.load(PATH)
	cat_data.clear()

	var cat_names: Array = config.get_value("categories", "category_names", [])

	cat_data["categories"] = {
		"category_names": cat_names.duplicate(),
	}

	for c_name in cat_names:

		cat_data[c_name] = {
			"category_name": c_name,
			"category_index": config.get_value("categories." + str(c_name), "category_index", 0),
			"file_name": config.get_value("categories." + c_name, "file_name", ""),
			"file_path": config.get_value("categories." + c_name, "file_path", ""),
			"file_count": config.get_value("categories." + str(c_name), "file_count", 0),
			"entry_count": 0,
			"is_locked": config.get_value("categories." + str(c_name), "is_locked", false)
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

	for c_name in cat_data["categories"]["category_names"]:
		if !cat_data.has(c_name):
			continue
		var c = cat_data[c_name]
		var base_section := "categories." + str(c["category_name"])

		config.set_value(base_section, "category_name", c.get("category_name", c_name))
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

	if _get_config_value("settings", "limit_method") == LimitMethod.SESSION_TIMER or _get_config_value("settings", "limit_method") == LimitMethod.BOTH:
		session_timer.start(_get_config_value("settings", "session_duration"))


	for i in range(cat_data["categories"]["category_names"].size()):
		var c_name: String = cat_data["categories"]["category_names"][i]
		var f_name: String = _get_file_name(c_name) # e.g. "game.log"
		var f_path: String = str(
			config.get_value(
			"settings", "base_directory",	settings_dict.get("base_directory").get("default")
			), c_name, "_logs/", f_name
		)

		config.set_value("categories." + str(c_name), "file_name", f_name)
		config.set_value("categories." + str(c_name), "file_path", f_path)
		config.save(PATH)

		# Open/create directory
		var path: String = str(config.get_value("settings", "base_directory", "user://GoLogger/"), c_name, "_logs/")
		var dir : DirAccess
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)

		dir = DirAccess.open(path)

		if !dir and _get_config_value("settings", "error_reporting") != 2: # ErrCheck
			var _err = DirAccess.get_open_error()
			if _err != OK: push_warning("GoLogger: ", get_error(_err, "DirAccess"), " (", config.get_value(str("categories.", c_name), "file_path", "EMPTY FILEPATH!"), ").")
			continue

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

	save_category_data()
	session_status = true
	if session_timer.is_stopped() and _get_config_value("settings", "session_timer_action") == 1\
	or session_timer.is_stopped() and _get_config_value("settings", "session_timer_action") == 2:
		if session_timer != null: session_timer.start()
	session_started.emit()


func msg(log_msg : String, category_name: String = "", print_msg: bool = false) -> void:
	load_category_data()
	var _target_cat: String = 				category_name
	var _cats: Array = 								_get_config_value("categories", "category_names", [])
	var _default_cat: String = 				_get_config_value("categories", "default_category", "")
	var _target_filepath: String = 		_get_config_value(str("categories." + category_name), "file_path", "")
	var _limit_method: int = 					_get_config_value("settings", "limit_method")
	var _entry_action: int = 					_get_config_value("settings", "entry_count_action")
	var _entry_cap: int = 						_get_config_value("settings", "entry_cap")
	var _session_timer_action: int = 	_get_config_value("settings", "session_timer_action")
	var _session_duration: int = 			_get_config_value("settings", "session_duration")
	var _err_lv = 										_get_config_value("settings", "error_reporting")



	if log_msg == "":
		if _err_lv != 2:
			printerr("GoLogger: Attempted to log empty entry.")
		return

	if category_name == "": # Unspecified category -> Use Default category
		if _default_cat != "" and _cats.has(_default_cat):
			_target_cat = _default_cat
			_target_filepath = config.get_value(str("categories." + _default_cat), "file_path", "")
		else:
			if _err_lv != 2:
				if _default_cat.is_empty():
					printerr("GoLogger: Attempted to log entry into default category when one hasn't assigned:\n\t", msg)
				else:
					if !_cats.has(_default_cat):
						printerr("GoLogger: Entry failed to log into default category[", _default_cat, "] that does not exist(the default category was likely deleted). Please assign a new default category, or specify a category when logging entries.")
					printerr("GoLogger: Attempted to log entry into a default category[", _default_cat,"] that doesn't exist.")

			return

	if _cats.is_empty():
		if _err_lv != 2:
			printerr("GoLogger: Attempted to log entry without categories.")
		return

	if _target_cat not in _cats:
		if _err_lv != 2:
			printerr("GoLogger: Category '" + _target_cat + "' not found. Check correct spelling.")
		return

	if !session_status:
		return

	if _target_filepath == "":
		if _err_lv != 2:
			printerr("GoLogger: No valid file path found for category '" + _target_cat + "[" + instance_id + "]'.")
		return


	# Read existing Entries (note that first entry is Log Header)
	var _f = FileAccess.open(_target_filepath, FileAccess.READ)
	if !_f: # ER
		var _err = FileAccess.get_open_error()
		if _err != OK and _err_lv != 2:
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return

	var lines : Array[String] = []
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l)
	_f.close()
	config.load(PATH)
	config.set_value("categories." + str(_target_cat), "entry_count", lines.size())
	config.save(PATH)

	# Handle Limit Methods
	match _limit_method:

		LimitMethod.ENTRY_COUNT:
			match _entry_action:
				EntryCountAction.OVERWRITE_ENTRIES:
					while lines.size() >= _entry_cap:
						lines.remove_at(1) # Retain header

				EntryCountAction.RESTART:
					if lines.size() >= _entry_cap:
						stop_session()
						start_session()
						msg(log_msg, _target_cat)
						return

				EntryCountAction.STOP:
					if lines.size() >= _entry_cap:
						stop_session()
						return

		LimitMethod.SESSION_TIMER:
			match _session_timer_action:
				SessionTimerAction.RESTART:
					stop_session()
					start_session()
					msg(log_msg, _target_cat)
					return

				SessionTimerAction.STOP:
					stop_session()
					return

		LimitMethod.BOTH:
			match _entry_action:
				SessionTimerAction.RESTART:
					if lines.size() >= _entry_cap:
						stop_session()
						start_session()
						msg(log_msg, _target_cat)
						return

				SessionTimerAction.STOP:
					if lines.size() >= _entry_cap:
						stop_session()
						return

	# Rewrite file with existing lines / Update entry count
	cat_data[_target_cat]["entry_count"] = lines.size()
	var _fw = FileAccess.open(_target_filepath, FileAccess.WRITE)
	if !_fw: # ErrCheck
		var err = FileAccess.get_open_error()
		if err != OK and _err_lv != 2:
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "")

	for line in lines:
		_fw.store_line(str(line))

	# Write new entry
	var new_entry: String = _get_entry_format(log_msg, _target_cat)
	_fw.store_line(new_entry)
	_fw.close()
	if print_msg:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] <", _target_cat, "> ", new_entry.dedent())



func stop_session() -> void:
	if !session_status:	return

	load_category_data()

	var _err_lv: int = _get_config_value("settings", "error_reporting")
	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_config_value("settings", "use_utc")), "] Stopped log session.")

	for category in config.get_value("categories", "category_names", []):
		var _fp = cat_data[category]["file_path"]
		if _fp == "":
			if _err_lv != 2:
				push_warning("GoLogger: Failed to stop session properly. No valid file path found for category '", category, "'.")
			continue


		var _f = FileAccess.open(_fp, FileAccess.READ)
		if !_f:
			var _err = FileAccess.get_open_error()
			if _err_lv != 2:
				if _err != OK: push_warning("GoLogger: Failed to open file ", _fp, " with READ ", get_error(_err))
			push_warning("GoLogger: Failed to stop session properly. Error opening file!", _fp)
			session_status = false
			return
		var _content := _f.get_as_text()
		_f.close()


		var _fw = FileAccess.open(_fp, FileAccess.WRITE)
		if !_fw and _err_lv != 2:
			var _err = FileAccess.get_open_error()
			if _err != OK:
				push_warning("GoLogger: Attempting to stop session by writing to file (", _fp, ") -> Error[", _err, "]")
				return
		var _s := str(_content, str(_timestamp))
		_fw.store_line(_s)
		_fw.close()

		config.set_value("categories." + str(category), "file_name", "")
		config.set_value("categories." + str(category), "file_path", "")
		config.set_value("categories." + str(category), "entry_count", 0)

	config.save(PATH)
	session_status = false



func create_settings_file() -> void: # Mirror
	var cf := ConfigFile.new()

	for key in settings_dict.keys():
		for field in ["section", "default", "type", "control", "default"]:
			if field == "control" and settings_dict[key]["section"] == "categories":
				continue

			if not settings_dict[key].has(field):
				push_error("GoLogger: Error creating a settings file. 'settings_dict' entry '%s' missing '", field, "' field", % key)
				continue

		var section = settings_dict[key].get("section", "settings")
		cf.set_value(section, key, settings_dict[key]["default"])

	var _s = cf.save(PATH)
	if _s != OK:
		var _e = cf.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))
		return

	config.load(PATH) 



func validate_settings() -> void: # Mirror
	config.load(PATH) 

	for key in settings_dict.keys():
		var setting: Dictionary = settings_dict.get(key, {})
		var a_fields = ["section", "name", "type", "control", "default"]
		var b_fields = ["section", "name", "type", "default"]
		var err: Array[bool] = [false, false,false, false, false, false]

		# Check missing fields
		for i in range(a_fields.size()):

			if setting.has("section"):
				var fs = a_fields.duplicate()

				if setting["section"] == "categories":
					fs = b_fields.duplicate()

				# Collect + report missing fields
				if !setting.has_all(fs):
					var _e: Array[String] = []
					for j in range(fs.size()):
						if !setting.has(fs[j]):
							_e.append(fs[j])

					if not _e.is_empty():
						push_warning(str("GoLogger error: invalid settings_dict key. Missing field(s) ", _e, " for setting <", key, ">"))

		# Validate Presence
		if !config.has_section(setting["section"]) or !config.has_section_key(setting["section"], setting["name"]):
			config.set_value(setting["section"], setting["name"], setting["default"])
			continue

		# Validate Type
		if typeof(config.get_value(setting["section"], setting["name"])) != setting["type"]:
			config.set_value(setting["section"], setting["name"], setting["default"])

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

	var _val = config.get_value(section, value, settings_dict.get(value, {}).get("default"))
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
	var rng := RandomNumberGenerator.new()
	var letters: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
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
				LimitMethod.SESSION_TIMER: # Session Timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
				LimitMethod.BOTH: # Both Count limit + Session timer
					if _get_config_value("settings", "session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
