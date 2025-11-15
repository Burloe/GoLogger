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
	#
	#	[In progress] Add 'instance_id' to solve issue with concurrency in multiplayer projects
	# Instance ID's are implemented but entry() and stop_session() do not currently use them in any way. Need to ensure that they write to the correct file based on instance ID.
	# [In progress] Refactor .ini settings handling <needed to do to finish instance_id task
	#
	# [TBD]Consider adding {instance_id} tag to header and entry formats.
	#
	# Add create_category(category_name:String, id: String) method allow users to create temporary categories programmatically - Store temporary categories in a separate non-persistant array
	# ?Add remove_category(category_name:String) method to allow users to remove temporary categories programmatically

### Release Checklist: ###
	# Test manual test entry with KEY_COMMA in _input()
##########################

signal session_started ## Emitted when a log session has started.
signal session_stopped ## Emitted when a log session has been stopped.

const PATH = "user://GoLogger/settings.ini"
var config := ConfigFile.new()
var base_directory: String = "user://GoLogger/"
var header_string: String
var copy_name : String = ""
var session_status: bool = false:
	set(value):
		session_status = value
		if value: session_started.emit()
		else: session_stopped.emit()
# var temp_categories: Array = []

var cat_data : Dictionary = {
	"game": {
		"category_name": "game",
		"category_index": 0,
		"file_count": 0,
		"is_locked": false,
		"instances": {
			"D44r3": {
				"id": "D44r3",
				"file_name": "game_D44r3.log",
				"file_path": "user://GoLogger/game_Gologs/game(251113_161313)_D44r3",
				"entry_count": 0
			},
			"X45jR": {
				"id": "X45jR",
				"file_name": "game_X45jR.log",
				"file_path": "user://GoLogger/game_Gologs/game(251113_161313)_X43jR.log",
				"entry_count": 0
			}
		}
	},
	"player": {
		"category_name": "game",
		"category_index": 0,
		"file_count": 0,
		"is_locked": false,
		"instances": {
			"U4j9K": {
				"id": "U4j9K",
				"file_name": "player_U4j9K.log",
				"file_path": "user://GoLogger/player_Gologs/player(251113_161313)_U4j9K.log",
				"file_count": 0,
				"instances": {
					"U4j9K": {
						"id": "U4j9K",
						"file_name": "player_U4j9K.log",
						"file_path": "user://GoLogger/player_Gologs/player(251113_161313)_U4j9K",
						"entry_count": 0
					}
				}
			}
		}
	}
}

var categories: Array = [] # See CategoryData enum for structure.
enum CategoryData {
			CATEGORY_NAME = 0, # String - The name of the category
			CATEGORY_INDEX = 1, # Int - The index of the category in the categories array
			CURRENT_FILENAMES = 2, # Array[String] - Array of file names for each instance ID of the current files
			CURRENT_FILEPATHS = 3, # Array[String] - Array of file paths for each instance ID of the current files
			ENTRY_COUNT = 4, # Int - Current entry count in the active log file
			FILE_COUNT = 5, # Int - Current file count in the category directory
			IS_LOCKED = 6 # Bool - Whether the category is locked from editing/deletion
}
## Instance ID is a unique ID for each runtime instance of GoLogger. Used to differentiate between multiple instances when debugging multiplayer projects.
var instance_id: String = ""

@onready var elements_canvaslayer: CanvasLayer = %GoLoggerElements
@onready var session_timer: Timer = %SessionTimer
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

# Note that this dictionary is also present in GoLoggerDock.gd. If you update it here, update it there too.
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

var hotkey_start_session: InputEventShortcut = preload("res://addons/GoLogger/StartSessionShortcut.tres")
var hotkey_stop_session: InputEventShortcut = preload("res://addons/GoLogger/StopSessionShortcut.tres")
var hotkey_copy_session: InputEventShortcut = preload("res://addons/GoLogger/CopySessionShortcut.tres")



func _ready() -> void:
	config.load(PATH)
	base_directory = config.get_value("plugin", "base_directory")
	header_string = _get_header()
	elements_canvaslayer.layer = _get_settings_value("canvaslayer_layer")
	session_timer.timeout.connect(_on_timer_timeout.bind(session_timer))
	inaction_timer.timeout.connect(_on_timer_timeout.bind(inaction_timer))
	popup_line_edit.text_changed.connect(_on_line_edit_text_changed)
	popup_line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	popup_yesbtn.button_up.connect(_on_button_up.bind(popup_yesbtn))
	popup_nobtn.button_up.connect(_on_button_up.bind(popup_nobtn))
	popup.visible = popup_state
	popup_errorlbl.visible = false
	popup_yesbtn.disabled = true

	assert(_check_filename_conflicts() == "", str("GoLogger: Conflicting category_name [", _check_filename_conflicts(), "] found in two(or more) categories."))

	validate_settings()
	instance_id = _get_instance_id()
	load_category_data()

	if _get_settings_value("autostart_session"):
		start_session()


func _physics_process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		if popup_state and inaction_timer != null and !inaction_timer.is_stopped():
			prompt_label.text = str("[center]Save copies of the current logs?[font_size=12]\nAutomatically cancelled in ", snapped(inaction_timer.time_left, 1.0),"s!\n[color=lightblue]Limit methods are paused during this prompt.")


func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event is InputEventKey \
		or event is InputEventJoypadButton \
		or event is InputEventJoypadMotion and event.axis == 4 \
		or event is InputEventJoypadMotion and event.axis == 5: # Only allow trigger axis
			if hotkey_start_session.shortcut.matches_event(event) and event.is_released():
				start_session()
			if hotkey_stop_session.shortcut.matches_event(event) and event.is_released():
				stop_session()
			if hotkey_copy_session.shortcut.matches_event(event) and event.is_released():
				save_copy()

		# Test entry logging with Comma Key.
		if event is InputEventKey and event.keycode == KEY_COMMA and event.is_released():
			var v1: int = 1234
			var v2: float = 56.78
			entry("Test entry " + str(v1) + " - " + str(v2), 0, true)



func load_category_data() -> void:
	config.load(PATH)
	cat_data.clear()

	var names: Array = config.get_value("categories", "category_names", [])
	var instance_ids: Array = config.get_value("categories", "instance_ids", [instance_id])

	cat_data["categories"] = {
		"category_names": names.duplicate(),
		"instance_ids": instance_ids.duplicate()
	}

	for name in names:
		var instances: Dictionary = {}
		for id in instance_ids:
			var inst_section := "categories." + str(name) + "." + str(id)
			instances[id] = {
				"id": str(id),
				"file_name": config.get_value(inst_section, "file_name", ""),
				"file_path": config.get_value(inst_section, "file_path", ""),
				"entry_count": config.get_value(inst_section, "entry_count", 0)
			}

		cat_data[name] = {
			"category_name": name,
			"category_index": config.get_value("categories." + str(name), "category_index", 0),
			"file_count": config.get_value("categories." + str(name), "file_count", 0),
			"is_locked": config.get_value("categories." + str(name), "is_locked", false),
			"instances": instances
		}

	# cat_data["categories"]["category_names"].append(config.get_value("categories", "category_names", null))
	# cat_data["categories"]["instance_ids"].append(config.get_value("categories", "instance_ids", instance_id))

	# for name in cat_data["categories"]["category_names"]:
	# 	var data: Dictionary = {}
	# 	for id in config.get_value("categories", "instance_ids", []):
	# 		var instance: Dictionary = {
	# 			"id": id,
	# 			"file_name": config.get_value("categories." + name + "." + id, "file_name", ""),
	# 			"file_path": config.get_value("categories." + name + "." + id, "file_path", ""),
	# 			"entry_count": config.get_value("categories." + name + "." + id, "entry_count", 0)
	# 		}
	# 		data[id] = instance


	# 	cat_data["categories." + name] = {
	# 		"category_name": name,
	# 		"category_index": config.get_value("categories." + name, "category_index", 0),
	# 		"file_count": config.get_value("categories." + name, "file_count", 0),
	# 		"is_locked": config.get_value("categories" + name, "is_locked", false),
	# 		"instances": data
	# 	}


func save_category_data() -> void:
	# Ensure there is categories meta to save
	if !cat_data.has("categories"):
		return

	# Load existing config so we don't clobber unrelated sections
	config.load(PATH)

	# Save meta arrays
	config.set_value("categories", "category_names", cat_data["categories"]["category_names"])
	config.set_value("categories", "instance_ids", cat_data["categories"]["instance_ids"])

	# [categories.category_name]
	for name in cat_data["categories"]["category_names"]:
		if !cat_data.has(name):
			continue
		var c = cat_data[name]
		var base_section := "categories." + str(c["category_name"])

		config.set_value(base_section, "category_name", c.get("category_name", name))
		config.set_value(base_section, "category_index", c.get("category_index", 0))
		config.set_value(base_section, "file_count", c.get("file_count", 0))
		config.set_value(base_section, "is_locked", c.get("is_locked", false))

		# [categories.category_name.instance_id]
		for id in cat_data["categories"]["instance_ids"]:
			if !c.has("instances") or !c["instances"].has(id):
				continue
			var inst = c["instances"][id]
			var inst_section := base_section + "." + str(id)
			config.set_value(inst_section, "id", inst.get("id", id))
			config.set_value(inst_section, "file_name", inst.get("file_name", ""))
			config.set_value(inst_section, "file_path", inst.get("file_path", ""))
			config.set_value(inst_section, "entry_count", inst.get("entry_count", 0))

	# Persist to disk
	config.save(PATH)



	# config.load(PATH) #? Ensure settings data isn't overwritten with old data

	# # [categories]
	# config.set_value("categories", "category_names", cat_data["categories"]["category_names"])
	# config.set_value("categories", "instance_ids", cat_data["categories"]["instance_ids"])

	# # [categories.category_name]
	# for c_name in cat_data.keys():
	# 	config.set_value("categories." + cat_data[c_name]["category_name"], "category_name", 	cat_data[c_name]["category_name"])
	# 	config.set_value("categories." + cat_data[c_name]["category_name"], "category_index", cat_data[c_name]["category_index"])
	# 	config.set_value("categories." + cat_data[c_name]["category_name"], "file_count", 		cat_data[c_name]["file_count"])
	# 	config.set_value("categories." + cat_data[c_name]["category_name"], "is_locked", 			cat_data[c_name]["is_locked"])

	# 	# [categories.category_name.instance_id]
	# 	for id in cat_data["categories"]["instance_ids"]:
	# 		var section: String = str("categories." + cat_data[c_name] + "." + id)
	# 		config.set_value(section, "id", cat_data[c_name]["instances"]["id"])
	# 		config.set_value(section, "file_name", cat_data[c_name]["instances"]["file-name"])
	# 		config.set_value(section, "file_path", cat_data[c_name]["instances"]["file_path"])
	# 		config.set_value(section, "entry_count", cat_data[c_name]["instances"]["entry_count"])

	# config.save(PATH)





func start_session() -> void:
	if session_status: # ErrCheck
		if _get_settings_value("error_reporting") != 2 and !_get_settings_value("disable_warn1"):
			push_warning("GoLogger: Failed to start session, a session is already active.")
		return

	config.load(PATH)
	categories = config.get_value("plugin", "categories")

	if categories.is_empty(): # ErrCheck
		push_warning(str("GoLogger warning: Unable to start a session. No valid log categories have been added."))
		return


	if _get_settings_value("limit_method") == 1 or _get_settings_value("limit_method") == 2:
		session_timer.start(_get_settings_value("session_duration"))

	for i in range(categories.size()):
		categories[i][CategoryData.CURRENT_FILEPATHS] = _get_file_name(categories[i][CategoryData.CATEGORY_NAME])
		var _path : String
		if _path.begins_with("res://") or _path.begins_with("user://"):
			_path = str(base_directory, categories[i][CategoryData.CATEGORY_NAME], "_Gologs/")
		else:
			_path = str(base_directory, categories[i][CategoryData.CATEGORY_NAME], "_Gologs/")

		if _path == "": # ErrCheck

			if _get_settings_value("error_reporting") == 0:
				push_error(str("GoLogger: Failed to start session due to invalid directory path(", categories[i][CategoryData.CURRENT_FILEPATHS], "). Please assign a valid directory path."))

			if _get_settings_value("error_reporting") == 1:
				push_warning(str("GoLogger: Failed to start session due to invalid directory path(", categories[i][CategoryData.CURRENT_FILEPATHS], "). Please assign a valid directory path."))

			return


		var _dir : DirAccess
		if !DirAccess.dir_exists_absolute(_path):
			DirAccess.make_dir_recursive_absolute(_path)

		if !DirAccess.dir_exists_absolute(str(_path, "saved_logs/")):
			DirAccess.make_dir_recursive_absolute(str(_path, "saved_logs/"))
		_dir = DirAccess.open(_path)

		if !_dir and _get_settings_value("error_reporting") != 2: # ErrCheck
			var _err = DirAccess.get_open_error()
			if _err != OK: push_warning("GoLogger: ", get_error(_err, "DirAccess"), " (", _path, ").")
			return

		categories[i][CategoryData.CURRENT_FILENAMES] = []
		categories[i][CategoryData.CURRENT_FILEPATHS]  = []
		categories[i][CategoryData.CURRENT_FILENAMES].append(_get_file_name(categories[i][CategoryData.CATEGORY_NAME]))
		categories[i][CategoryData.CURRENT_FILEPATHS].append(str(_path, categories[i][CategoryData.CURRENT_FILENAMES]))

		var _f = FileAccess.open(categories[i][CategoryData.CURRENT_FILEPATHS], FileAccess.WRITE)
		var _files = _dir.get_files()
		categories[i][CategoryData.FILE_COUNT] = _files.size()
		if _get_settings_value("file_cap") > 0:
			while _files.size() > _get_settings_value("file_cap") -1:
				_files.sort()
				_dir.remove(_files[CategoryData.CATEGORY_NAME])
				_files.remove_at(CategoryData.CATEGORY_NAME)

				var _err = DirAccess.get_open_error()
				if _err != OK and _get_settings_value("error_reporting") != 2:
					push_warning("GoLoggger Error: Failed to remove old log file -> ", get_error(_err, "DirAccess"))

		if !_f and _get_settings_value("error_reporting") != 2:
			push_warning("GoLogger: Failed to create log file(", categories[i][CategoryData.CURRENT_FILEPATHS], ").")

		else:
			var _s := str(header_string, categories[i][CategoryData.CATEGORY_NAME], " Log session started[", Time.get_datetime_string_from_system(_get_settings_value("use_utc"), true), "]:")
			_f.store_line(_s)
			categories[i][CategoryData.ENTRY_COUNT] = 0
		_f.close()

	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	session_status = true
	if session_timer != null:
		if session_timer.is_stopped() and _get_settings_value("session_timer_action") == 1 or session_timer.is_stopped() and _get_settings_value("session_timer_action") == 2:
			session_timer.start()
	session_started.emit()


func entry(log_entry : String, category_index : int = 0, print_entry_to_output: bool = false) -> void:
	config.load(PATH)
	categories = config.get_value("plugin", "categories")
	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_settings_value("use_utc")), "] ")

	if categories == null or categories.is_empty(): # ErrCheck
		if _get_settings_value("error_reporting") != 2:
			printerr("GoLogger: No valid categories to log in.")
		return
	if categories[category_index][CategoryData.CATEGORY_NAME] == "": # ErrCheck
		if _get_settings_value("error_reporting") != 2:
			printerr("GoLogger: Attempted to log entry on an invalid category.")
			return
	if !session_status: # ErrCheck
		if _get_settings_value("error_reporting") != 2 and !_get_settings_value("disable_warn2"): push_warning("GoLogger: Failed to log entry due to inactive session.")
		return


	# Get target file based on instance ID
	var target_filepath: String = ""
	var target_file: String = ""
	for i in categories[category_index][CategoryData.CURRENT_FILENAMES]:
		if i.ends_with(str("_", instance_id, ".log")):
			target_file = i
	for i in categories[category_index][CategoryData.CURRENT_FILEPATHS]:
		if i.ends_with(str("_", instance_id, ".log")):
			target_filepath = i


	# Open file to read existing lines
	var _f = FileAccess.open(categories[category_index][CategoryData.CURRENT_FILEPATHS], FileAccess.READ)
	if !_f: # Error check
		var _err = FileAccess.get_open_error()
		if _err != OK and _get_settings_value("error_reporting") != 2:
			push_warning("Gologger Error: Log entry failed [", get_error(_err, "FileAccess"), ".")
		return

	var lines : Array[String] = []
	while not _f.eof_reached():
		var _l = _f.get_line().strip_edges(false, true)
		if _l != "":
			lines.append(_l)
	_f.close()


		# Handle Limit Methods
	if !popup_state:
		match _get_settings_value("limit_method"):

			0: # Entry count
				match _get_settings_value("entry_count_action"):
					0: # Remove old entries
						while lines.size() >= _get_settings_value("entry_cap"):
							lines.remove_at(1) # Keeping header line 0

					1: # Stop & start
						if lines.size() >= _get_settings_value("entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, category_index)
							return

					2: # Stop only
						if lines.size() >= _get_settings_value("entry_cap"):
							stop_session()
							return

			1: # Session timer
				match _get_settings_value("session_timer_action"):
					0: # Stop & start session
						stop_session()
						start_session()
						entry(log_entry, category_index)
						return

					1: # Stop session
						stop_session()
						return

			2: # Both Entry count limit and Session Timer
				match _get_settings_value("entry_count_action"):
					0: # Stop & start session
						if lines.size() >= _get_settings_value("entry_cap"):
							stop_session()
							start_session()
							entry(log_entry, category_index)
							return

					1: # Stop session
						if lines.size() >= _get_settings_value("entry_cap"):
							stop_session()
							return


	# Rewrite file with existing lines / Update entry count
	#TODO: Need to account for individual instance ID entry counts here [make into array?]
	categories[category_index][CategoryData.ENTRY_COUNT] = lines.size()
	var _fw = FileAccess.open(target_filepath, FileAccess.WRITE)
	if !_fw: # ErrCheck
		var err = FileAccess.get_open_error()
		if err != OK and _get_settings_value("error_reporting") != 2:
			push_warning("GoLogger error: Log entry failed. ", get_error(err, "FileAccess"), "")

	for line in lines:
		_fw.store_line(str(line))

	# Write new entry
	var new_entry: String = _get_entry_format(log_entry)
	_fw.store_line(new_entry)
	_fw.close()
	if print_entry_to_output:
		print_rich("[color=fc4674][font_size=12][GoLogger][color=white] <", categories[category_index][CategoryData.CATEGORY_NAME], "> ", new_entry.dedent())


func save_copy(_name: String = "") -> void:
	if !session_status:
		return

	# No specified name -> prompt popup for name
	if _name == "":
		popup_state = true if popup_state == false else false
	# Name specified, i.e. called programmatically -> save copy using predetermines name
	else:
		copy_name = _name
		complete_copy()


func complete_copy() -> void:
	if !session_status:
		if _get_settings_value("error_reporting") != 2 and !_get_settings_value("disable_warn2"): push_warning("GoLogger: Attempt to log entry failed due to inactive session.")
		return

	config.load(PATH)
	categories = config.get_value("plugin", "categories")

	if categories.is_empty():
		if config.get_value("plugin", "error_reporting"):
			push_warning("GoLogger: Unable to complete copy action. No categories are present.")

	if copy_name.ends_with(".log") or copy_name.ends_with(".txt"):
		copy_name = copy_name.substr(0, copy_name.length() - 4)
	var _timestamp : String = str("[", Time.get_time_string_from_system(_get_settings_value("use_utc")), "] ")

	for i in range(categories.size()):
		var _fr = FileAccess.open(categories[i][CategoryData.CURRENT_FILEPATHS], FileAccess.READ)
		if !_fr:
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to open base file to copy the session [", categories[i][CategoryData.CURRENT_FILEPATHS],"].")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return

		var _c = _fr.get_as_text()
		var _path := str(base_directory, categories[i][CategoryData.CATEGORY_NAME], "_Gologs/saved_logs/", _get_file_name(copy_name))
		var _fw = FileAccess.open(_path, FileAccess.WRITE)
		if !_fw:
			var _e = FileAccess.get_open_error()
			popup_errorlbl.text = str("[outline_size=8][center][color=#e84346]Failed to create copy of file [", _path,"] - ", get_error(_e), ".")
			popup_errorlbl.visible = true
			await get_tree().create_timer(4.0).timeout
			return
		_fw.store_line(str(_c, "\nSaved copy of ", categories[i][CategoryData.CURRENT_FILENAMES], "."))
		_fw.close()
	config.set_value("plugin", "categories", categories)
	config.save(PATH)
	popup_state = false


func stop_session() -> void:
	if !session_status:
		return

	else:
		config.load(PATH)
		categories = config.get_value("plugin", "categories")
		var _timestamp : String = str("[", Time.get_time_string_from_system(_get_settings_value("use_utc")), "] Stopped log session.")

		for i in range(categories.size()):

			# Open file
			var _f = FileAccess.open(categories[i][CategoryData.CURRENT_FILEPATHS], FileAccess.READ)
			if !_f:
				var _err = FileAccess.get_open_error()
				if _get_settings_value("error_reporting") != 2:
					if _err != OK: push_warning("GoLogger: Failed to open file ", categories[i][CategoryData.CURRENT_FILEPATHS], " with READ ", get_error(_err))
				push_warning("GoLogger: Stopped session but failed to do so properly. Couldn't open the file.")
				session_status = false
				return
			var _content := _f.get_as_text()
			_f.close()
			var _fw = FileAccess.open(categories[i][CategoryData.CURRENT_FILEPATHS], FileAccess.WRITE)
			if !_fw and _get_settings_value("error_reporting") != 2:
				var _err = FileAccess.get_open_error()
				if _err != OK:
					push_warning("GoLogger: Attempting to stop session by writing to file (", categories[i][CategoryData.CURRENT_FILEPATHS], ") -> Error[", _err, "]")
					return
			var _s := str(_content, str(_timestamp + "Stopped Log Session.") if _get_settings_value("timestamp_entries") else "Stopped Log Session.")
			_fw.store_line(_s)
			_fw.close()
			categories[i][CategoryData.CURRENT_FILENAMES] = ""
			categories[i][CategoryData.CURRENT_FILEPATHS] = ""
			categories[i][CategoryData.ENTRY_COUNT] = 0


	config.set_value("plugin", "categories", categories)
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


func create_settings_file() -> void: # Note mirror function present in GoLoggerDock.gd. Keep both in sunc.
	var _a : Array[Array] = [["game", 0, [], "null", 0, 0, false], ["player", 1, [], "null", 0, 0, false]]
	config.set_value("plugin", "base_directory", "user://GoLogger/")
	config.set_value("plugin", "categories", _a)

	config.set_value("settings", "columns", 6)
	config.set_value("settings", "log_header_format", "{project_name} {version} {category} [{yy}-{mm}-{dd} | {hh:mi:ss}]:")
	config.set_value("settings", "entry_format", "\t[{hh}:{mi}:{ss}]")
	config.set_value("settings", "canvaslayer_layer", 5)
	config.set_value("settings", "autostart_session", true)
	config.set_value("settings", "use_utc", false)
	config.set_value("settings", "limit_method", 0)
	config.set_value("settings", "entry_count_action", 0)
	config.set_value("settings", "session_timer_action", 0)
	config.set_value("settings", "file_cap", 10)
	config.set_value("settings", "entry_cap", 300)
	config.set_value("settings", "session_duration", 300.0)
	config.set_value("settings", "error_reporting", 0)
	config.set_value("settings", "disable_warn1", false)
	config.set_value("settings", "disable_warn2", false)
	var _s = config.save(PATH)
	if _s != OK:
		var _e = config.get_open_error()
		printerr(str("GoLogger error: Failed to create settings.ini file! ", get_error(_e, "ConfigFile")))


func validate_settings() -> void: # Note mirror function present in GoLoggerDock.gd. Keep both in sunc.
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



func _get_settings_value(value : String) -> Variant:
	validate_settings()
	var _config = ConfigFile.new()
	var _result = _config.load(PATH)
	var section : String = "settings"

	if !FileAccess.file_exists(PATH):
		push_warning(str("GoLogger: No settings.ini file present in ", PATH, ". Generating a new file with default settings."))
		create_settings_file()

	if _result != OK:
		push_error(str("GoLogger: ConfigFile failed to load settings.ini file."))
		return null

	if value == "base_directory" or value == "categories":
		section = "plugin"

	var _val = _config.get_value(section, value, default_settings[value])
	if _val == null:
		push_error(str("GoLogger: ConfigFile failed to load settings value from file."))
	return _val


func _check_filename_conflicts() -> String:
	categories = config.get_value("plugin", "categories")
	var seen_resources : Array[String] = []
	for r in categories:
		if !seen_resources.is_empty():
			if r[0] in seen_resources:
				return r[0]
			else: seen_resources.append(r[0])
		else: seen_resources.append(r[0])
	return ""


func _get_header() -> String:
	config.load(PATH)
	var format: String = _get_settings_value("log_header_format")
	var _header: String = ""
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}"
	]

	if format != null and format != "":
		var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_settings_value("use_utc"))
		var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
		var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
		var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
		var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
		var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
		var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))

		var replacements: Dictionary = {
			"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
			"{version}": str(ProjectSettings.get_setting("application/config/version")),
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


func _get_entry_format(entry: String) -> String:
	var _tags: Array[String] = [
		"{project_name}",
		"{version}",
		"{yy}",
		"{mm}",
		"{dd}",
		"{hh}",
		"{mi}",
		"{ss}",
		"{entry}"
	]

	var dt: Dictionary = Time.get_datetime_dict_from_system(_get_settings_value("use_utc"))

	var yy: String = str(dt["year"]).substr(2, 2)
	var mm: String = str(dt["month"]  if dt["month"]  > 9 else str("0", dt["month"]))
	var dd: String = str(dt["day"]    if dt["day"]    > 9 else str("0", dt["day"]))
	var hh: String = str(dt["hour"]   if dt["hour"]   > 9 else str("0", dt["hour"]))
	var mi: String = str(dt["minute"] if dt["minute"] > 9 else str("0", dt["minute"]))
	var ss: String = str(dt["second"] if dt["second"] > 9 else str("0", dt["second"]))

	var replacements: Dictionary = {
		"{project_name}": str(ProjectSettings.get_setting("application/config/name")),
		"{version}": str(ProjectSettings.get_setting("application/config/version")),
		"{yy}": yy,
		"{mm}": mm,
		"{dd}": dd,
		"{hh}": hh,
		"{mi}": mi,
		"{ss}": ss,
		"{entry}": entry
	}

	var format: String = _get_settings_value("entry_format")
	var final_entry: String = format
	for tag in _tags:
		if tag in replacements:
			final_entry = final_entry.replace(tag, replacements[tag])

	return final_entry


func _get_file_name(category_name : String) -> String:
	var dict  : Dictionary = Time.get_datetime_dict_from_system(_get_settings_value("use_utc"))
	var yy  : String = str(dict["year"]).substr(2, 2) # Removes 20 from 2024
	var mm  : String = str(dict["month"]  if dict["month"]  > 9 else str("0", dict["month"]))
	var dd  : String = str(dict["day"]    if dict["day"]    > 9 else str("0", dict["day"]))
	var hh  : String = str(dict["hour"]   if dict["hour"]   > 9 else str("0", dict["hour"]))
	var mi  : String = str(dict["minute"] if dict["minute"] > 9 else str("0", dict["minute"]))
	var ss  : String = str(dict["second"] if dict["second"] > 9 else str("0", dict["second"]))
	var fin : String
	fin = str(category_name, "(", yy, mm, dd, "_", hh,mi, ss, ")_", instance_id, ".log")

	return fin


func _get_instance_id() -> String:
	# Create RNG and initial ID (keeps the old leading underscore format)
	var rng := RandomNumberGenerator.new()
	var letters: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz0123456789"
	var id_len: int = 5
	var id_str: String = "_"
	rng.randomize()
	for i in range(id_len):
		var idx: int = rng.randi_range(0, letters.length() - 1)
		id_str += letters[idx]

	# Collect used IDs by scanning category log folders and their saved_logs subfolders
	var used_ids: Array = []
	config.load(PATH)
	var categories_list: Array = config.get_value("plugin", "categories", [])
	for cat in categories_list:
		if typeof(cat) != TYPE_ARRAY or cat.size() == 0:
			continue
		var cat_name: String = str(cat[0])
		if cat_name == "":
			continue

		# Check  main category folder
		var gologs_path := str(base_directory, cat_name, "_Gologs/")
		var d := DirAccess.open(gologs_path)
		if d:
			var files := d.get_files()
			for f in files:
				if f.ends_with(".log"):
					var base := f.substr(0, f.length() - 4) # remove ".log"
					var id := _extract_id_from_basename(base)
					if id != "" and id not in used_ids:
						used_ids.append(id)

			# Check saved_logs subfolder
			var saved_path := str(gologs_path, "saved_logs/")
			var ds := DirAccess.open(saved_path)
			if ds:
				var sfiles := ds.get_files()
				for sf in sfiles:
					if sf.ends_with(".log"):
						var sbase := sf.substr(0, sf.length() - 4)
						var sid := _extract_id_from_basename(sbase)
						if sid != "" and sid not in used_ids:
							used_ids.append(sid)

	# Re-generate ID if conflict found
	while id_str.substr(1) in used_ids:
		id_str = ""
		for i in range(id_len):
			var idx := rng.randi_range(0, letters.length() - 1)
			id_str += letters[idx]

	return id_str


func _extract_id_from_basename(basename: String) -> String:
	# Used by _get_instance_id exclusively to extract the ID portion from a filename
	#
	# Extracts the ID from a basename like:
	#   "game(241112_215340)D39fk" -> "D39fk"
	# Returns "" if none or invalid.

	var pos := basename.rfind(")")
	if pos == -1 or pos >= basename.length() - 1:
		return ""
	var candidate := basename.substr(pos + 1, basename.length() - (pos + 1)).strip_edges()
	if candidate == "":
		return ""

	var id_regex := RegEx.new()

	if id_regex.compile(r"^[A-Za-z][A-Za-z0-9_-]*$") == OK:
		var m := id_regex.search(candidate)
		return candidate if m else ""

	else: # Ensure first char is a letter (is_valid_ascii_identifier requires the first char to be a letter)
		if candidate.length() == 0:
			return ""
		var first_ch := candidate.substr(0, 1)
		if not (first_ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"):
			return ""

		# Validate remaining characters
		for i in range(1, candidate.length()):
			var ch := candidate.substr(i, 1)
			# ch.is_valid_ascii_identifier() covers letters, digits and underscore.
			if not (ch.is_valid_ascii_identifier() or ch == "-"):
				return ""
		return candidate


func _on_timer_timeout(_timer: Timer) -> void:
	match _timer:
		session_timer:
			var _wt: float = _get_settings_value("session_duration")
			match _get_settings_value("limit_method"):
				1: # Session Timer
					if _get_settings_value("session_timer_action") == 0: # Stop & Start
						stop_session()
						await get_tree().physics_frame
						session_timer.wait_time = _wt
						start_session()
					else: # Stop only
						stop_session()
						session_timer.stop()
				2: # Both Count limit + Session timer
					if _get_settings_value("session_timer_action") == 0: # Stop & Start
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
	if new_text != "":
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
